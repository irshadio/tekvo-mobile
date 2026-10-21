import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/widgets/category_tile.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/presentation/view/widgets/category_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                CategoryTile(
                  icon: category.icon,
                  label: categoryLabel(context, category),
                  onTap: () => onCategory(category),
                ),
            ],
          ),
      ],
    );
  }
}
