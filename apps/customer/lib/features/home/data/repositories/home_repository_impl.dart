import 'package:core/assets/assets.gen.dart';
import 'package:core/error/failure.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/domain/entities/promo.dart';
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
  );
}
