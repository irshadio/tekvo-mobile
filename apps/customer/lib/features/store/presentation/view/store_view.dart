import 'dart:async';

import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/presentation/widgets/product/product_row.dart';
import 'package:core/presentation/widgets/promo_banner.dart';
import 'package:core/presentation/widgets/section_header.dart';
import 'package:core/sharing/share_service.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/features/store/presentation/view/widgets/store_head.dart';
import 'package:customer/features/store/presentation/view/widgets/store_header.dart';
import 'package:customer/features/store/presentation/view/widgets/store_sections.dart';
import 'package:customer/features/store/presentation/view_model/store_choices_view_model.dart';
import 'package:customer/features/store/presentation/view_model/store_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A brand's store: who it is, its coupons, promotions, categories, best
/// sellers and every product. Its tabs jump to their sections.
class StoreView extends ConsumerStatefulWidget {
  const StoreView({required this.brand, super.key});

  /// Such as `Nova`.
  final String brand;

  @override
  ConsumerState<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends ConsumerState<StoreView>
    with ViewReadyMixin<StoreView> {
  static const double _band = 8;
  static const double _promo = 164;
  static const double _spyMargin = 24;
  static const Duration _jump = Duration(milliseconds: 350);

  static const int _home = 0;
  static const int _products = 1;
  static const int _categories = 2;
  static const int _reviews = 3;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewport = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final ValueNotifier<int> _tab = ValueNotifier<int>(_home);
  bool _jumping = false;

  StoreViewModelProvider get _store => storeViewModelProvider(widget.brand);
  StoreChoicesViewModelProvider get _choices =>
      storeChoicesViewModelProvider(widget.brand);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_followScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(_store.notifier).load());

  void _open(String route, {Object? arguments}) =>
      unawaited(context.pushNamed<void>(route, arguments: arguments));

  Future<void> _chooseTab(int tab) async {
    if (tab == _reviews) {
      _open(Routes.storeReviews, arguments: widget.brand);
      return;
    }
    _tab.value = tab;
    _jumping = true;
    if (tab == _home) {
      await _scroll.animateTo(
        0,
        duration: context.motion(_jump),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final section =
          (tab == _products ? _productsKey : _categoriesKey).currentContext;
      if (section != null) {
        await Scrollable.ensureVisible(
          section,
          duration: context.motion(_jump),
          curve: Curves.easeInOutCubic,
        );
      }
    }
    _jumping = false;
  }

  /// Marks the tab of the section the list has reached.
  void _followScroll() {
    if (_jumping) return;
    final viewport = _viewport.currentContext?.findRenderObject();
    if (viewport is! RenderBox) return;
    bool reached(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      return box is RenderBox &&
          box.localToGlobal(Offset.zero, ancestor: viewport).dy <= _spyMargin.h;
    }

    _tab.value = reached(_productsKey)
        ? _products
        : reached(_categoriesKey)
        ? _categories
        : _home;
  }

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_store, context);
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: Column(
          children: <Widget>[
            StoreHeader(
              brand: widget.brand,
              onSearch: () => _open(Routes.search),
              onShare: () => unawaited(
                ref.read(shareServiceProvider).shareText(widget.brand),
              ),
            ),
            Expanded(
              child: ViewStateSwitcher<Store>(
                state: ref.watch(_store),
                onRetry: _load,
                onData: _page,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(Store store) {
    final l10n = context.l10n;
    final choices = ref.watch(_choices);
    final act = ref.read(_choices.notifier);
    final band = SizedBox(height: _band.h);
    final promo = store.promo;
    void openProduct(String id) => _open(Routes.product, arguments: id);
    void openCategory(ShopCategory category) =>
        _open(Routes.productList, arguments: category);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SingleChildScrollView(
        key: _viewport,
        controller: _scroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ValueListenableBuilder<int>(
              valueListenable: _tab,
              builder: (context, tab, _) => StoreHead(
                store: store,
                following: choices.following,
                tab: tab,
                onChat: () => _open(Routes.supportChat, arguments: store.id),
                onFollow: () => act.toggleFollow(store.id),
                onTab: (tab) => unawaited(_chooseTab(tab)),
              ),
            ),
            band,
            StoreCoupons(
              coupons: store.coupons,
              collected: choices.collected,
              onCollect: (coupon) {
                act.collect(store.id, coupon.id);
                context.showSnackBar(l10n.storeCouponCollected);
              },
            ),
            if (promo != null) ...<Widget>[
              band,
              ColoredBox(
                color: context.colors.surfaceContainerLowest,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  child: SizedBox(
                    height: _promo.h,
                    child: PromoBanner(
                      promo: promo,
                      onTap: () => _open(Routes.productList),
                    ),
                  ),
                ),
              ),
            ],
            band,
            KeyedSubtree(
              key: _categoriesKey,
              child: StoreCategories(
                categories: store.categories,
                onCategory: openCategory,
              ),
            ),
            band,
            ColoredBox(
              color: context.colors.surfaceContainerLowest,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md.h,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg.w,
                      ),
                      child: SectionHeader(
                        title: l10n.storeBestSellers,
                        onSeeAll: () => unawaited(_chooseTab(_products)),
                      ),
                    ),
                    ProductRow(
                      products: store.bestSellers,
                      onProduct: openProduct,
                    ),
                  ],
                ),
              ),
            ),
            band,
            KeyedSubtree(
              key: _productsKey,
              child: StoreProducts(
                products: store.products,
                count: store.productCount,
                sort: choices.sort,
                onSort: act.sort,
                onProduct: openProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
