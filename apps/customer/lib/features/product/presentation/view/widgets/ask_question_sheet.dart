import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/app_sheet.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view_model/post_question_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Asks the seller and buyers a question about a product, or answers
/// [questionId] when given; closes with true once posted.
class AskQuestionSheet extends ConsumerStatefulWidget {
  const AskQuestionSheet({
    required this.productId,
    required this.product,
    this.questionId,
    this.question,
    super.key,
  });

  final String productId;

  /// Such as `Nova X Pro 5G · 256 GB`, under the title.
  final String product;
  final String? questionId;

  /// The question being answered, shown under the title instead.
  final String? question;

  static Future<bool?> show(
    BuildContext context, {
    required String productId,
    required String product,
    String? questionId,
    String? question,
  }) => showAppSheet<bool>(
    context,
    builder: (_) => AskQuestionSheet(
      productId: productId,
      product: product,
      questionId: questionId,
      question: question,
    ),
  );

  @override
  ConsumerState<AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends ConsumerState<AskQuestionSheet> {
  static const int _max = 250;
  static const double _field = 112;
  static const double _fieldRadius = 10;
  static const double _fieldHorizontal = 14;
  static const double _focus = 1.5;
  static const double _close = 44;
  static const double _closeIcon = 22;
  static const double _checkbox = 22;
  static const double _tick = 16;
  static const double _bottom = 30;
  static const Duration _focusFade = Duration(milliseconds: 200);

  final TextEditingController _text = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _notify = ValueNotifier<bool>(true);

  bool get _answering => widget.questionId != null;

  PostQuestionViewModelProvider get _post =>
      postQuestionViewModelProvider(widget.productId);

  @override
  void dispose() {
    _text.dispose();
    _focusNode.dispose();
    _notify.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listenSubmission(
      _post,
      context,
      onSuccess: (_) => Navigator.of(context).pop(true),
    );
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final sending = ref.watch(_post).isInProgress;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        10.h,
        AppSpacing.lg.w,
        _bottom.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14.h,
          children: <Widget>[
            Center(
              child: Container(
                width: 36.w,
                height: AppSpacing.xs.h,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.xxs.h),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs.h,
                    children: <Widget>[
                      Semantics(
                        header: true,
                        child: Text(
                          _answering
                              ? l10n.productAnswerTitle
                              : l10n.productAskQuestion,
                          style: text.titleLarge,
                        ),
                      ),
                      Text(
                        widget.question ?? widget.product,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surfaceContainerHigh,
                    fixedSize: Size.square(_close.r),
                    minimumSize: Size.square(_close.r),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: SvgPicture.asset(
                    Assets.iconsClose,
                    width: _closeIcon.r,
                    height: _closeIcon.r,
                    colorFilter: ColorFilter.mode(
                      colors.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md.h,
              children: <Widget>[
                _input(context),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(_fieldRadius.r),
                  ),
                  child: Text(
                    l10n.productWhoAnswers,
                    style: text.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                if (!_answering)
                  ValueListenableBuilder<bool>(
                    valueListenable: _notify,
                    builder: (context, notify, _) => MergeSemantics(
                      child: Semantics(
                        checked: notify,
                        child: InkWell(
                          onTap: () => _notify.value = !notify,
                          child: Row(
                            spacing: 10.w,
                            children: <Widget>[
                              ProductCheckbox(
                                checked: notify,
                                size: _checkbox,
                                tick: _tick,
                              ),
                              Expanded(
                                child: Text(
                                  l10n.productNotifyMe,
                                  style: text.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ListenableBuilder(
              listenable: _text,
              builder: (context, _) => FilledButton(
                onPressed: _text.text.trim().isEmpty || sending
                    ? null
                    : () => unawaited(
                        ref
                            .read(_post.notifier)
                            .post(
                              _text.text,
                              questionId: widget.questionId,
                              notify: _notify.value,
                            ),
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                ),
                child: Text(
                  _answering
                      ? l10n.productPostAnswer
                      : l10n.productPostQuestion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final small = text.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s6.h,
      children: <Widget>[
        Text(
          _answering ? l10n.productYourAnswer : l10n.productYourQuestion,
          style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        ListenableBuilder(
          listenable: _focusNode,
          builder: (context, _) => AnimatedContainer(
            duration: context.motion(_focusFade),
            height: _field.h,
            padding: EdgeInsets.symmetric(
              horizontal: _fieldHorizontal.w,
              vertical: AppSpacing.md.h,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(_fieldRadius.r),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colors.primary
                    : colors.outlineVariant,
                width: _focus,
              ),
            ),
            child: TextField(
              controller: _text,
              focusNode: _focusNode,
              autofocus: true,
              maxLength: _max,
              maxLines: null,
              expands: true,
              textCapitalization: TextCapitalization.sentences,
              style: text.bodyLarge,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: _answering
                    ? l10n.productAnswerHint
                    : l10n.productQuestionHint,
                hintStyle: text.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            Expanded(
              child: Text(
                _answering
                    ? l10n.productAnswerPublic
                    : l10n.productQuestionPublic,
                style: small,
              ),
            ),
            ListenableBuilder(
              listenable: _text,
              builder: (context, _) => Text(
                l10n.productTextCounter(_text.text.length, _max),
                style: small,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
