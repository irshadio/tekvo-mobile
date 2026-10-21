import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/presentation/widgets/dashed_border.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The product's store, name, rating, price and ways to pay less.
class ProductInfo extends StatelessWidget {
  const ProductInfo({
    required this.product,
    required this.couponApplied,
    required this.onStore,
    required this.onApplyCoupon,
    super.key,
  });

  final ProductDetails product;
  final bool couponApplied;
  final VoidCallback onStore;
  final VoidCallback onApplyCoupon;

  static const double _star = 16;
  static const double _starGap = 2;
  static const int _stars = 5;
  static const double _dot = 3;
  static const double _shield = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.appColors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final variant = colors.onSurfaceVariant;
    final was = product.was;
    final saving = product.saving;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          AppSpacing.xs.h,
          AppSpacing.lg.w,
          AppSpacing.lg.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.h,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: AppSpacing.s6.w,
              children: <Widget>[
                Flexible(
                  child: InkWell(
                    onTap: onStore,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.xxs.w,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            l10n.productVisitStore(product.store),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelLarge?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        _icon(
                          context,
                          Assets.iconsChevronRight,
                          AppSizes.iconXs,
                          colors.primary,
                          flip: true,
                        ),
                      ],
                    ),
                  ),
                ),
                if (product.officialStore)
                  InkWell(
                    onTap: onStore,
                    borderRadius: BorderRadius.circular(AppRadius.xs.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.xs.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppSpacing.xs.w,
                        children: <Widget>[
                          _icon(
                            context,
                            Assets.iconsShield,
                            _shield,
                            colors.onPrimaryContainer,
                          ),
                          Text(
                            l10n.productOfficialStore,
                            style: text.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Semantics(
              header: true,
              child: Text(product.title, style: text.titleLarge),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                Semantics(
                  label: context.coreL10n.productRating(
                    FormatCache.number('0.0', locale).format(product.rating),
                    product.ratingCount,
                  ),
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.xs.w,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: _starGap.w,
                        children: <Widget>[
                          for (var i = 0; i < _stars; i++)
                            _icon(
                              context,
                              Assets.iconsStarFilled,
                              _star,
                              i < product.rating.round()
                                  ? app.commerceRating
                                  : colors.outlineVariant,
                            ),
                        ],
                      ),
                      Text(
                        FormatCache.number(
                          '0.0',
                          locale,
                        ).format(product.rating),
                        style: text.labelMedium,
                      ),
                      Text(
                        l10n.productRatingTotal(
                          FormatCache.decimal(locale).format(
                            product.ratingCount,
                          ),
                        ),
                        style: text.bodySmall?.copyWith(color: variant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _dot,
                  height: _dot,
                  decoration: BoxDecoration(
                    color: colors.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  l10n.productSoldThisWeek(
                    _thousands(context, product.soldThisWeek),
                  ),
                  style: text.bodySmall?.copyWith(color: variant),
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: AppSpacing.s6.w,
                  children: <Widget>[
                    Text(
                      context.money(product.price),
                      style: text.headlineSmall?.bold.copyWith(
                        color: app.commercePrice,
                      ),
                    ),
                    if (was != null)
                      Flexible(
                        child: Text(
                          context.money(was),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: app.commercePriceStrike,
                          ),
                        ),
                      ),
                  ],
                ),
                if (saving != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                    child: Text(
                      l10n.productSaving(context.money(saving)),
                      style: text.labelLarge?.copyWith(
                        color: app.commerceSale,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              l10n.productVatIncluded,
              style: text.bodySmall?.copyWith(color: variant),
            ),
            if (product.instalments case final plan?)
              _box(
                context,
                color: colors.surfaceContainer,
                icon: Assets.iconsCard,
                iconColor: colors.onSurface,
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: l10n.productInstalments(plan.count)),
                      TextSpan(
                        text: context.money(plan.amount),
                        style: text.bodySmall?.emphasized,
                      ),
                    ],
                  ),
                  style: text.bodySmall,
                ),
              ),
            if (product.coupon case final coupon?)
              DashedBorder(
                color: colors.primary,
                radius: BorderRadius.circular(AppRadius.sm.r),
                child: _box(
                  context,
                  color: colors.primaryContainer,
                  icon: Assets.iconsTag,
                  iconColor: colors.onPrimaryContainer,
                  vertical: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 1.h,
                    children: <Widget>[
                      Text(
                        coupon.title,
                        style: text.titleSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        coupon.detail,
                        style: text.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  action: TextButton(
                    onPressed: couponApplied ? null : onApplyCoupon,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      textStyle: text.labelLarge,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      couponApplied
                          ? l10n.productCouponApplied
                          : l10n.productCouponApply,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// `1.2k` for 1,200; smaller counts as they are.
  static String _thousands(BuildContext context, int count) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    const thousand = 1000;
    return count < thousand
        ? FormatCache.decimal(locale).format(count)
        : context.coreL10n.productThousands(
            FormatCache.number('0.#', locale).format(count / thousand),
          );
  }

  static Widget _box(
    BuildContext context, {
    required Color color,
    required String icon,
    required Color iconColor,
    required Widget child,
    Widget? action,
    double vertical = 10,
  }) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md.w + (vertical == 10 ? 0 : 1),
      vertical: vertical.h,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.sm.r),
    ),
    child: Row(
      spacing: 10.w,
      children: <Widget>[
        _icon(context, icon, AppSizes.iconSm, iconColor),
        Expanded(child: child),
        ?action,
      ],
    ),
  );

  static Widget _icon(
    BuildContext context,
    String asset,
    double size,
    Color color, {
    bool flip = false,
  }) => Transform.flip(
    flipX: flip && Directionality.of(context) == TextDirection.rtl,
    child: SvgPicture.asset(
      asset,
      width: size.r,
      height: size.r,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}
