import 'package:core/catalog/product.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/product/domain/entities/product_bundle.dart';
import 'package:customer/features/product/domain/entities/product_delivery.dart';
import 'package:customer/features/product/domain/entities/product_options.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/entities/product_specs.dart';
import 'package:flutter/foundation.dart';

/// A discount code the product qualifies for.
@immutable
final class Coupon {
  const Coupon({required this.title, required this.detail});

  /// Such as `Extra AED 150 off`.
  final String title;

  /// Such as `Code TEKVO150 · orders above AED 2,000`.
  final String detail;
}

/// Splitting the price into interest-free payments.
@immutable
final class Instalments {
  const Instalments({required this.count, required this.amount});

  final int count;
  final Money amount;
}

/// Everything the product details screen shows, as the server sends it.
@immutable
final class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.title,
    required this.store,
    required this.officialStore,
    required this.images,
    required this.tags,
    required this.rating,
    required this.ratingCount,
    required this.soldThisWeek,
    required this.price,
    required this.freeDelivery,
    this.was,
    this.saving,
    this.instalments,
    this.coupon,
    this.options = const <ProductOptionGroup>[],
    this.stockLeft,
    this.bundle,
    this.delivery,
    this.protection = const <ProtectionPlan>[],
    this.highlights = const <Highlight>[],
    this.specs = const <Spec>[],
    this.reviews,
    this.questions,
    this.alsoViewed = const <Product>[],
  });

  final String id;
  final String title;

  /// The brand's store, such as `Nova`.
  final String store;
  final bool officialStore;

  /// Bundled image keys from `Assets`, the first shown first.
  final List<String> images;
  final List<ProductTag> tags;
  final double rating;
  final int ratingCount;
  final int soldThisWeek;
  final Money price;
  final Money? was;

  /// How much the sale saves, as the server worked it out.
  final Money? saving;
  final Instalments? instalments;
  final Coupon? coupon;
  final bool freeDelivery;
  final List<ProductOptionGroup> options;

  /// How many are left at this price, when few are.
  final int? stockLeft;
  final Bundle? bundle;
  final Delivery? delivery;
  final List<ProtectionPlan> protection;
  final List<Highlight> highlights;

  /// The main lines of the specification; the full list is its own screen.
  final List<Spec> specs;
  final Reviews? reviews;
  final Questions? questions;
  final List<Product> alsoViewed;
}
