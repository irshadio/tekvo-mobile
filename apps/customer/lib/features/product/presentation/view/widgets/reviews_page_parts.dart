import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_promo_colors.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/review_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A white rounded card on the reviews screen.
class ReviewsCard extends StatelessWidget {
  const ReviewsCard({required this.spacing, required this.children, super.key});

  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.lg.w,
      vertical: AppSpacing.lg.h,
    ),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.h,
      children: children,
    ),
  );
}

/// The ratings and the way to write a review.
class ReviewsSummaryCard extends StatelessWidget {
  const ReviewsSummaryCard({
    required this.page,
    required this.onWrite,
    super.key,
  });

  final ReviewsPage page;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) => ReviewsCard(
    spacing: 14,
    children: <Widget>[
      RatingSummary(
        rating: page.rating,
        ratingCount: page.ratingCount,
        shares: page.shares,
      ),
      ProductOutlineButton(
        label: context.l10n.productWriteReview,
        icon: Assets.iconsEdit,
        onPressed: onWrite,
      ),
    ],
  );
}

/// What buyers praise and complain about, as tags.
class ReviewTopicsCard extends StatelessWidget {
  const ReviewTopicsCard({required this.page, super.key});

  final ReviewsPage page;

  static const double _icon = 14;
  static const double _vertical = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return ReviewsCard(
      spacing: 10,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(l10n.productWhatBuyersSay, style: text.titleMedium),
        ),
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: <Widget>[
            for (final topic in page.topics)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: _vertical.h,
                ),
                decoration: BoxDecoration(
                  color: topic.positive
                      ? colors.primaryContainer
                      : colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.s6.w,
                  children: <Widget>[
                    ProductIcon(
                      topic.positive ? Assets.iconsCheck : Assets.iconsClose,
                      size: _icon,
                      color: topic.positive
                          ? colors.onPrimaryContainer
                          : colors.onErrorContainer,
                    ),
                    Text(
                      l10n.productMention(
                        topic.label,
                        decimal.format(topic.count),
                      ),
                      style: text.labelMedium?.copyWith(
                        color: topic.positive
                            ? colors.onPrimaryContainer
                            : colors.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Text(
          l10n.productTopicsNote(decimal.format(page.ratingCount)),
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// A strip of buyers' photos, the last one counting the rest.
class ReviewPhotosCard extends StatelessWidget {
  const ReviewPhotosCard({
    required this.page,
    required this.onSeeAll,
    super.key,
  });

  final ReviewsPage page;
  final VoidCallback onSeeAll;

  static const double _photo = 64;
  static const double _gap = 6;
  static const double _scrim = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final rest = page.photoCount - page.photos.length;
    return ReviewsCard(
      spacing: 10,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.productCustomerPhotos,
                  style: text.titleMedium,
                ),
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
              child: Text(
                l10n.productSeeAllCount(page.photoCount),
                style: text.labelLarge?.copyWith(color: colors.primary),
              ),
            ),
          ],
        ),
        Row(
          spacing: _gap.w,
          children: <Widget>[
            for (final (i, photo) in page.photos.indexed)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  child: SizedBox(
                    height: _photo.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ColoredBox(
                          color: context.appColors.commerceProductBg,
                          child: Image.asset(
                            photo,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                        if (i == page.photos.length - 1 &&
                            rest > 0) ...<Widget>[
                          ColoredBox(
                            color: colors.scrim.withValues(alpha: _scrim),
                          ),
                          Semantics(
                            label: l10n.productMorePhotos(rest),
                            excludeSemantics: true,
                            child: Center(
                              child: Text(
                                '+$rest',
                                style: text.titleSmall?.copyWith(
                                  color: AppPromoColors.onNight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The store's answer under a review.
class SellerReplyCard extends StatelessWidget {
  const SellerReplyCard({required this.reply, super.key});

  final SellerReply reply;

  static const double _icon = 18;
  static const double _horizontal = 14;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontal.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(_radius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.w,
        children: <Widget>[
          ProductIcon(Assets.iconsChat, size: _icon, color: colors.primary),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs.h,
              children: <Widget>[
                Text(
                  context.l10n.productSellerReply(reply.store),
                  style: text.labelLarge,
                ),
                Text(
                  reply.text,
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// How many reviews match, and the sort that orders them.
class ReviewListHead extends StatelessWidget {
  const ReviewListHead({
    required this.count,
    required this.sort,
    required this.onSort,
    super.key,
  });

  final int count;
  final String sort;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs.h),
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                context.l10n.productReviewsCount(decimal.format(count)),
                style: text.titleMedium,
              ),
            ),
          ),
          InkWell(
            onTap: onSort,
            borderRadius: BorderRadius.circular(AppRadius.xs.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs.w,
              children: <Widget>[
                Text(sort, style: text.labelLarge),
                ProductIcon(
                  Assets.iconsChevronDown,
                  size: AppSizes.iconXs,
                  color: context.colors.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
