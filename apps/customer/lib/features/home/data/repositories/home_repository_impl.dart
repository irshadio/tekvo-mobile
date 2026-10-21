import 'package:core/assets/assets.gen.dart';
import 'package:core/error/failure.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/home/domain/entities/deal_tile.dart';
import 'package:customer/features/home/domain/entities/flash_deal.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/domain/entities/offer.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/domain/entities/promo.dart';
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
}
