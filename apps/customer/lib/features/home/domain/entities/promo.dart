import 'package:flutter/foundation.dart';

/// How a promotion is drawn.
enum PromoStyle {
  /// A product launch on the night blue with a glow and a white button.
  launch,

  /// A timed sale on the night blue with its countdown.
  flashSale,

  /// A new arrival on the deal green with a dark button.
  newArrival,
}

/// A promotion in the hero carousel or between sections. Its words come
/// from the server as they are shown.
@immutable
final class Promo {
  const Promo({
    required this.id,
    required this.style,
    required this.eyebrow,
    required this.title,
    required this.image,
    this.subtitle,
    this.action,
  });

  final String id;
  final PromoStyle style;

  /// The small label above the title, such as `NEW` or `FLASH SALE`.
  final String eyebrow;
  final String title;

  /// A bundled image key from `Assets`.
  final String image;
  final String? subtitle;

  /// The button's label; a flash sale shows its countdown instead.
  final String? action;
}
