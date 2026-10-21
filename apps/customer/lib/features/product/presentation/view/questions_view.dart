import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/presentation/widgets/app_text_field.dart';
import 'package:core/presentation/widgets/choice_sheet.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/presentation/view/widgets/ask_question_sheet.dart';
import 'package:customer/features/product/presentation/view/widgets/product_page_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/questions_page_parts.dart';
import 'package:customer/features/product/presentation/view_model/question_query_view_model.dart';
import 'package:customer/features/product/presentation/view_model/questions_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// What [QuestionsView] opens with: the product, and whether to start
/// asking a question.
typedef QuestionsRequest = ({String id, bool ask});

/// Every question about a product: search, topics, sort, each with its
/// answers, and a way to ask or answer.
class QuestionsView extends ConsumerStatefulWidget {
  const QuestionsView({required this.id, this.ask = false, super.key});

  final String id;

  /// Opens the ask sheet once the questions show.
  final bool ask;

  @override
  ConsumerState<QuestionsView> createState() => _QuestionsViewState();
}

class _QuestionsViewState extends ConsumerState<QuestionsView>
    with ViewReadyMixin<QuestionsView> {
  static const double _bottom = 24;
  static const Duration _searchPause = Duration(milliseconds: 300);
  static const Duration _swap = Duration(milliseconds: 250);

  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchTimer;

  QuestionsViewModelProvider get _questions =>
      questionsViewModelProvider(widget.id);
  QuestionQueryViewModelProvider get _query =>
      questionQueryViewModelProvider(widget.id);

  @override
  void dispose() {
    _searchTimer?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    unawaited(_loadThenAsk());
  }

  Future<void> _loadThenAsk() async {
    await ref.read(_questions.notifier).load();
    final page = ref.read(_questions).dataOrNull;
    if (widget.ask && mounted && page != null) {
      await _ask(page.product);
    }
  }

  void _load() => unawaited(ref.read(_questions.notifier).load());

  void _searchFor(String words) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      _searchPause,
      () => ref.read(_query.notifier).search(words),
    );
  }

  Future<void> _ask(String product, {ProductQuestion? answering}) async {
    final l10n = context.l10n;
    final posted = await AskQuestionSheet.show(
      context,
      productId: widget.id,
      product: product,
      questionId: answering?.id,
      question: answering?.question,
    );
    if ((posted ?? false) && mounted) {
      context.showSnackBar(
        answering == null
            ? l10n.productQuestionPosted
            : l10n.productAnswerPosted,
      );
    }
  }

  Future<void> _chooseSort(QuestionSort current) async {
    final l10n = context.l10n;
    final chosen = await ChoiceSheet.show(
      context,
      title: l10n.productSortTitle,
      options: <String>[l10n.productSortHelpful, l10n.productSortNewest],
      selected: current.index,
    );
    if (chosen != null && mounted) {
      ref.read(_query.notifier).sort(QuestionSort.values[chosen]);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_questions, context);
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: ViewStateSwitcher<QuestionsPage>(
          state: ref.watch(_questions),
          onRetry: _load,
          onData: _page,
        ),
      ),
    );
  }

  Widget _page(QuestionsPage page) {
    final l10n = context.l10n;
    final text = context.textTheme;
    final query = ref.watch(_query);
    final open = ref.watch(openAnswersViewModelProvider(widget.id));
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final topic = query.topic;
    return Column(
      children: <Widget>[
        ProductPageBar(
          title: l10n.productQuestionsTitle,
          subtitle: page.product,
          bottomGap: 0,
          bottom: FilterChips(
            labels: <String>[
              l10n.productQuestionFilterAll(page.total),
              ...page.topics,
            ],
            selected: topic == null ? 0 : page.topics.indexOf(topic) + 1,
            onSelect: (index) => ref
                .read(_query.notifier)
                .topic(index == 0 ? null : page.topics[index - 1]),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.md.h,
                AppSpacing.lg.w,
                _bottom.h + context.viewPadding.bottom,
              ),
              children:
                  <Widget>[
                        AppTextField(
                          controller: _search,
                          focusNode: _searchFocus,
                          icon: Assets.iconsSearch,
                          hint: l10n.productQuestionsSearch,
                          whiteWhenFocused: false,
                          textInputAction: TextInputAction.search,
                          onChanged: _searchFor,
                        ),
                        Row(
                          spacing: AppSpacing.sm.w,
                          children: <Widget>[
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  l10n.productQuestionsSummary(
                                    decimal.format(page.total),
                                    decimal.format(page.answerCount),
                                  ),
                                  style: text.titleMedium,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => unawaited(_chooseSort(query.sort)),
                              borderRadius: BorderRadius.circular(
                                AppRadius.xs.r,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: AppSpacing.xs.w,
                                children: <Widget>[
                                  Text(
                                    switch (query.sort) {
                                      QuestionSort.mostHelpful =>
                                        l10n.productSortHelpful,
                                      QuestionSort.newest =>
                                        l10n.productSortNewest,
                                    },
                                    style: text.labelLarge?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                  ProductIcon(
                                    Assets.iconsChevronDown,
                                    size: AppSizes.iconXs,
                                    color: context.colors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AnimatedSwitcher(
                          duration: context.motion(_swap),
                          child: Column(
                            key: ValueKey<QuestionQuery>(query),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppSpacing.md.h,
                            children: <Widget>[
                              if (page.questions.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.xl.h,
                                  ),
                                  child: Text(
                                    l10n.productNoQuestionsMatch,
                                    textAlign: TextAlign.center,
                                    style: text.bodyMedium?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              for (final question in page.questions)
                                QuestionCard(
                                  question: question,
                                  open: open.contains(question.id),
                                  onToggle: () => ref
                                      .read(
                                        openAnswersViewModelProvider(widget.id)
                                            .notifier,
                                      )
                                      .toggle(question.id),
                                  onAnswer: () => unawaited(
                                    _ask(page.product, answering: question),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        AskCard(onAsk: () => unawaited(_ask(page.product))),
                      ]
                      .expand(
                        (child) => <Widget>[
                          child,
                          SizedBox(height: AppSpacing.md.h),
                        ],
                      )
                      .toList()
                    ..removeLast(),
            ),
          ),
        ),
      ],
    );
  }
}
