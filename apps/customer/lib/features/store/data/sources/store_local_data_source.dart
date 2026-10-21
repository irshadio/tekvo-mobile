import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/catalog/promo.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/store/domain/entities/store.dart';

/// Stand-in until stores are served: every brand opens the design's Nova
/// store, its products sorted here as the server will.
class StoreLocalDataSource {
  const StoreLocalDataSource();

  Store store(String brand, {required StoreSort sort}) => Store(
    id: 'nova',
    brand: 'Nova',
    name: 'Nova Official Store',
    about: 'Phones, tablets, audio & wearables · Partner since 2019',
    cover: Assets.storesNovaCover,
    logo: Assets.storesNovaLogo,
    verified: true,
    rating: 4.8,
    positive: 98,
    followers: 126000,
    shipsWithinHours: 24,
    coupons: const <StoreCoupon>[
      StoreCoupon(
        id: 'nova-100',
        title: 'AED 100 off',
        detail: 'Orders over AED 1,500',
      ),
      StoreCoupon(
        id: 'nova-40',
        title: 'AED 40 off',
        detail: 'Audio over AED 400',
      ),
      StoreCoupon(
        id: 'nova-express',
        title: 'Free express',
        detail: 'All Nova phones',
        collected: true,
      ),
    ],
    promo: const Promo(
      id: 'nova-week',
      style: PromoStyle.newArrival,
      eyebrow: 'NOVA WEEK',
      title: 'Nova Week: up to 20% off',
      image: Assets.productsSlateTab11,
      action: 'Shop the sale',
    ),
    categories: const <StoreCategory>[
      StoreCategory(label: 'Phones', category: ShopCategory.phones),
      StoreCategory(label: 'Tablets & PCs', category: ShopCategory.laptops),
      StoreCategory(label: 'Audio', category: ShopCategory.audio),
      StoreCategory(label: 'Wearables', category: ShopCategory.watches),
    ],
    bestSellers: const <Product>[_xPro, _buds, _watch, _sLite],
    products: _sorted(sort),
    productCount: 128,
  );

  static List<Product> _sorted(StoreSort sort) => switch (sort) {
    StoreSort.popular => _all,
    StoreSort.newArrivals => const <Product>[
      _book,
      _tab,
      _xPro,
      _pulse,
      _watch,
      _buds,
    ],
    StoreSort.priceLow => List<Product>.of(
      _all,
    )..sort((a, b) => a.price.minor.compareTo(b.price.minor)),
    StoreSort.onSale => <Product>[
      for (final product in _all)
        if (product.onSale) product,
    ],
  };
}

const List<Product> _all = <Product>[_xPro, _tab, _book, _pulse, _buds, _watch];

const Product _xPro = Product(
  id: 'nova-x-pro',
  name: 'Nova X Pro 5G · 256GB',
  image: Assets.productsNovaXPro,
  price: Money.units(3499),
  was: Money.units(3999),
  rating: 4.7,
  ratingCount: 2300,
  tag: SaleTag(12),
);

const Product _buds = Product(
  id: 'nova-buds-3-pro',
  name: 'Nova Buds 3 Pro · ANC',
  image: Assets.productsBudsAir3,
  price: Money.units(449),
  was: Money.units(549),
  rating: 4.5,
  ratingCount: 1800,
  tag: SaleTag(18),
);

const Product _watch = Product(
  id: 'nova-watch-5',
  name: 'Nova Watch 5 · 44mm',
  image: Assets.productsArcWatchS2,
  price: Money.units(1249),
  rating: 4.6,
  ratingCount: 720,
);

const Product _sLite = Product(
  id: 'nova-s-lite',
  name: 'Nova S Lite · 128GB',
  image: Assets.productsNovaSLite,
  price: Money.units(1499),
  rating: 4.6,
  ratingCount: 980,
);

const Product _tab = Product(
  id: 'nova-tab-11',
  name: 'Nova Tab 11 · Wi-Fi',
  image: Assets.productsSlateTab11,
  price: Money.units(2299),
  was: Money.units(2499),
  rating: 4.7,
  ratingCount: 640,
  tag: SaleTag(8),
);

const Product _book = Product(
  id: 'nova-book-14',
  name: 'Nova Book 14 · 16GB',
  image: Assets.productsAeroBookPro,
  price: Money.units(4999),
  was: Money.units(5499),
  rating: 4.8,
  ratingCount: 310,
  tag: SaleTag(9),
);

const Product _pulse = Product(
  id: 'nova-pulse-anc',
  name: 'Nova Pulse ANC',
  image: Assets.productsPulseAncMax,
  price: Money.units(899),
  rating: 4.4,
  ratingCount: 430,
);
