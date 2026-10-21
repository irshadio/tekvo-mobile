import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The purchase being reviewed.
class ReviewProductCard extends StatelessWidget {
  const ReviewProductCard({required this.form, super.key});

  final ReviewForm form;

  static const double _photo = 52;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        spacing: AppSpacing.md.w,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
            child: ColoredBox(
              color: context.appColors.commerceProductBg,
              child: Image.asset(
                form.image,
                width: _photo.r,
                height: _photo.r,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs.h,
              children: <Widget>[
                Text(form.name, style: text.titleSmall),
                Text(
                  form.purchase,
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

/// Five big stars to tap, and the word for the chosen rating.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    required this.stars,
    required this.onRate,
    super.key,
  });

  final int stars;
  final ValueChanged<int> onRate;

  static const double _star = 40;
  static const int _count = 5;
  static const double _pop = 1.15;
  static const Duration _bounce = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final rating = context.appColors.commerceRating;
    final l10n = context.l10n;
    return Column(
      spacing: 10.h,
      children: <Widget>[
        Text(l10n.productRateQuestion, style: text.titleMedium),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.w,
          children: <Widget>[
            for (var i = 1; i <= _count; i++)
              Semantics(
                button: true,
                selected: i == stars,
                label: l10n.productRateStars(i),
                excludeSemantics: true,
                child: InkResponse(
                  onTap: () => onRate(i),
                  radius: _star.r / 2 + AppSpacing.xs.r,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<bool>(i <= stars),
                    tween: Tween<double>(begin: i <= stars ? _pop : 1, end: 1),
                    duration: context.motion(_bounce),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: ProductIcon(
                      i <= stars ? Assets.iconsStarFilled : Assets.iconsStar,
                      size: _star,
                      color: i <= stars ? rating : colors.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
        AnimatedOpacity(
          opacity: stars > 0 ? 1 : 0,
          duration: context.motion(_bounce),
          child: Text(
            l10n.productRatingWord('${stars.clamp(1, _count)}'),
            style: text.titleSmall?.copyWith(color: rating),
          ),
        ),
      ],
    );
  }
}

/// What the buyer liked, any number of them.
class LikeChips extends StatelessWidget {
  const LikeChips({
    required this.likes,
    required this.liked,
    required this.onToggle,
    super.key,
  });

  final List<String> likes;
  final Set<String> liked;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10.h,
    children: <Widget>[
      Text(
        context.l10n.productLikedQuestion,
        style: context.textTheme.titleSmall,
      ),
      Wrap(
        spacing: AppSpacing.sm.w,
        runSpacing: AppSpacing.sm.h,
        children: <Widget>[
          for (final like in likes)
            AppChip(
              label: like,
              selected: liked.contains(like),
              onTap: () => onToggle(like),
            ),
        ],
      ),
    ],
  );
}

/// Whether the review shows the buyer's name, with the name it shows.
class ShowNameRow extends StatelessWidget {
  const ShowNameRow({
    required this.author,
    required this.show,
    required this.onChanged,
    super.key,
  });

  final String author;
  final bool show;
  final ValueChanged<bool> onChanged;

  static const double _tile = 36;
  static const double _tileRadius = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!show),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
          child: Row(
            spacing: AppSpacing.md.w,
            children: <Widget>[
              Container(
                width: _tile.r,
                height: _tile.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(_tileRadius.r),
                ),
                child: ProductIcon(
                  Assets.iconsUser,
                  size: AppSizes.iconSm,
                  color: colors.onSurface,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs.h,
                  children: <Widget>[
                    Text(l10n.productShowName, style: text.bodyLarge),
                    Text(
                      show
                          ? l10n.productPostedAs(author)
                          : l10n.productPostedAnonymously,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: show,
                onChanged: onChanged,
                activeTrackColor: colors.primary,
                activeThumbColor: colors.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The reward the review earns.
class ReviewRewardNote extends StatelessWidget {
  const ReviewRewardNote({required this.points, super.key});

  final int points;

  static const double _icon = 18;
  static const double _horizontal = 14;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontal.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(_radius.r),
      ),
      child: Row(
        spacing: 10.w,
        children: <Widget>[
          ProductIcon(
            Assets.iconsGift,
            size: _icon,
            color: colors.onPrimaryContainer,
          ),
          Expanded(
            child: Text(
              context.l10n.productReviewReward(points),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
