import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:flutter/foundation.dart';

/// The order results are listed in.
enum SearchSort {
  relevance,
  bestSelling,
  priceLow,
  priceHigh,
  rating,
  newest,
  discount,
}

/// One-tap filters above the results.
enum QuickFilter { underTwoThousand, fourStarsUp, freeDelivery, inStock }

/// A group of filters, such as Brand.
enum FacetKind {
  category,
  brand,
  price,
  rating,
  storage,
  colour,
  delivery,
  availability,
  discount,
}

/// A value to filter by, with how many results have it.
@immutable
final class FacetOption {
  const FacetOption({
    required this.id,
    required this.label,
    required this.count,
  });

  final String id;
  final String label;
  final int count;
}

/// A group of values to filter by.
@immutable
final class Facet {
  const Facet({required this.kind, required this.options});

  final FacetKind kind;
  final List<FacetOption> options;
}

/// The chosen filters: values per facet, and the price range in whole
/// dirhams.
@immutable
final class SearchFilters {
  const SearchFilters({
    this.chosen = const <FacetKind, Set<String>>{},
    this.minPrice,
    this.maxPrice,
    this.quick = const <QuickFilter>{},
  });

  final Map<FacetKind, Set<String>> chosen;
  final int? minPrice;
  final int? maxPrice;
  final Set<QuickFilter> quick;

  bool get isEmpty =>
      chosen.values.every((ids) => ids.isEmpty) &&
      minPrice == null &&
      maxPrice == null &&
      quick.isEmpty;

  /// Chosen values in [kind], counting the price range as one.
  int countOf(FacetKind kind) => kind == FacetKind.price
      ? (minPrice != null || maxPrice != null ? 1 : 0) +
            (chosen[kind]?.length ?? 0)
      : chosen[kind]?.length ?? 0;

  /// Facets with anything chosen, for the Filters badge.
  int get facetCount =>
      FacetKind.values.where((kind) => countOf(kind) > 0).length;

  SearchFilters copyWith({
    Map<FacetKind, Set<String>>? chosen,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    Set<QuickFilter>? quick,
  }) => SearchFilters(
    chosen: chosen ?? this.chosen,
    minPrice: minPrice == null ? this.minPrice : minPrice(),
    maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
    quick: quick ?? this.quick,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchFilters &&
      mapEquals(other.chosen, chosen) &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      setEquals(other.quick, quick);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(
      chosen.entries.map(
        (e) => Object.hash(e.key, Object.hashAllUnordered(e.value)),
      ),
    ),
    minPrice,
    maxPrice,
    Object.hashAllUnordered(quick),
  );
}

/// How prices spread across the results, for the price filter.
@immutable
final class PriceSpread {
  const PriceSpread({
    required this.min,
    required this.max,
    required this.histogram,
  });

  /// Whole dirhams.
  final int min;
  final int max;

  /// How many results fall in each equal slice from [min] to [max].
  final List<int> histogram;
}

/// The products a query finds, with what helps when it finds few.
@immutable
final class SearchResults {
  const SearchResults({
    required this.query,
    required this.count,
    required this.products,
    required this.facets,
    required this.prices,
    this.store,
    this.didYouMean,
    this.browse,
    this.popular = const <String>[],
    this.recommended = const <Product>[],
  });

  final String query;
  final int count;
  final List<Product> products;
  final StoreHit? store;
  final List<Facet> facets;
  final PriceSpread prices;

  /// A spelling to try instead, when nothing matches.
  final String? didYouMean;

  /// The category to browse instead, when nothing matches.
  final ShopCategory? browse;
  final List<String> popular;
  final List<Product> recommended;
}
