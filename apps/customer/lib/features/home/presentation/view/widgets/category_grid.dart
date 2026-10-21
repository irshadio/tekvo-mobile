import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/shop_category.dart';
import 'package:customer/features/home/presentation/view/widgets/category_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Every category as an icon tile, four to a row.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({required this.onCategory, super.key});

  final ValueChanged<ShopCategory> onCategory;

  static const int _perRow = 4;

  @override
  Widget build(BuildContext context) {
    const categories = ShopCategory.values;
    return Column(
      spacing: AppSpacing.lg.h,
      children: <Widget>[
        for (var start = 0; start < categories.length; start += _perRow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (final category in categories.skip(start).take(_perRow))
                _CategoryTile(
                  category: category,
                  onTap: () => onCategory(category),
                ),
            ],
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final ShopCategory category;
  final VoidCallback onTap;

  static const double _width = 72;
  static const double _tile = 60;
  static const double _icon = 26;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: _width.w,
          child: Column(
            spacing: AppSpacing.sm.h,
            children: <Widget>[
              Container(
                width: _tile.r,
                height: _tile.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: radius,
                ),
                child: SvgPicture.asset(
                  categoryIcon(category),
                  width: _icon.r,
                  height: _icon.r,
                  colorFilter: ColorFilter.mode(
                    colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Text(
                categoryLabel(context, category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [category]'s icon.
String categoryIcon(ShopCategory category) => switch (category) {
  ShopCategory.phones => Assets.iconsPhone,
  ShopCategory.laptops => Assets.iconsLaptop,
  ShopCategory.audio => Assets.iconsHeadphones,
  ShopCategory.watches => Assets.iconsWatch,
  ShopCategory.cameras => Assets.iconsCamera,
  ShopCategory.gaming => Assets.iconsGamepad,
  ShopCategory.tvs => Assets.iconsTv,
  ShopCategory.speakers => Assets.iconsSpeaker,
};
