import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/domain/entities/shop_category.dart';
import 'package:customer/features/home/presentation/view/widgets/category_grid.dart';
import 'package:customer/features/home/presentation/view/widgets/deals_grid.dart';
import 'package:customer/features/home/presentation/view/widgets/filter_chips.dart';
import 'package:customer/features/home/presentation/view/widgets/flash_deals_section.dart';
import 'package:customer/features/home/presentation/view/widgets/hero_carousel.dart';
import 'package:customer/features/home/presentation/view/widgets/home_header.dart';
import 'package:customer/features/home/presentation/view/widgets/offers_row.dart';
import 'package:customer/features/home/presentation/view/widgets/product_row.dart';
import 'package:customer/features/home/presentation/view/widgets/promo_banner.dart';
import 'package:customer/features/home/presentation/view/widgets/recently_viewed.dart';
import 'package:customer/features/home/presentation/view/widgets/recommended_grid.dart';
import 'package:customer/features/home/presentation/view/widgets/section_header.dart';
import 'package:customer/features/home/presentation/view/widgets/trust_footer.dart';
import 'package:customer/features/home/presentation/view/widgets/trust_strip.dart';
import 'package:customer/features/home/presentation/view_model/flash_sale_timer_view_model.dart';
import 'package:customer/features/home/presentation/view_model/home_view_model.dart';
import 'package:customer/features/home/presentation/view_model/phone_filter_view_model.dart';
import 'package:customer/features/home/presentation/view_model/recommended_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    with ViewReadyMixin<HomeView>, TickerProviderStateMixin<HomeView> {
  /// The room between the pinned header and the first chips.
  static const double _contentTop = AppSpacing.lg;
  static const double _sectionGap = 28;
  static const double _launchHeight = 164;
  static const double _outline = 1.5;

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
    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: _HeaderDelegate(
            vsync: this,
            expanded: HomeHeader.heightOf(context),
            collapsed: HomeHeader.collapsedHeightOf(context),
            header: (searchShown) => HomeHeader(
              deliveryArea: feed.deliveryArea,
              deliveryEta: feed.deliveryEta,
              cartCount: cartCount,
              searchShown: searchShown,
              onNotifications: () => _open(Routes.notifications),
              onCart: widget.onOpenCart,
              onSearch: () => _open(Routes.search),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            top: _contentTop.h,
            bottom: _sectionGap.h,
          ),
          sliver: SliverList.list(children: _sections(feed, saleLeft)),
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
      gap,
      _phones(feed),
      gap,
      Padding(
        padding: side,
        child: SizedBox(
          height: _launchHeight.h,
          child: PromoBanner(
            promo: feed.launch,
            onTap: () => _openProduct(feed.launch.id),
          ),
        ),
      ),
      gap,
      _shelf(
        title: l10n.homeTrendingAudio,
        onSeeAll: () =>
            _open(Routes.productList, arguments: ShopCategory.audio),
        child: ProductRow(products: feed.audio, onProduct: _openProduct),
      ),
      gap,
      _shelf(
        title: l10n.homeRecentlyViewed,
        onSeeAll: widget.onOpenExplore,
        child: RecentlyViewed(
          products: feed.recentlyViewed,
          onProduct: _openProduct,
        ),
      ),
      gap,
      _recommended(feed),
      gap,
      Padding(padding: side, child: const TrustFooter()),
    ];
  }

  /// A titled section whose content runs edge to edge.
  Widget _shelf({
    required String title,
    required VoidCallback onSeeAll,
    required Widget child,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.md.h,
    children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: SectionHeader(title: title, onSeeAll: onSeeAll),
      ),
      child,
    ],
  );

  Widget _phones(HomeFeed feed) {
    final facet = ref.watch(phoneFilterViewModelProvider);
    final keep = facet == null ? null : feed.phoneFacets[facet].productIds;
    final phones = keep == null
        ? feed.phones
        : feed.phones.where((p) => keep.contains(p.id)).toList();
    return _shelf(
      title: context.l10n.homeBestInPhones,
      onSeeAll: () => _open(Routes.productList, arguments: ShopCategory.phones),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: <Widget>[
          FilterChips(
            labels: <String>[
              context.l10n.homeAll,
              for (final f in feed.phoneFacets) f.label,
            ],
            selected: facet == null ? 0 : facet + 1,
            onSelect: (index) => ref
                .read(phoneFilterViewModelProvider.notifier)
                .select(index == 0 ? null : index - 1),
          ),
          ProductRow(products: phones, onProduct: _openProduct),
        ],
      ),
    );
  }

  Widget _recommended(HomeFeed feed) {
    final l10n = context.l10n;
    final more = ref.watch(recommendedViewModelProvider);
    final products = more
        ? <Product>[...feed.recommended, ...feed.moreRecommended]
        : feed.recommended;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm.h,
        children: <Widget>[
          SectionHeader(
            title: l10n.homeRecommended,
            onSeeAll: widget.onOpenExplore,
          ),
          Text(
            l10n.homeRecommendedReason(feed.city),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          RecommendedGrid(products: products, onProduct: _openProduct),
          if (!more && feed.moreRecommended.isNotEmpty)
            OutlinedButton(
              onPressed: ref
                  .read(recommendedViewModelProvider.notifier)
                  .showMore,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                foregroundColor: context.colors.onSurface,
                side: BorderSide(
                  color: context.colors.outlineVariant,
                  width: _outline,
                ),
              ),
              child: Text(l10n.homeShowMore),
            ),
        ],
      ),
    );
  }
}

/// The header as a sliver that stays pinned at its top row: its search
/// slides away as the page scrolls down and back on any scroll up, snapping
/// fully open or shut.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({
    required this.vsync,
    required this.expanded,
    required this.collapsed,
    required this.header,
  });

  @override
  final TickerProvider vsync;
  final double expanded;
  final double collapsed;
  final Widget Function(double searchShown) header;

  static const Duration _snap = Duration(milliseconds: 250);

  @override
  double get maxExtent => expanded;

  @override
  double get minExtent => collapsed;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration(curve: Curves.easeOut, duration: _snap);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final shown = range <= 0 ? 1.0 : (1 - shrinkOffset / range).clamp(0.0, 1.0);
    return OverflowBox(
      alignment: Alignment.topCenter,
      maxHeight: double.infinity,
      child: header(shown),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) => true;
}
