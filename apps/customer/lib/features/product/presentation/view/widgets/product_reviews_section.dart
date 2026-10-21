import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/section_header.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/review_parts.dart';
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

  static const double _mention = 36;
  static const double _mentionOutline = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final decimal = FormatCache.decimal(locale);
    return ProductSection(
      spacing: 14,
      children: <Widget>[
        SectionHeader(
          title: l10n.productReviewsTitle,
          onSeeAll: () => onAllReviews(null),
        ),
        RatingSummary(
          rating: rating,
          ratingCount: ratingCount,
          shares: reviews.shares,
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
          ReviewCard(
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
