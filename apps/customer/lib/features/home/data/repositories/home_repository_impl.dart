import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/catalog/promo.dart';
import 'package:core/error/failure.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/home/domain/entities/deal_tile.dart';
import 'package:customer/features/home/domain/entities/flash_deal.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/domain/entities/offer.dart';
import 'package:customer/features/home/domain/entities/product_facet.dart';
import 'package:customer/features/home/domain/entities/shop_category.dart';
import 'package:customer/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the catalogue is served: the design's sample feed.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<Either<Failure, HomeFeed>> feed() async => right(sample);

  static const HomeFeed sample = HomeFeed(
    deliveryArea: 'Dubai Marina, Dubai',
    deliveryEta: 'Today by 9 PM',
    city: 'Dubai',
    freeDeliveryOver: Money.units(200),
    flashSaleEndsIn: Duration(hours: 2, minutes: 14, seconds: 37),
    hero: <Promo>[
      Promo(
        id: 'nova-x-pro',
        style: PromoStyle.launch,
        eyebrow: 'NEW',
        title: 'Nova X Pro is here',
        subtitle: 'From AED 3,499 or AED 292/mo',
        action: 'Pre-order',
        image: Assets.productsNovaXPro,
      ),
      Promo(
        id: 'gaming-sale',
        style: PromoStyle.flashSale,
        eyebrow: 'FLASH SALE',
        title: 'Up to 40% off gaming',
        image: Assets.productsPlaycore5,
      ),
      Promo(
        id: 'aero-book-14',
        style: PromoStyle.newArrival,
        eyebrow: 'JUST LANDED',
        title: 'Aero Book 14 is here',
        action: 'Shop now',
        image: Assets.productsAeroBookPro,
      ),
    ],
    flashDeals: <FlashDeal>[
      FlashDeal(product: pulseAncMax, soldPercent: 72),
      FlashDeal(product: budsAir3, soldPercent: 45),
      FlashDeal(product: playCore5, soldPercent: 88, almostGone: true),
      FlashDeal(product: boomGo, soldPercent: 31),
    ],
    offers: <Offer>[
      Offer(
        style: OfferStyle.tradeIn,
        title: 'Trade in your old phone',
        detail: 'Up to AED 1,500 credit',
        image: Assets.productsNovaSLite,
      ),
      Offer(
        style: OfferStyle.instalments,
        title: 'Pay in 4, interest-free',
        detail: 'On orders over AED 500',
        image: Assets.productsArcWatchS2,
      ),
    ],
    dealTiles: <DealTile>[
      DealTile(
        category: ShopCategory.audio,
        title: 'Audio',
        deal: 'Up to 40% off',
        image: Assets.productsPulseStudio,
      ),
      DealTile(
        category: ShopCategory.watches,
        title: 'Wearables',
        deal: 'From AED 299',
        image: Assets.productsArcWatchS2,
      ),
      DealTile(
        category: ShopCategory.laptops,
        title: 'Laptops',
        deal: 'Save AED 800',
        image: Assets.productsAeroBookPro,
      ),
      DealTile(
        category: ShopCategory.cameras,
        title: 'Cameras',
        deal: 'Up to 25% off',
        image: Assets.productsSnapZ5,
      ),
    ],
    phones: <Product>[novaXPro, novaSLite, slateTab11],
    phoneFacets: <ProductFacet>[
      ProductFacet(label: 'Flagship', productIds: <String>{'nova-x-pro'}),
      ProductFacet(
        label: 'Under AED 1,500',
        productIds: <String>{'nova-s-lite'},
      ),
      ProductFacet(
        label: '5G',
        productIds: <String>{'nova-x-pro', 'nova-s-lite'},
      ),
      ProductFacet(label: 'Foldables', productIds: <String>{}),
    ],
    launch: Promo(
      id: 'aero-book-14',
      style: PromoStyle.newArrival,
      eyebrow: 'JUST LANDED',
      title: 'Aero Book 14 is here',
      action: 'Shop now',
      image: Assets.productsAeroBookPro,
    ),
    audio: <Product>[pulseStudio, budsAir3, boomGo, pulseAncMax],
    recentlyViewed: <Product>[
      Product(
        id: 'arc-watch-s2',
        name: 'Arc Watch S2',
        image: Assets.productsArcWatchS2,
        price: Money.units(1299),
        rating: 4.7,
        ratingCount: 2000,
      ),
      Product(
        id: 'snap-z5',
        name: 'Snap Z5 Mirrorless',
        image: Assets.productsSnapZ5,
        price: Money.units(5299),
        rating: 4.8,
        ratingCount: 410,
      ),
      Product(
        id: 'aero-book-14',
        name: 'Aero Book 14',
        image: Assets.productsAeroBook14,
        price: Money.units(4999),
        rating: 4.7,
        ratingCount: 380,
      ),
      Product(
        id: 'instant-mini',
        name: 'Instant Mini',
        image: Assets.productsInstantMini,
        price: Money.units(449),
        rating: 4.4,
        ratingCount: 290,
      ),
    ],
    recommended: <Product>[aeroBookPro16, arcWatchS2, snapZ5Kit, arcClassic],
    moreRecommended: <Product>[novaXPro, pulseStudio, slateTab11, playCore5],
  );

  static const Product pulseAncMax = Product(
    id: 'pulse-anc-max',
    name: 'Pulse ANC Max Headphones',
    image: Assets.productsPulseAncMax,
    price: Money.units(1099),
    was: Money.units(1399),
    rating: 4.8,
    ratingCount: 3200,
    tag: SaleTag(21),
  );

  static const Product budsAir3 = Product(
    id: 'buds-air-3',
    name: 'Buds Air 3 · ANC',
    image: Assets.productsBudsAir3,
    price: Money.units(399),
    was: Money.units(499),
    rating: 4.6,
    ratingCount: 1100,
    tag: SaleTag(20),
  );

  static const Product playCore5 = Product(
    id: 'playcore-5',
    name: 'PlayCore 5 Console',
    image: Assets.productsPlaycore5,
    price: Money.units(1899),
    was: Money.units(2099),
    rating: 4.9,
    ratingCount: 5400,
    tag: SaleTag(10),
  );

  static const Product boomGo = Product(
    id: 'boom-go',
    name: 'Boom Go Speaker',
    image: Assets.productsBoomGo,
    price: Money.units(349),
    was: Money.units(449),
    rating: 4.5,
    ratingCount: 860,
    tag: SaleTag(22),
  );

  static const Product novaXPro = Product(
    id: 'nova-x-pro',
    name: 'Nova X Pro · 256GB',
    image: Assets.productsNovaXPro,
    price: Money.units(3499),
    was: Money.units(3999),
    rating: 4.8,
    ratingCount: 2400,
    tag: SaleTag(12),
  );

  static const Product novaSLite = Product(
    id: 'nova-s-lite',
    name: 'Nova S Lite · 128GB',
    image: Assets.productsNovaSLite,
    price: Money.units(1499),
    rating: 4.6,
    ratingCount: 980,
    tag: BestsellerTag(),
  );

  static const Product slateTab11 = Product(
    id: 'slate-tab-11',
    name: 'Slate Tab 11 · Wi-Fi',
    image: Assets.productsSlateTab11,
    price: Money.units(2299),
    rating: 4.7,
    ratingCount: 640,
    tag: FreeDeliveryTag(),
  );

  static const Product pulseStudio = Product(
    id: 'pulse-studio',
    name: 'Pulse Studio Wireless',
    image: Assets.productsPulseStudio,
    price: Money.units(649),
    rating: 4.7,
    ratingCount: 1800,
    tag: BestsellerTag(),
  );

  static const Product aeroBookPro16 = Product(
    id: 'aero-book-pro-16',
    name: 'Aero Book Pro 16 · 32GB',
    image: Assets.productsAeroBookPro,
    price: Money.units(8499),
    was: Money.units(9199),
    rating: 4.9,
    ratingCount: 720,
    tag: SaleTag(8),
  );

  static const Product arcWatchS2 = Product(
    id: 'arc-watch-s2',
    name: 'Arc Watch S2 · 44mm',
    image: Assets.productsArcWatchS2,
    price: Money.units(1299),
    rating: 4.7,
    ratingCount: 2000,
    tag: NewTag(),
  );

  static const Product snapZ5Kit = Product(
    id: 'snap-z5',
    name: 'Snap Z5 Mirrorless Kit',
    image: Assets.productsSnapZ5,
    price: Money.units(5299),
    rating: 4.8,
    ratingCount: 410,
    tag: LowStockTag(3),
  );

  static const Product arcClassic = Product(
    id: 'arc-classic',
    name: 'Arc Classic · Steel',
    image: Assets.productsArcClassic,
    price: Money.units(899),
    was: Money.units(1099),
    rating: 4.5,
    ratingCount: 530,
    tag: SaleTag(18),
  );
}
