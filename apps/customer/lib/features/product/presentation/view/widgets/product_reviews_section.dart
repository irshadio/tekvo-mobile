import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/section_header.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The score with how the ratings split, topics reviews mention, the top
/// reviews and a way to read the rest.
class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    required this.reviews,
    required this.rating,
    required this.ratingCount,
    required this.helpful,
    required this.onToggleHelpful,
    required this.onAllReviews,
    super.key,
  });

  final Reviews reviews;
  final double rating;
  final int ratingCount;

  /// The reviews the user found helpful, by id.
  final Set<String> helpful;
  final ValueChanged<String> onToggleHelpful;

  /// Opens every review; a topic narrows them to it.
  final ValueChanged<ReviewMention?> onAllReviews;

  static const double _score = 78;
  static const double _mention = 36;
  static const double _mentionOutline = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final decimal = FormatCache.decimal(locale);
    final score = FormatCache.number('0.0', locale).format(rating);
    return ProductSection(
      spacing: 14,
      children: <Widget>[
        SectionHeader(
          title: l10n.productReviewsTitle,
          onSeeAll: () => onAllReviews(null),
        ),
        Row(
          spacing: AppSpacing.s20.w,
          children: <Widget>[
            Semantics(
              label: context.coreL10n.productRating(score, ratingCount),
              excludeSemantics: true,
              child: SizedBox(
                width: _score.w,
                child: Column(
                  spacing: AppSpacing.xs.h,
                  children: <Widget>[
                    Text(score, style: text.displaySmall),
                    ProductStars(filled: rating.round()),
                    Text(
                      l10n.productRatingsCount(decimal.format(ratingCount)),
                      maxLines: 1,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                spacing: AppSpacing.s6.h,
                children: <Widget>[
                  for (final (i, share) in reviews.shares.indexed)
                    _RatingBar(stars: reviews.shares.length - i, share: share),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: _mention.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.mentions.length,
            separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
            itemBuilder: (context, index) {
              final mention = reviews.mentions[index];
              return OutlinedButton(
                onPressed: () => onAllReviews(mention),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, _mention.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                  foregroundColor: colors.onSurface,
                  backgroundColor: colors.surfaceContainerLowest,
                  textStyle: text.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.s6.r),
                  ),
                  side: BorderSide(
                    color: colors.outlineVariant,
                    width: _mentionOutline,
                  ),
                ),
                child: Text(
                  l10n.productMention(
                    mention.label,
                    decimal.format(mention.count),
                  ),
                ),
              );
            },
          ),
        ),
        for (final review in reviews.top)
          _ReviewCard(
            review: review,
            helpful: helpful.contains(review.id),
            onHelpful: () => onToggleHelpful(review.id),
          ),
        ProductOutlineButton(
          label: l10n.productReadAllReviews(decimal.format(reviews.total)),
          onPressed: () => onAllReviews(null),
        ),
      ],
    );
  }
}

/// How many ratings gave [stars], as a bar that fills when it appears.
class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.stars, required this.share});

  final int stars;
  final int share;

  static const double _label = 8;
  static const double _percent = 30;
  static const double _track = 6;
  static const Duration _fill = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textTheme.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final radius = BorderRadius.circular(_track.h / 2);
    return Semantics(
      label: context.l10n.productRatingShare(stars, share),
      excludeSemantics: true,
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          SizedBox(
            width: _label.w,
            child: Text('$stars', style: style),
          ),
          Expanded(
            child: Container(
              height: _track.h,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: radius,
              ),
              alignment: AlignmentDirectional.centerStart,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: share / 100),
                duration: context.motion(_fill),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.appColors.commerceRating,
                      borderRadius: radius,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: _percent.w,
            child: Text(
              context.l10n.productPercent(share),
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.helpful,
    required this.onHelpful,
  });

  final Review review;
  final bool helpful;
  final VoidCallback onHelpful;

  static const double _padding = 14;
  static const double _avatar = 36;
  static const double _check = 12;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final variant = text.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _padding.w,
        vertical: _padding.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.h,
        children: <Widget>[
          Row(
            spacing: 10.w,
            children: <Widget>[
              Container(
                width: _avatar.r,
                height: _avatar.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: ExcludeSemantics(
                  child: Text(
                    review.initials,
                    style: text.labelLarge?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 1.h,
                  children: <Widget>[
                    Text(review.author, style: text.titleSmall),
                    Row(
                      spacing: AppSpacing.xs.w,
                      children: <Widget>[
                        ProductIcon(
                          Assets.iconsCheck,
                          size: _check,
                          color: colors.primary,
                        ),
                        Flexible(
                          child: Text(
                            l10n.productVerifiedPurchase(review.variant),
                            style: variant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                FormatCache.date('d MMM', locale).format(review.date),
                style: variant,
              ),
            ],
          ),
          Row(
            spacing: AppSpacing.sm.w,
            children: <Widget>[
              ProductStars(filled: review.stars),
              Expanded(child: Text(review.headline, style: text.titleSmall)),
            ],
          ),
          Text(review.body, style: text.bodyMedium),
          _HelpfulButton(
            count: review.helpful,
            marked: helpful,
            onPressed: onHelpful,
          ),
        ],
      ),
    );
  }
}

/// Marks a review helpful, counting the user in once marked.
class _HelpfulButton extends StatelessWidget {
  const _HelpfulButton({
    required this.count,
    required this.marked,
    required this.onPressed,
  });

  final int count;
  final bool marked;
  final VoidCallback onPressed;

  static const double _vertical = 5;
  static const Duration _swap = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppSpacing.s6.r);
    return Semantics(
      button: true,
      toggled: marked,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: context.motion(_swap),
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: _vertical.h,
            ),
            decoration: BoxDecoration(
              color: marked ? colors.primaryContainer : null,
              borderRadius: radius,
              border: Border.all(
                color: marked ? colors.primary : colors.outlineVariant,
              ),
            ),
            child: Text(
              context.l10n.productHelpful(count + (marked ? 1 : 0)),
              style: context.textTheme.labelMedium?.copyWith(
                color: marked
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
