import 'package:core/catalog/product.dart';
import 'package:core/catalog/promo.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:flutter/foundation.dart';

/// The order a store's products are listed in.
enum StoreSort { popular, newArrivals, priceLow, onSale }

/// A discount the store gives, collected before checkout.
@immutable
final class StoreCoupon {
  const StoreCoupon({
    required this.id,
    required this.title,
    required this.detail,
    this.collected = false,
  });

  final String id;

  /// Such as `AED 100 off`.
  final String title;

  /// Such as `Orders over AED 1,500`.
  final String detail;

  /// Already in the user's wallet.
  final bool collected;
}

/// One of the store's categories, named by the store.
@immutable
final class StoreCategory {
  const StoreCategory({required this.label, required this.category});

  /// Such as `Tablets & PCs`.
  final String label;

  /// The shop category it lists, which also gives its icon.
  final ShopCategory category;
}

/// A brand's store: who it is, how it does, and what it sells.
@immutable
final class Store {
  const Store({
    required this.id,
    required this.brand,
    required this.name,
    required this.about,
    required this.cover,
    required this.logo,
    required this.verified,
    required this.rating,
    required this.positive,
    required this.followers,
    required this.shipsWithinHours,
    required this.coupons,
    required this.categories,
    required this.bestSellers,
    required this.products,
    required this.productCount,
    this.promo,
  });

  final String id;

  /// Such as `Nova`.
  final String brand;

  /// Such as `Nova Official Store`.
  final String name;
  final String about;

  /// Bundled image keys from `Assets`.
  final String cover;
  final String logo;
  final bool verified;
  final double rating;

  /// The share of positive ratings, in percent.
  final int positive;
  final int followers;
  final int shipsWithinHours;
  final List<StoreCoupon> coupons;
  final Promo? promo;
  final List<StoreCategory> categories;
  final List<Product> bestSellers;

  /// The first products in the chosen order.
  final List<Product> products;

  /// How many products the store sells.
  final int productCount;
}
