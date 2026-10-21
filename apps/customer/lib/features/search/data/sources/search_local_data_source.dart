import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/search/data/sources/catalogue_local_data_source.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';

/// Stand-in until search is served: a small catalogue searched, filtered
/// and sorted here as the server will.
class SearchLocalDataSource {
  const SearchLocalDataSource();

  static const int _suggestionCount = 6;
  static const int _previewCount = 3;
  static const int _histogram = 16;

  SearchHome home() => SearchHome(
    recent: const <String>[
      'nova x pro',
      'noise cancelling headphones',
      'gaming laptop',
      'smart watch 44mm',
    ],
    trending: const <TrendingSearch>[
      TrendingSearch(
        query: 'foldable phones',
        note: '+240% this week',
        hot: true,
      ),
      TrendingSearch(query: '65 inch oled tv', note: 'Up to 30% off'),
      TrendingSearch(query: 'playcore 5 bundle', note: 'Back in stock'),
      TrendingSearch(query: 'wireless earbuds under 300'),
      TrendingSearch(query: '4k action camera'),
    ],
    recentlyViewed: <Product>[
      for (final item in catalogue)
        if (const <String>{
          'nova-x-pro',
          'pulse-anc-max',
          'arc-watch-s2',
          'snap-z5',
        }.contains(item.product.id))
          item.product,
    ],
  );

  Suggestions suggestions(String query) {
    final words = _words(query);
    final matches = _match(words);
    final names = <String>[];
    final suggestions = <Suggestion>[];
    for (final item in matches) {
      final name = item.short;
      if (names.contains(name)) continue;
      names.add(name);
      suggestions.add(Suggestion(query: name));
      if (suggestions.length == 1) {
        suggestions.add(
          Suggestion(
            query: name,
            category: item.category,
            categoryName: _categoryNames[item.category],
          ),
        );
      }
      if (suggestions.length >= _suggestionCount) break;
    }
    return Suggestions(
      query: query,
      suggestions: suggestions,
      store: _storeFor(words),
      products: <Product>[
        for (final item in matches.take(_previewCount)) item.product,
      ],
      total: matches.length,
    );
  }

  SearchResults results(
    String query, {
    required SearchSort sort,
    required SearchFilters filters,
  }) {
    var words = _words(query);
    final found = _match(words);
    final kept = found.where((item) => _keeps(item, filters)).toList();
    if (sort != SearchSort.relevance) {
      kept.sort((a, b) => _compare(sort, a, b));
    }
    String? didYouMean;
    ShopCategory? browse;
    if (found.isEmpty) {
      while (words.length > 1 && _match(words).isEmpty) {
        words = words.sublist(0, words.length - 1);
      }
      final near = _match(words);
      if (near.isNotEmpty) {
        didYouMean = words.join(' ');
        browse = near.first.category;
      }
    }
    return SearchResults(
      query: query,
      count: kept.length,
      products: <Product>[for (final item in kept) item.product],
      store: found.isEmpty ? null : _storeFor(_words(query)),
      facets: _facets(found),
      prices: _spread(found.isEmpty ? catalogue : found),
      didYouMean: didYouMean,
      browse: browse,
      popular: const <String>[
        'nova x pro',
        'foldable phones',
        'wireless earbuds',
        'smart watch',
      ],
      recommended: found.isEmpty
          ? <Product>[for (final item in catalogue.take(3)) item.product]
          : const <Product>[],
    );
  }

  static List<String> _words(String query) => query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  static List<CatalogueItem> _match(List<String> words) => <CatalogueItem>[
    for (final item in catalogue)
      if (words.isNotEmpty && words.every(item.text.contains)) item,
  ];

  static StoreHit? _storeFor(List<String> words) =>
      words.contains('nova') || words.any('nova'.startsWith)
      ? const StoreHit(
          brand: 'Nova',
          name: 'Nova Official Store',
          logo: Assets.storesNovaLogo,
          verified: true,
          productCount: 128,
          rating: 4.8,
        )
      : null;

  static bool _keeps(CatalogueItem item, SearchFilters filters) {
    final units = item.product.price.minor ~/ Money.minorPerUnit;
    bool chosen(FacetKind kind, bool Function(String id) test) {
      final ids = filters.chosen[kind] ?? const <String>{};
      return ids.isEmpty || ids.any(test);
    }

    return chosen(FacetKind.category, (id) => id == item.category.name) &&
        chosen(FacetKind.brand, (id) => id == item.brand) &&
        chosen(FacetKind.price, (id) => _priceRanges[id]!.contains(units)) &&
        chosen(
          FacetKind.rating,
          (id) => item.product.rating >= double.parse(id),
        ) &&
        chosen(FacetKind.storage, (id) => id == item.storage) &&
        chosen(FacetKind.colour, (id) => id == item.colour) &&
        chosen(
          FacetKind.delivery,
          (id) => id == 'free' ? item.freeDelivery : item.express,
        ) &&
        chosen(FacetKind.availability, (id) => item.inStock) &&
        chosen(FacetKind.discount, (id) => item.discount >= int.parse(id)) &&
        (filters.minPrice == null || units >= filters.minPrice!) &&
        (filters.maxPrice == null || units <= filters.maxPrice!) &&
        filters.quick.every(
          (quick) => switch (quick) {
            QuickFilter.underTwoThousand => units < 2000,
            QuickFilter.fourStarsUp => item.product.rating >= 4,
            QuickFilter.freeDelivery => item.freeDelivery,
            QuickFilter.inStock => item.inStock,
          },
        );
  }

  static int _compare(SearchSort sort, CatalogueItem a, CatalogueItem b) =>
      switch (sort) {
        SearchSort.relevance => 0,
        SearchSort.bestSelling => b.product.ratingCount.compareTo(
          a.product.ratingCount,
        ),
        SearchSort.priceLow => a.product.price.minor.compareTo(
          b.product.price.minor,
        ),
        SearchSort.priceHigh => b.product.price.minor.compareTo(
          a.product.price.minor,
        ),
        SearchSort.rating => b.product.rating.compareTo(a.product.rating),
        SearchSort.newest => a.age.compareTo(b.age),
        SearchSort.discount => b.discount.compareTo(a.discount),
      };

  static List<Facet> _facets(List<CatalogueItem> items) {
    List<FacetOption> count(
      Map<String, String> labels,
      bool Function(CatalogueItem item, String id) has,
    ) => <FacetOption>[
      for (final MapEntry(key: id, value: label) in labels.entries)
        if (items.any((item) => has(item, id)))
          FacetOption(
            id: id,
            label: label,
            count: items.where((item) => has(item, id)).length,
          ),
    ];
    return <Facet>[
      Facet(
        kind: FacetKind.category,
        options: count(<String, String>{
          for (final MapEntry(key: category, value: name)
              in _categoryNames.entries)
            category.name: name,
        }, (item, id) => item.category.name == id),
      ),
      Facet(
        kind: FacetKind.brand,
        options: count(<String, String>{
          for (final item in catalogue) item.brand: item.brand,
        }, (item, id) => item.brand == id),
      ),
      Facet(
        kind: FacetKind.price,
        options: count(
          <String, String>{
            for (final MapEntry(key: id, value: range) in _priceRanges.entries)
              id: range.label,
          },
          (item, id) {
            final units = item.product.price.minor ~/ Money.minorPerUnit;
            return _priceRanges[id]!.contains(units);
          },
        ),
      ),
      Facet(
        kind: FacetKind.rating,
        options: count(const <String, String>{
          '4.5': '4.5★ & up',
          '4': '4★ & up',
          '3': '3★ & up',
        }, (item, id) => item.product.rating >= double.parse(id)),
      ),
      Facet(
        kind: FacetKind.storage,
        options: count(const <String, String>{
          '128 GB': '128 GB',
          '256 GB': '256 GB',
          '512 GB': '512 GB',
        }, (item, id) => item.storage == id),
      ),
      Facet(
        kind: FacetKind.colour,
        options: count(const <String, String>{
          'Black': 'Black',
          'White': 'White',
          'Blue': 'Blue',
          'Silver': 'Silver',
        }, (item, id) => item.colour == id),
      ),
      Facet(
        kind: FacetKind.delivery,
        options: count(
          const <String, String>{
            'free': 'Free delivery',
            'express': 'Express in 1 hour',
          },
          (item, id) => id == 'free' ? item.freeDelivery : item.express,
        ),
      ),
      Facet(
        kind: FacetKind.availability,
        options: count(const <String, String>{
          'in-stock': 'In stock',
        }, (item, id) => item.inStock),
      ),
      Facet(
        kind: FacetKind.discount,
        options: count(const <String, String>{
          '10': '10% off or more',
          '20': '20% off or more',
          '30': '30% off or more',
        }, (item, id) => item.discount >= int.parse(id)),
      ),
    ];
  }

  static PriceSpread _spread(List<CatalogueItem> items) {
    final prices = <int>[
      for (final item in items) item.product.price.minor ~/ Money.minorPerUnit,
    ]..sort();
    final min = prices.first;
    final max = prices.last;
    final slice = ((max - min) / _histogram).ceil().clamp(1, 1 << 30);
    final histogram = List<int>.filled(_histogram, 0);
    for (final price in prices) {
      histogram[((price - min) ~/ slice).clamp(0, _histogram - 1)]++;
    }
    return PriceSpread(min: min, max: max, histogram: histogram);
  }
}

/// A popular price range in whole dirhams; [to] is exclusive.
final class _Range {
  const _Range(this.label, this.from, this.to);

  final String label;
  final int from;
  final int? to;

  bool contains(int units) => units >= from && (to == null || units < to!);
}

const Map<String, _Range> _priceRanges = <String, _Range>{
  'under-1000': _Range('Under AED 1,000', 0, 1000),
  '1000-2000': _Range('AED 1,000 – 2,000', 1000, 2000),
  '2000-4000': _Range('AED 2,000 – 4,000', 2000, 4000),
  'over-4000': _Range('Above AED 4,000', 4000, null),
};

const Map<ShopCategory, String> _categoryNames = <ShopCategory, String>{
  ShopCategory.phones: 'Phones',
  ShopCategory.laptops: 'Tablets & PCs',
  ShopCategory.audio: 'Audio',
  ShopCategory.watches: 'Wearables',
  ShopCategory.cameras: 'Cameras',
  ShopCategory.gaming: 'Gaming',
  ShopCategory.speakers: 'Speakers',
};
