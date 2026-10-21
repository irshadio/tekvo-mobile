import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/presentation/view/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Product cards two to a row.
class RecommendedGrid extends StatelessWidget {
  const RecommendedGrid({
    required this.products,
    required this.onProduct,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;

  static const int _perRow = 2;
  static const double _card = 175;
  static const double _rowGap = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.s6.h),
      child: Column(
        spacing: _rowGap.h,
        children: <Widget>[
          for (var start = 0; start < products.length; start += _perRow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (final product in products.skip(start).take(_perRow))
                  ProductCard(
                    product: product,
                    width: _card,
                    onOpen: () => onProduct(product.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
