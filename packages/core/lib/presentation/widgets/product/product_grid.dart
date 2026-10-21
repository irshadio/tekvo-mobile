import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_card.dart';
import 'package:flutter/material.dart';

/// Products two to a row on square cards with dividers between them.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    required this.onProduct,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;

  static const int _perRow = 2;
  static const double _width = 361;

  @override
  Widget build(BuildContext context) {
    final divider = BorderSide(color: context.colors.outlineVariant);
    final rows = (products.length / _perRow).ceil();
    return Column(
      children: <Widget>[
        for (var row = 0; row < rows; row++)
          // A container leaves room for its border, as the design does.
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
                      final index when index < products.length => DecoratedBox(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            end: column == 0 ? divider : BorderSide.none,
                          ),
                        ),
                        child: ProductCard(
                          product: products[index],
                          width: _width / _perRow,
                          flat: true,
                          onOpen: () => onProduct(products[index].id),
                        ),
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
