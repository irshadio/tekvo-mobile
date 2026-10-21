import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/presentation/view/widgets/category_grid.dart';
import 'package:customer/features/home/presentation/view/widgets/deals_grid.dart';
import 'package:customer/features/home/presentation/view/widgets/flash_deals_section.dart';
import 'package:customer/features/home/presentation/view/widgets/hero_carousel.dart';
import 'package:customer/features/home/presentation/view/widgets/home_header.dart';
import 'package:customer/features/home/presentation/view/widgets/offers_row.dart';
import 'package:customer/features/home/presentation/view/widgets/section_header.dart';
import 'package:customer/features/home/presentation/view/widgets/trust_strip.dart';
import 'package:customer/features/home/presentation/view_model/flash_sale_timer_view_model.dart';
import 'package:customer/features/home/presentation/view_model/home_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The home tab: a pinned header over promotions, categories and products.
/// [onOpenExplore] and [onOpenCart] switch tabs, which the shell owns.
class HomeView extends ConsumerStatefulWidget {
  const HomeView({
    required this.onOpenExplore,
    required this.onOpenCart,
    super.key,
  });

  final VoidCallback onOpenExplore;
  final VoidCallback onOpenCart;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with ViewReadyMixin<HomeView> {
  static const double _contentTop = 6;
  static const double _sectionGap = 28;

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(homeViewModelProvider.notifier).load());

  void _open(String route, {Object? arguments}) =>
      unawaited(context.pushNamed<void>(route, arguments: arguments));

  void _openProduct(String id) => _open(Routes.product, arguments: id);

  @override
  Widget build(BuildContext context) {
    ref
      ..listenRefreshFailures(homeViewModelProvider, context)
      ..listen<ViewState<HomeFeed>>(homeViewModelProvider, (previous, next) {
        final feed = next.dataOrNull;
        if (feed != null && feed != previous?.dataOrNull) {
          ref
              .read(flashSaleTimerViewModelProvider.notifier)
              .start(feed.flashSaleEndsIn);
        }
      });
    final state = ref.watch(homeViewModelProvider);
    // Watched before the feed arrives, so the countdown it starts is kept.
    final saleLeft = ref.watch(flashSaleTimerViewModelProvider);
    return ViewStateSwitcher<HomeFeed>(
      state: state,
      onRetry: _load,
      onData: (feed) => _page(feed, saleLeft),
    );
  }

  Widget _page(HomeFeed feed, Duration saleLeft) {
    final cartCount = ref.watch(
      cartViewModelProvider.select((cart) => cart.count),
    );
    final headerHeight = context.viewPadding.top + HomeHeader.height.h;
    return Stack(
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.only(
                  top: headerHeight + _contentTop.h,
                  bottom: _sectionGap.h,
                ),
                sliver: SliverList.list(children: _sections(feed, saleLeft)),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: HomeHeader(
            deliveryArea: feed.deliveryArea,
            deliveryEta: feed.deliveryEta,
            cartCount: cartCount,
            onNotifications: () => _open(Routes.notifications),
            onCart: widget.onOpenCart,
            onSearch: () => _open(Routes.search),
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(HomeFeed feed, Duration saleLeft) {
    final l10n = context.l10n;
    final gap = SizedBox(height: _sectionGap.h);
    final side = EdgeInsets.symmetric(horizontal: AppSpacing.lg.w);
    return <Widget>[
      TrustStrip(freeDeliveryOver: feed.freeDeliveryOver, city: feed.city),
      gap,
      HeroCarousel(
        promos: feed.hero,
        flashSaleRemaining: saleLeft,
        onPromo: (promo) => _openProduct(promo.id),
      ),
      gap,
      Padding(
        padding: side,
        child: Column(
          spacing: AppSpacing.md.h,
          children: <Widget>[
            SectionHeader(
              title: l10n.homeShopByCategory,
              onSeeAll: widget.onOpenExplore,
            ),
            CategoryGrid(
              onCategory: (category) =>
                  _open(Routes.productList, arguments: category),
            ),
          ],
        ),
      ),
      gap,
      FlashDealsSection(
        deals: feed.flashDeals,
        remaining: saleLeft,
        onSeeAll: widget.onOpenExplore,
        onProduct: _openProduct,
      ),
      gap,
      Padding(
        padding: side,
        child: OffersRow(offers: feed.offers),
      ),
      gap,
      Padding(
        padding: side,
        child: Column(
          spacing: AppSpacing.md.h,
          children: <Widget>[
            SectionHeader(
              title: l10n.homeDealsByCategory,
              onSeeAll: widget.onOpenExplore,
            ),
            DealsGrid(
              tiles: feed.dealTiles,
              onTile: (tile) =>
                  _open(Routes.productList, arguments: tile.category),
            ),
          ],
        ),
      ),
    ];
  }
}
