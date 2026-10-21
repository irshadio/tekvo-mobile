import 'package:core/utils/money.dart';
import 'package:flutter/foundation.dart';

/// The label on a product photo.
sealed class ProductTag {
  const ProductTag();
}

/// A discount, as the server worked it out.
final class SaleTag extends ProductTag {
  const SaleTag(this.percent);

  final int percent;
}

final class NewTag extends ProductTag {
  const NewTag();
}

final class BestsellerTag extends ProductTag {
  const BestsellerTag();
}

final class LowStockTag extends ProductTag {
  const LowStockTag(this.left);

  final int left;
}

final class FreeDeliveryTag extends ProductTag {
  const FreeDeliveryTag();
}

/// A product as a card shows it. Prices and discounts come from the
/// server; the app never works them out.
@immutable
final class Product {
  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.ratingCount,
    this.was,
    this.tag,
  });

  final String id;
  final String name;

  /// A bundled image key from `Assets`.
  final String image;
  final Money price;

  /// The price before a sale, shown under [price].
  final Money? was;

  /// Out of five.
  final double rating;
  final int ratingCount;
  final ProductTag? tag;

  bool get onSale => was != null;
}
