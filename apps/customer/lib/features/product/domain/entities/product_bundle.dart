import 'package:core/utils/money.dart';
import 'package:flutter/foundation.dart';

/// A product often bought with this one.
@immutable
final class BundleItem {
  const BundleItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  final String id;

  /// Such as `Buds Air 3 · ANC`.
  final String name;

  /// A bundled image key from `Assets`.
  final String image;
  final Money price;
}

/// This product with what is often bought with it, and the price for all
/// of them together as the server worked it out.
@immutable
final class Bundle {
  const Bundle({
    required this.items,
    required this.total,
    required this.saving,
  });

  /// This product first.
  final List<BundleItem> items;
  final Money total;
  final Money saving;
}
