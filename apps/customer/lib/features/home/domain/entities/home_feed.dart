import 'package:core/utils/money.dart';
import 'package:customer/features/home/domain/entities/deal_tile.dart';
import 'package:customer/features/home/domain/entities/flash_deal.dart';
import 'package:customer/features/home/domain/entities/offer.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/domain/entities/product_facet.dart';
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
    required this.flashDeals,
    required this.offers,
    required this.dealTiles,
    required this.phones,
    required this.phoneFacets,
    required this.launch,
    required this.audio,
    required this.recentlyViewed,
    required this.recommended,
    required this.moreRecommended,
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
  final List<FlashDeal> flashDeals;
  final List<Offer> offers;
  final List<DealTile> dealTiles;
  final List<Product> phones;

  /// Filters over [phones], after the app's own All.
  final List<ProductFacet> phoneFacets;
  final Promo launch;
  final List<Product> audio;
  final List<Product> recentlyViewed;
  final List<Product> recommended;

  /// Shown under [recommended] once the user asks for more.
  final List<Product> moreRecommended;
}
