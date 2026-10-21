import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/sharing/share_service.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/presentation/view/widgets/added_toast.dart';
import 'package:customer/features/product/presentation/view/widgets/product_bottom_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/product_gallery.dart';
import 'package:customer/features/product/presentation/view/widgets/product_header.dart';
import 'package:customer/features/product/presentation/view/widgets/product_info.dart';
import 'package:customer/features/product/presentation/view_model/added_toast_view_model.dart';
import 'package:customer/features/product/presentation/view_model/coupon_view_model.dart';
import 'package:customer/features/product/presentation/view_model/gallery_view_model.dart';
import 'package:customer/features/product/presentation/view_model/product_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A product: photos, price, options and everything to decide on it, with
/// Add to cart pinned at the foot. [onOpenCart] shows the cart, which the
/// shell owns, from this screen's context.
class ProductView extends ConsumerStatefulWidget {
  const ProductView({required this.id, required this.onOpenCart, super.key});

  final String id;
  final void Function(BuildContext context) onOpenCart;

  /// How long the page takes to push in, as in the prototype.
  static const Duration entryDuration = Duration(milliseconds: 300);

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView>
    with ViewReadyMixin<ProductView> {
  static const double _band = 8;
  static const Duration _toastSlide = Duration(milliseconds: 250);

  ProductViewModelProvider get _product => productViewModelProvider(widget.id);

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(_product.notifier).load());

  void _open(String route, {Object? arguments}) =>
      unawaited(context.pushNamed<void>(route, arguments: arguments));

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_product, context);
    final state = ref.watch(_product);
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: ViewStateSwitcher<ProductDetails>(
          state: state,
          onRetry: _load,
          onData: _page,
        ),
      ),
    );
  }

  Widget _page(ProductDetails product) {
    final cart = ref.watch(cartViewModelProvider);
    final saved = ref.watch(
      wishlistViewModelProvider.select((ids) => ids.contains(product.id)),
    );
    final toast = ref.watch(addedToastViewModelProvider);
    final l10n = context.l10n;
    final band = SizedBox(height: _band.h);
    return Column(
      children: <Widget>[
        ProductHeader(
          cartCount: cart.count,
          onSearch: () => _open(Routes.search),
          onShare: () => unawaited(
            ref.read(shareServiceProvider).shareText(product.title),
          ),
          onCart: () => widget.onOpenCart(context),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView(
                  children: <Widget>[
                    ProductGallery(
                      images: product.images,
                      tags: product.tags,
                      current: ref.watch(galleryViewModelProvider(product.id)),
                      saved: saved,
                      heartTooltip: saved
                          ? context.coreL10n.productUnsave(product.title)
                          : context.coreL10n.productSave(product.title),
                      onShow: ref
                          .read(galleryViewModelProvider(product.id).notifier)
                          .show,
                      onToggleSaved: () => ref
                          .read(wishlistViewModelProvider.notifier)
                          .toggle(product.id),
                    ),
                    band,
                    ProductInfo(
                      product: product,
                      couponApplied: ref.watch(
                        couponViewModelProvider(product.id),
                      ),
                      onStore: () =>
                          _open(Routes.store, arguments: product.store),
                      onApplyCoupon: () {
                        ref
                            .read(couponViewModelProvider(product.id).notifier)
                            .apply();
                        context.showSnackBar(l10n.productCouponAppliedNote);
                      },
                    ),
                    band,
                  ],
                ),
              ),
              PositionedDirectional(
                start: AppSpacing.lg.w,
                end: AppSpacing.lg.w,
                bottom: AppSpacing.md.h,
                child: AnimatedSwitcher(
                  duration: context.motion(_toastSlide),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: toast
                      ? AddedToast(
                          productName: product.title,
                          onViewCart: () {
                            ref
                                .read(addedToastViewModelProvider.notifier)
                                .hide();
                            widget.onOpenCart(context);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
        ProductBottomBar(
          price: product.price,
          freeDelivery: product.freeDelivery,
          quantity: cart.quantityOf(product.id),
          onAdd: () {
            ref.read(cartViewModelProvider.notifier).add(product.id);
            ref.read(addedToastViewModelProvider.notifier).show();
          },
          onIncrease: () =>
              ref.read(cartViewModelProvider.notifier).increase(product.id),
          onDecrease: () =>
              ref.read(cartViewModelProvider.notifier).decrease(product.id),
        ),
      ],
    );
  }
}
