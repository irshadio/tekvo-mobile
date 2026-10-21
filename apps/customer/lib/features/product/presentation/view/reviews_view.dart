import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/presentation/widgets/choice_sheet.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_page_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/review_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/reviews_page_parts.dart';
import 'package:customer/features/product/presentation/view_model/product_choices_view_model.dart';
import 'package:customer/features/product/presentation/view_model/review_query_view_model.dart';
import 'package:customer/features/product/presentation/view_model/reviews_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// What [ReviewsView] opens on: the product, and the filter to start with.
typedef ReviewsRequest = ({String id, ReviewFilter filter});

/// Every review of a product: the summary, what buyers say, their photos,
/// and the reviews themselves, filtered and sorted.
class ReviewsView extends ConsumerStatefulWidget {
  const ReviewsView({
    required this.id,
    this.filter = ReviewFilter.all,
    super.key,
  });

  final String id;
  final ReviewFilter filter;

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView>
    with ViewReadyMixin<ReviewsView> {
  static const double _bottom = 24;
  static const Duration _swap = Duration(milliseconds: 250);

  ReviewsViewModelProvider get _reviews => reviewsViewModelProvider(widget.id);
  ReviewQueryViewModelProvider get _query =>
      reviewQueryViewModelProvider(widget.id);

  @override
  void onReady() {
    if (widget.filter == ReviewFilter.all) {
      _load();
    } else {
      ref.read(_query.notifier).filter(widget.filter);
    }
  }

  void _load() => unawaited(ref.read(_reviews.notifier).load());

  Future<void> _chooseSort(ReviewSort current) async {
    final chosen = await ChoiceSheet.show(
      context,
      title: context.l10n.productSortTitle,
      options: <String>[for (final sort in ReviewSort.values) _sortLabel(sort)],
      selected: current.index,
    );
    if (chosen != null && mounted) {
      ref.read(_query.notifier).sort(ReviewSort.values[chosen]);
    }
  }

  String _sortLabel(ReviewSort sort) {
    final l10n = context.l10n;
    return switch (sort) {
      ReviewSort.mostHelpful => l10n.productSortHelpful,
      ReviewSort.newest => l10n.productSortNewest,
      ReviewSort.highest => l10n.productSortHighest,
      ReviewSort.lowest => l10n.productSortLowest,
    };
  }

  List<String> _filterLabels(ReviewsPage page) {
    final l10n = context.l10n;
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return <String>[
      for (final filter in ReviewFilter.values)
        switch (filter) {
          ReviewFilter.all => l10n.productReviewFilterAll(
            decimal.format(page.ratingCount),
          ),
          ReviewFilter.withPhotos => l10n.productReviewFilterPhotos(
            decimal.format(page.withPhotos),
          ),
          ReviewFilter.fiveStars => l10n.productReviewFilterStars(5),
          ReviewFilter.fourStars => l10n.productReviewFilterStars(4),
          ReviewFilter.threeAndBelow => l10n.productReviewFilterLow,
          ReviewFilter.verified => l10n.productReviewFilterVerified,
        },
    ];
  }

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_reviews, context);
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: ViewStateSwitcher<ReviewsPage>(
          state: ref.watch(_reviews),
          onRetry: _load,
          onData: _page,
        ),
      ),
    );
  }

  Widget _page(ReviewsPage page) {
    final l10n = context.l10n;
    final query = ref.watch(_query);
    final loading = ref.watch(_reviews) is ViewLoading<ReviewsPage>;
    final helpful = ref.watch(
      productChoicesViewModelProvider(widget.id).select((c) => c.helpful),
    );
    final choices = ref.read(
      productChoicesViewModelProvider(widget.id).notifier,
    );
    return Column(
      children: <Widget>[
        ProductPageBar(
          title: l10n.productReviewsTitle,
          subtitle: page.product,
          bottomGap: 0,
          bottom: FilterChips(
            labels: _filterLabels(page),
            selected: query.filter.index,
            onSelect: (index) =>
                ref.read(_query.notifier).filter(ReviewFilter.values[index]),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.md.h,
                AppSpacing.lg.w,
                _bottom.h + context.viewPadding.bottom,
              ),
              children: <Widget>[
                ReviewsSummaryCard(
                  page: page,
                  onWrite: () => unawaited(
                    context.pushNamed<void>(
                      Routes.writeReview,
                      arguments: widget.id,
                    ),
                  ),
                ),
                ReviewTopicsCard(page: page),
                ReviewPhotosCard(
                  page: page,
                  onSeeAll: () =>
                      ref.read(_query.notifier).filter(ReviewFilter.withPhotos),
                ),
                ReviewListHead(
                  count: page.matching,
                  sort: _sortLabel(query.sort),
                  onSort: () => unawaited(_chooseSort(query.sort)),
                ),
                AnimatedSwitcher(
                  duration: context.motion(_swap),
                  child: Column(
                    key: ValueKey<(ReviewFilter, ReviewSort)>((
                      query.filter,
                      query.sort,
                    )),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md.h,
                    children: <Widget>[
                      if (page.reviews.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xl.h,
                          ),
                          child: Text(
                            l10n.productNoReviewsMatch,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      for (final review in page.reviews) ...<Widget>[
                        ReviewCard(
                          review: review,
                          outlined: false,
                          helpful: helpful.contains(review.id),
                          onHelpful: () => choices.toggleHelpful(review.id),
                        ),
                        if (review.reply case final reply?)
                          SellerReplyCard(reply: reply),
                      ],
                    ],
                  ),
                ),
                if (page.hasMore)
                  ProductOutlineButton(
                    label: l10n.productMoreReviews,
                    onPressed: loading ? null : ref.read(_query.notifier).more,
                  ),
              ].expand(_spaced).toList()..removeLast(),
            ),
          ),
        ),
      ],
    );
  }

  Iterable<Widget> _spaced(Widget child) => <Widget>[
    child,
    SizedBox(height: AppSpacing.md.h),
  ];
}
