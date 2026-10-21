import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:flutter/foundation.dart';

/// A search people are making more of, with a note on why.
@immutable
final class TrendingSearch {
  const TrendingSearch({required this.query, this.note, this.hot = false});

  final String query;

  /// Such as `+240% this week`.
  final String? note;

  /// Rising fast; its note shows in the sale colour.
  final bool hot;
}

/// What search shows before the user types.
@immutable
final class SearchHome {
  const SearchHome({
    required this.recent,
    required this.trending,
    required this.recentlyViewed,
  });

  final List<String> recent;
  final List<TrendingSearch> trending;
  final List<Product> recentlyViewed;
}

/// A store the query matches.
@immutable
final class StoreHit {
  const StoreHit({
    required this.brand,
    required this.name,
    required this.logo,
    required this.verified,
    required this.productCount,
    required this.rating,
  });

  /// Opens the store page.
  final String brand;
  final String name;

  /// A bundled image key from `Assets`.
  final String logo;
  final bool verified;
  final int productCount;
  final double rating;
}

/// A way to finish the query, optionally within a category.
@immutable
final class Suggestion {
  const Suggestion({required this.query, this.category, this.categoryName});

  final String query;
  final ShopCategory? category;

  /// The category as the shop names it, such as `Accessories`.
  final String? categoryName;
}

/// Suggestions while typing, with the store and products it already finds.
@immutable
final class Suggestions {
  const Suggestions({
    required this.query,
    required this.suggestions,
    required this.products,
    required this.total,
    this.store,
  });

  final String query;
  final List<Suggestion> suggestions;
  final StoreHit? store;

  /// The best few matches.
  final List<Product> products;

  /// How many products match.
  final int total;
}
