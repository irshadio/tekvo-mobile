import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The score with its stars and count, beside how the ratings split.
class RatingSummary extends StatelessWidget {
  const RatingSummary({
    required this.rating,
    required this.ratingCount,
    required this.shares,
    super.key,
  });

  final double rating;
  final int ratingCount;

  /// The percentage of ratings with five stars, then four, down to one.
  final List<int> shares;

  static const double _score = 78;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final decimal = FormatCache.decimal(locale);
    final score = FormatCache.number('0.0', locale).format(rating);
    return Row(
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
              for (final (i, share) in shares.indexed)
                RatingBar(stars: shares.length - i, share: share),
            ],
          ),
        ),
      ],
    );
  }
}

/// How many ratings gave [stars], as a bar that fills when it appears.
class RatingBar extends StatelessWidget {
  const RatingBar({required this.stars, required this.share, super.key});

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

/// A buyer's review: who, when, stars, what they wrote and Helpful.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.review,
    required this.helpful,
    required this.onHelpful,
    this.outlined = true,
    super.key,
  });

  final Review review;
  final bool helpful;
  final VoidCallback onHelpful;

  /// Ringed on the product page; plain cards on the reviews screen.
  final bool outlined;

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
        border: outlined ? Border.all(color: colors.outlineVariant) : null,
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
              Semantics(
                label: l10n.productReviewStars(review.stars),
                child: ProductStars(filled: review.stars),
              ),
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
