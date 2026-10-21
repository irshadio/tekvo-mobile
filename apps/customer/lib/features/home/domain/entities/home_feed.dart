import 'package:core/utils/money.dart';
import 'package:customer/features/home/domain/entities/promo.dart';
import 'package:flutter/foundation.dart';

/// Everything the home tab shows, as the server sends it.
@immutable
final class HomeFeed {
  const HomeFeed({
    required this.deliveryArea,
    required this.deliveryEta,
    required this.city,
    required this.freeDeliveryOver,
    required this.hero,
    required this.flashSaleEndsIn,
  });

  /// Where orders go, such as `Dubai Marina, Dubai`.
  final String deliveryArea;

  /// When an order placed now arrives, such as `Today by 9 PM`.
  final String deliveryEta;

  /// The city with same-day delivery.
  final String city;
  final Money freeDeliveryOver;
  final List<Promo> hero;

  /// Time left in the flash sale when the feed was sent.
  final Duration flashSaleEndsIn;
}
