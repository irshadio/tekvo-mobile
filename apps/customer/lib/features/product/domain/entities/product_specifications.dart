import 'package:core/utils/money.dart';
import 'package:customer/features/product/domain/entities/product_specs.dart';
import 'package:flutter/foundation.dart';

enum SpecGroupKind {
  general,
  display,
  performance,
  camera,
  battery,
  connectivity,
  design,
  inTheBox,
}

/// A titled block of the specification, such as Display.
@immutable
final class SpecGroup {
  const SpecGroup({
    required this.kind,
    required this.title,
    required this.rows,
    this.chip,
  });

  final SpecGroupKind kind;

  /// Such as `Battery & charging`.
  final String title;

  /// The shorter name on its jump chip, such as `Battery`; groups without
  /// one get no chip.
  final String? chip;
  final List<Spec> rows;
}

/// The full specification of a product, with enough of the product to
/// buy it from the same screen.
@immutable
final class ProductSpecifications {
  const ProductSpecifications({
    required this.id,
    required this.name,
    required this.variant,
    required this.image,
    required this.rating,
    required this.ratingCount,
    required this.price,
    required this.freeDelivery,
    required this.overview,
    required this.features,
    required this.groups,
  });

  final String id;

  /// Such as `Nova X Pro 5G`.
  final String name;

  /// Such as `256 GB, 12 GB RAM · Titanium Black`.
  final String variant;

  /// A bundled image key from `Assets`.
  final String image;
  final double rating;
  final int ratingCount;
  final Money price;
  final bool freeDelivery;
  final String overview;

  /// The selling points, one line each.
  final List<String> features;
  final List<SpecGroup> groups;
}
