import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/category_tile.dart';
import 'package:core/presentation/widgets/dashed_border.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/presentation/widgets/product/product_card.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The store's coupons in a row that scrolls sideways.
class StoreCoupons extends StatelessWidget {
  const StoreCoupons({
    required this.coupons,
    required this.collected,
    required this.onCollect,
    super.key,
  });

  final List<StoreCoupon> coupons;

  /// Coupons collected on this page, by id.
  final Set<String> collected;
  final ValueChanged<StoreCoupon> onCollect;

  static const double _card = 236;
  static const double _radius = 10;
  static const double _actionRadius = 8;
  static const double _actionVertical = 6;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final ink = colors.onPrimaryContainer;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md.h,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: Semantics(
                header: true,
                child: Text(l10n.storeCoupons, style: text.titleMedium),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: Row(
                spacing: 10.w,
                children: <Widget>[
                  for (final coupon in coupons)
                    DashedBorder(
                      color: colors.primary,
                      radius: BorderRadius.circular(_radius.r),
                      child: Container(
                        width: _card.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: (AppSpacing.md + AppBorders.thin).w,
                          vertical: (AppSpacing.md + AppBorders.thin).h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(_radius.r),
                        ),
                        child: Row(
                          spacing: 10.w,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppSpacing.xxs.h,
                                children: <Widget>[
                                  Text(
                                    coupon.title,
                                    style: text.titleMedium?.copyWith(
                                      color: ink,
                                    ),
                                  ),
                                  Text(
                                    coupon.detail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall?.copyWith(color: ink),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: context.motion(_swap),
                              child:
                                  coupon.collected ||
                                      collected.contains(coupon.id)
                                  ? Padding(
                                      key: const ValueKey<bool>(true),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md.w,
                                        vertical: _actionVertical.h,
                                      ),
                                      child: Text(
                                        l10n.storeCollected,
                                        style: text.labelLarge?.copyWith(
                                          color: ink,
                                        ),
                                      ),
                                    )
                                  : FilledButton(
                                      key: const ValueKey<bool>(false),
                                      onPressed: () => onCollect(coupon),
                                      style: FilledButton.styleFrom(
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md.w,
                                          vertical: _actionVertical.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _actionRadius.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(l10n.storeCollect),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The store's categories as icon tiles.
class StoreCategories extends StatelessWidget {
  const StoreCategories({
    required this.categories,
    required this.onCategory,
    super.key,
  });

  final List<StoreCategory> categories;
  final ValueChanged<ShopCategory> onCategory;

  static const double _tile = 84;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerLowest,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg.w,
        vertical: AppSpacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.l10n.storeShopByCategory,
              style: context.textTheme.titleMedium,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (final category in categories)
                CategoryTile(
                  icon: category.category.icon,
                  label: category.label,
                  width: _tile,
                  onTap: () => onCategory(category.category),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Every product in the chosen order, two to a row with dividers.
class StoreProducts extends StatelessWidget {
  const StoreProducts({
    required this.products,
    required this.count,
    required this.sort,
    required this.onSort,
    required this.onProduct,
    super.key,
  });

  final List<Product> products;

  /// How many products the store sells.
  final int count;
  final StoreSort sort;
  final ValueChanged<StoreSort> onSort;
  final ValueChanged<String> onProduct;

  static const int _perRow = 2;
  static const double _grid = 361;
  static const double _bottom = 34;
  static const Duration _swap = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final divider = BorderSide(color: colors.outlineVariant);
    final rows = (products.length / _perRow).ceil();
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg.h, bottom: _bottom.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md.h,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: Row(
                spacing: AppSpacing.sm.w,
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.storeAllProducts,
                        style: text.titleMedium,
                      ),
                    ),
                  ),
                  Text(
                    l10n.storeItemCount(decimal.format(count)),
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilterChips(
              labels: <String>[
                l10n.storeSortPopular,
                l10n.storeSortNew,
                l10n.storeSortPriceLow,
                l10n.storeSortOnSale,
              ],
              selected: sort.index,
              onSelect: (index) => onSort(StoreSort.values[index]),
            ),
            AnimatedSwitcher(
              duration: context.motion(_swap),
              child: Padding(
                key: ValueKey<StoreSort>(sort),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Column(
                  children: <Widget>[
                    for (var row = 0; row < rows; row++)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: row < rows - 1 ? divider : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (var column = 0; column < _perRow; column++)
                              Expanded(
                                child: switch (row * _perRow + column) {
                                  final index when index < products.length =>
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: BorderDirectional(
                                          end: column == 0
                                              ? divider
                                              : BorderSide.none,
                                        ),
                                      ),
                                      child: ProductCard(
                                        product: products[index],
                                        width: _grid / _perRow,
                                        flat: true,
                                        onOpen: () =>
                                            onProduct(products[index].id),
                                      ),
                                    ),
                                  _ => const SizedBox.shrink(),
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
