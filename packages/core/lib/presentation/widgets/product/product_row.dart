import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_card.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Product cards in a row that scrolls sideways; a filter that keeps none
/// says so in the row's place.
class ProductRow extends StatelessWidget {
  const ProductRow({
    required this.products,
    required this.onProduct,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;

  static const double _card = 160;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductCard.heightOf(context),
      child: AnimatedSwitcher(
        duration: context.motion(_swap),
        child: products.isEmpty
            ? Center(
                key: const ValueKey<String>('none'),
                child: Text(
                  context.coreL10n.productNoneFound,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.separated(
                key: ValueKey<String>(products.map((p) => p.id).join()),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                itemCount: products.length,
                separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md.w),
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  width: _card,
                  onOpen: () => onProduct(products[index].id),
                ),
              ),
      ),
    );
  }
}
