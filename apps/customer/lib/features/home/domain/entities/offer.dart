import 'package:flutter/foundation.dart';

/// How an offer card is drawn.
enum OfferStyle {
  /// Trading in a device, on the primary tint.
  tradeIn,

  /// Paying in instalments, on the deal green.
  instalments,
}

/// A shop-wide offer with a photo of what it applies to.
@immutable
final class Offer {
  const Offer({
    required this.style,
    required this.title,
    required this.detail,
    required this.image,
  });

  final OfferStyle style;
  final String title;
  final String detail;

  /// A bundled image key from `Assets`.
  final String image;
}
