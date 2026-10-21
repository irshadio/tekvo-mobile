import 'package:core/catalog/shop_category.dart';
import 'package:flutter/foundation.dart';

/// A category's deal as a photo tile.
@immutable
final class DealTile {
  const DealTile({
    required this.category,
    required this.title,
    required this.deal,
    required this.image,
  });

  final ShopCategory category;
  final String title;

  /// The offer line, such as `Up to 40% off`.
  final String deal;

  /// A bundled image key from `Assets`.
  final String image;
}
