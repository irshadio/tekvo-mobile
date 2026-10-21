import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/utils/money.dart';

/// A catalogue entry with what search filters on.
final class CatalogueItem {
  const CatalogueItem(
    this.product, {
    required this.brand,
    required this.category,
    required this.age,
    this.storage,
    this.colour,
    this.freeDelivery = true,
    this.express = false,
    this.inStock = true,
  });

  final Product product;
  final String brand;
  final ShopCategory category;

  /// Days since it arrived.
  final int age;
  final String? storage;
  final String? colour;
  final bool freeDelivery;
  final bool express;
  final bool inStock;

  /// What a query is matched against.
  String get text => '${product.name} $brand ${category.name}'.toLowerCase();

  /// The name without its options, as a search: `nova x pro 5g`.
  String get short => product.name.split(' · ').first.toLowerCase();

  int get discount {
    final was = product.was;
    return was == null
        ? 0
        : ((was.minor - product.price.minor) * 100 / was.minor).round();
  }
}

/// The stand-in catalogue, most relevant first.
const List<CatalogueItem> catalogue = <CatalogueItem>[
  CatalogueItem(
    Product(
      id: 'nova-x-pro',
      name: 'Nova X Pro 5G · 256GB',
      image: Assets.productsNovaXPro,
      price: Money.units(3499),
      was: Money.units(3999),
      rating: 4.7,
      ratingCount: 2300,
      tag: SaleTag(12),
    ),
    brand: 'Nova',
    category: ShopCategory.phones,
    age: 30,
    storage: '256 GB',
    colour: 'Black',
    express: true,
  ),
  CatalogueItem(
    Product(
      id: 'nova-s-lite',
      name: 'Nova S Lite · 128GB',
      image: Assets.productsNovaSLite,
      price: Money.units(1499),
      rating: 4.6,
      ratingCount: 980,
      tag: BestsellerTag(),
    ),
    brand: 'Nova',
    category: ShopCategory.phones,
    age: 120,
    storage: '128 GB',
    colour: 'White',
  ),
  CatalogueItem(
    Product(
      id: 'nova-tab-11',
      name: 'Nova Tab 11 · Wi-Fi',
      image: Assets.productsSlateTab11,
      price: Money.units(2299),
      was: Money.units(2499),
      rating: 4.7,
      ratingCount: 640,
      tag: SaleTag(8),
    ),
    brand: 'Nova',
    category: ShopCategory.laptops,
    age: 60,
    storage: '128 GB',
    colour: 'Silver',
  ),
  CatalogueItem(
    Product(
      id: 'nova-buds-3-pro',
      name: 'Nova Buds 3 Pro · ANC',
      image: Assets.productsBudsAir3,
      price: Money.units(449),
      was: Money.units(549),
      rating: 4.5,
      ratingCount: 1800,
      tag: SaleTag(18),
    ),
    brand: 'Nova',
    category: ShopCategory.audio,
    age: 45,
    colour: 'Black',
    express: true,
  ),
  CatalogueItem(
    Product(
      id: 'nova-watch-5',
      name: 'Nova Watch 5 · 44mm',
      image: Assets.productsArcWatchS2,
      price: Money.units(1249),
      rating: 4.6,
      ratingCount: 720,
    ),
    brand: 'Nova',
    category: ShopCategory.watches,
    age: 20,
    colour: 'Black',
  ),
  CatalogueItem(
    Product(
      id: 'nova-book-14',
      name: 'Nova Book 14 · 16GB',
      image: Assets.productsAeroBookPro,
      price: Money.units(4999),
      was: Money.units(5499),
      rating: 4.8,
      ratingCount: 310,
      tag: SaleTag(9),
    ),
    brand: 'Nova',
    category: ShopCategory.laptops,
    age: 10,
    storage: '512 GB',
    colour: 'Silver',
  ),
  CatalogueItem(
    Product(
      id: 'pulse-anc-max',
      name: 'Pulse ANC Max Headphones',
      image: Assets.productsPulseAncMax,
      price: Money.units(1099),
      was: Money.units(1399),
      rating: 4.8,
      ratingCount: 3200,
      tag: SaleTag(21),
    ),
    brand: 'Pulse',
    category: ShopCategory.audio,
    age: 90,
    colour: 'Black',
  ),
  CatalogueItem(
    Product(
      id: 'pulse-studio',
      name: 'Pulse Studio Wireless',
      image: Assets.productsPulseStudio,
      price: Money.units(649),
      rating: 4.7,
      ratingCount: 1800,
      tag: BestsellerTag(),
    ),
    brand: 'Pulse',
    category: ShopCategory.audio,
    age: 150,
    colour: 'White',
  ),
  CatalogueItem(
    Product(
      id: 'arc-watch-s2',
      name: 'Arc Watch S2',
      image: Assets.productsArcWatchS2,
      price: Money.units(1299),
      rating: 4.7,
      ratingCount: 2000,
    ),
    brand: 'Arc',
    category: ShopCategory.watches,
    age: 75,
    colour: 'Black',
  ),
  CatalogueItem(
    Product(
      id: 'snap-z5',
      name: 'Snap Z5 Kit',
      image: Assets.productsSnapZ5,
      price: Money.units(4299),
      rating: 4.8,
      ratingCount: 410,
    ),
    brand: 'Snap',
    category: ShopCategory.cameras,
    age: 25,
    colour: 'Black',
    inStock: false,
  ),
  CatalogueItem(
    Product(
      id: 'playcore-5',
      name: 'PlayCore 5 Bundle',
      image: Assets.productsPlaycore5,
      price: Money.units(2199),
      was: Money.units(2499),
      rating: 4.9,
      ratingCount: 5100,
      tag: SaleTag(12),
    ),
    brand: 'PlayCore',
    category: ShopCategory.gaming,
    age: 5,
    colour: 'White',
  ),
  CatalogueItem(
    Product(
      id: 'boom-go',
      name: 'Boom Go Speaker',
      image: Assets.productsBoomGo,
      price: Money.units(199),
      rating: 4.4,
      ratingCount: 860,
    ),
    brand: 'Boom',
    category: ShopCategory.speakers,
    age: 200,
    colour: 'Blue',
    freeDelivery: false,
  ),
];
