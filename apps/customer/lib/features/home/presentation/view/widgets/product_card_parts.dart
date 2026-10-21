import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The label on a product photo, coloured by its kind.
class ProductTagChip extends StatelessWidget {
  const ProductTagChip({required this.tag, super.key});

  final ProductTag tag;

  static const double _height = 22;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final colors = context.appColors;
    final l10n = context.l10n;
    final (label, background, foreground) = switch (tag) {
      SaleTag(:final percent) => (
        l10n.productDiscount(percent),
        colors.commerceSale,
        colors.commerceOnSale,
      ),
      NewTag() => (l10n.productNew, colors.commerceDeal, colors.commerceOnDeal),
      BestsellerTag() => (
        l10n.productBestseller,
        scheme.inverseSurface,
        scheme.onInverseSurface,
      ),
      LowStockTag(:final left) => (
        l10n.productLowStock(left),
        colors.statusWarningContainer,
        colors.statusOnWarningContainer,
      ),
      FreeDeliveryTag() => (
        l10n.productFreeDelivery,
        colors.statusSuccessContainer,
        colors.statusOnSuccessContainer,
      ),
    };
    return Container(
      height: _height.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xs.r),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.bold.copyWith(color: foreground),
      ),
    );
  }
}

/// A star, the score and how many rated it: `4.8 (3.2k)`.
class RatingLine extends StatelessWidget {
  const RatingLine({required this.rating, required this.count, super.key});

  final double rating;
  final int count;

  static const double _star = 14;
  static const int _thousand = 1000;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final score = FormatCache.number('0.0', locale).format(rating);
    final ratings = count < _thousand
        ? FormatCache.decimal(locale).format(count)
        : context.l10n.productThousands(
            FormatCache.number('0.0', locale).format(count / _thousand),
          );
    return Semantics(
      label: context.l10n.productRating(score, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs.w,
        children: <Widget>[
          SvgPicture.asset(
            Assets.iconsStarFilled,
            width: _star.r,
            height: _star.r,
            colorFilter: ColorFilter.mode(
              context.appColors.commerceRating,
              BlendMode.srcIn,
            ),
          ),
          Text(score, style: text.labelMedium),
          Text(
            context.l10n.productRatingCount(ratings),
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The price, red when on sale with the old price under it.
class PriceBlock extends StatelessWidget {
  const PriceBlock({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.textTheme;
    final was = product.was;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.money(product.price),
          style: text.titleMedium?.bold.copyWith(
            color: product.onSale ? colors.commerceSale : colors.commercePrice,
          ),
        ),
        if (was != null)
          Text(
            context.money(was),
            style: text.bodySmall?.copyWith(color: colors.commercePriceStrike),
          ),
      ],
    );
  }
}

/// Adds the product to the cart; once added it shows a check that opens
/// the cart.
class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    required this.added,
    required this.onAdd,
    this.onOpenCart,
    super.key,
  });

  final bool added;
  final VoidCallback onAdd;

  /// What the check does; without it the check does nothing.
  final VoidCallback? onOpenCart;

  static const double _size = 36;
  static const Duration _morph = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: added ? l10n.productInCart : l10n.productAdd,
      excludeSemantics: true,
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: added ? onOpenCart : onAdd,
          child: SizedBox.square(
            dimension: _size.r,
            child: AnimatedSwitcher(
              duration: context.motion(_morph),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: SvgPicture.asset(
                added ? Assets.iconsCheck : Assets.iconsPlus,
                key: ValueKey<bool>(added),
                width: AppSizes.iconSm.r,
                height: AppSizes.iconSm.r,
                colorFilter: ColorFilter.mode(
                  colors.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
