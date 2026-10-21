import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:core/presentation/widgets/product/cart_shortcut.dart';
import 'package:core/presentation/widgets/product/product_card_parts.dart';
import 'package:core/presentation/widgets/product/wishlist_heart_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A product: photo with its tag and a wishlist heart, rating, name, price
/// and an Add button. Tapping the card opens the product.
class ProductCard extends ConsumerWidget {
  const ProductCard({
    required this.product,
    required this.width,
    required this.onOpen,
    this.flat = false,
    super.key,
  });

  final Product product;
  final double width;
  final VoidCallback onOpen;

  /// Square, as in a grid with dividers.
  final bool flat;

  /// The card's height: the photo and gaps in design pixels, and the words
  /// as tall as their text at the user's text size.
  static double heightOf(BuildContext context) =>
      _photo.h +
      _inset.h +
      context.textBox(16, size: 12) +
      AppSpacing.xs.h +
      _nameHeight(context) +
      AppSpacing.xs.h +
      _priceHeight(context) +
      _bottom.h;

  static double _nameHeight(BuildContext context) =>
      context.textBox(_nameLines * 20, size: 14);

  /// The price over the old price.
  static double _priceHeight(BuildContext context) =>
      context.textBox(24, size: 16) + context.textBox(16, size: 12);

  static const int _nameLines = 2;
  static const double _bottom = 12;

  static const double _photo = 174;
  static const double _radius = 12;
  static const double _inset = 10;
  static const double _tintOpacity = 0.05;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final saved = ref.watch(
      wishlistViewModelProvider.select((ids) => ids.contains(product.id)),
    );
    final added = ref.watch(
      cartViewModelProvider.select((cart) => cart.added.contains(product.id)),
    );
    final l10n = context.coreL10n;
    final radius = BorderRadius.circular(flat ? 0 : _radius.r);
    return SizedBox(
      width: width.w,
      height: heightOf(context),
      child: Material(
        color: colors.onSurface.withValues(alpha: _tintOpacity),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _inset.h,
            children: <Widget>[
              SizedBox(
                height: _photo.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ColoredBox(
                      color: context.appColors.commerceProductBg,
                      child: Image.asset(product.image, fit: BoxFit.cover),
                    ),
                    if (product.tag case final tag?)
                      PositionedDirectional(
                        start: _inset.w,
                        top: _inset.h,
                        child: ProductTagChip(tag: tag),
                      ),
                    PositionedDirectional(
                      end: _inset.w,
                      top: _inset.h,
                      child: WishlistHeartButton(
                        saved: saved,
                        tooltip: saved
                            ? l10n.productUnsave(product.name)
                            : l10n.productSave(product.name),
                        onPressed: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggle(product.id),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _inset.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs.h,
                  children: <Widget>[
                    RatingLine(
                      rating: product.rating,
                      count: product.ratingCount,
                    ),
                    SizedBox(
                      height: _nameHeight(context),
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                    SizedBox(
                      height: _priceHeight(context),
                      // The old price may reach past the box, as designed.
                      child: OverflowBox(
                        alignment: AlignmentDirectional.topStart,
                        maxHeight: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xxs.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: PriceBlock(product: product)),
                              AddToCartButton(
                                added: added,
                                onAdd: () => ref
                                    .read(cartViewModelProvider.notifier)
                                    .add(product.id),
                                onOpenCart: CartShortcut.of(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
