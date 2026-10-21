import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/presentation/view/widgets/product_card_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
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
    super.key,
  });

  final Product product;
  final double width;
  final VoidCallback onOpen;

  /// The card's height in design pixels at every width.
  static const double height = 300;

  static const double _photo = 174;
  static const double _radius = 12;
  static const double _inset = 10;
  static const double _heart = 36;
  static const double _tintOpacity = 0.05;
  static const double _lineBox = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final saved = ref.watch(
      wishlistViewModelProvider.select((ids) => ids.contains(product.id)),
    );
    final added = ref.watch(
      cartViewModelProvider.select((cart) => cart.added.contains(product.id)),
    );
    final l10n = context.l10n;
    final radius = BorderRadius.circular(_radius.r);
    return SizedBox(
      width: width.w,
      height: height.h,
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
                      child: AppIconButton(
                        icon: saved
                            ? Assets.iconsHeartFilled
                            : Assets.iconsHeart,
                        iconColor: saved
                            ? context.appColors.commerceSale
                            : null,
                        tooltip: saved
                            ? l10n.productUnsave(product.name)
                            : l10n.productSave(product.name),
                        variant: AppIconButtonVariant.glass,
                        size: _heart,
                        iconSize: 22,
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
                      height: _lineBox.h,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                    SizedBox(
                      height: _lineBox.h,
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
