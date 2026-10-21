import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/product/domain/entities/product_bundle.dart';
import 'package:customer/features/product/domain/entities/product_delivery.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/entities/product_options.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/domain/entities/product_specs.dart';

/// Stand-in until the catalogue is served: every product is the design's
/// sample, the Nova X Pro.
class ProductLocalDataSource {
  const ProductLocalDataSource();

  ProductDetails details(String id) => _novaXPro;

  ProductSpecifications specifications(String id) => _novaXProSpecs;
}

/// The design's sample product, the Nova X Pro.
final ProductDetails _novaXPro = ProductDetails(
  id: 'nova-x-pro',
  title: 'Nova X Pro 5G · 256 GB, 12 GB RAM · Titanium Black',
  store: 'Nova',
  officialStore: true,
  images: const <String>[
    Assets.productsNovaXPro,
    Assets.productsNovaSLite,
    Assets.productsNovaXPro,
    Assets.productsNovaSLite,
    Assets.productsNovaXPro,
    Assets.productsNovaSLite,
  ],
  tags: const <ProductTag>[SaleTag(12), BestsellerTag()],
  rating: 4.7,
  ratingCount: 2318,
  soldThisWeek: 1200,
  price: const Money.units(3499),
  was: const Money.units(3999),
  saving: const Money.units(500),
  instalments: const Instalments(count: 4, amount: Money(87475)),
  coupon: const Coupon(
    title: 'Extra AED 150 off',
    detail: 'Code TEKVO150 · orders above AED 2,000',
  ),
  freeDelivery: true,
  options: const <ProductOptionGroup>[
    ProductOptionGroup(
      name: 'Colour',
      options: <ProductOption>[
        ProductOption(name: 'Titanium Black', swatch: 0xFF2B2D31),
        ProductOption(name: 'Desert Sand', swatch: 0xFFBDB6AA),
        ProductOption(name: 'Ocean Blue', swatch: 0xFF34466B),
        ProductOption(name: 'Pearl White', swatch: 0xFFECEAE5),
      ],
    ),
    ProductOptionGroup(
      name: 'Storage',
      chosen: 1,
      options: <ProductOption>[
        ProductOption(name: '128 GB', price: Money.units(3099)),
        ProductOption(name: '256 GB', price: Money.units(3499)),
        ProductOption(name: '512 GB', soldOut: true),
      ],
    ),
  ],
  stockLeft: 4,
  bundle: const Bundle(
    items: <BundleItem>[
      BundleItem(
        id: 'nova-x-pro',
        name: 'Nova X Pro 5G · 256 GB',
        image: Assets.productsNovaXPro,
        price: Money.units(3499),
      ),
      BundleItem(
        id: 'buds-air-3',
        name: 'Buds Air 3 · ANC',
        image: Assets.productsBudsAir3,
        price: Money.units(449),
      ),
      BundleItem(
        id: 'arc-watch-s2',
        name: 'Arc Watch S2 · 44mm',
        image: Assets.productsArcWatchS2,
        price: Money.units(1249),
      ),
    ],
    total: Money.units(5047),
    saving: Money.units(150),
  ),
  delivery: const Delivery(
    recipient: 'Sam',
    place: 'Dubai Marina, Dubai',
    options: <DeliveryOption>[
      DeliveryOption(
        speed: DeliverySpeed.standard,
        highlight: 'FREE delivery',
        title: 'tomorrow, 21 Oct',
        detail: 'Order within 3 h 12 min',
      ),
      DeliveryOption(
        speed: DeliverySpeed.express,
        title: 'Express in 1 hour · AED 25',
        detail: 'Free with Tekvo Plus · order within 1 h 40 min',
      ),
    ],
    returnDays: 15,
    warrantyYears: 2,
    seller: 'Tekvo',
    fulfiller: 'Tekvo',
  ),
  protection: const <ProtectionPlan>[
    ProtectionPlan(
      id: 'care-accidental',
      title: 'Care+ Accidental damage · 1 year',
      detail: 'Drops, spills and cracked screens',
      price: Money.units(199),
    ),
    ProtectionPlan(
      id: 'care-extended',
      title: 'Care+ Extended warranty · +1 year',
      detail: 'Repairs after the 2-year warranty ends',
      price: Money.units(129),
    ),
  ],
  highlights: const <Highlight>[
    Highlight(
      kind: HighlightKind.display,
      label: 'Display',
      value: '6.7" 120 Hz OLED',
    ),
    Highlight(
      kind: HighlightKind.camera,
      label: 'Camera',
      value: '200 MP triple',
    ),
    Highlight(
      kind: HighlightKind.battery,
      label: 'Battery',
      value: '5,000 mAh',
    ),
    Highlight(
      kind: HighlightKind.connectivity,
      label: 'Connectivity',
      value: '5G · Wi-Fi 7',
    ),
  ],
  specs: const <Spec>[
    Spec(label: 'Processor', value: 'Octa-core, 3.3 GHz'),
    Spec(label: 'Memory', value: '12 GB RAM · 256 GB'),
    Spec(label: 'Software', value: 'Android 15'),
    Spec(label: 'Weight', value: '205 g'),
    Spec(label: 'In the box', value: 'Phone, USB-C cable, SIM tool'),
  ],
  reviews: Reviews(
    shares: const <int>[78, 14, 4, 2, 2],
    mentions: const <ReviewMention>[
      ReviewMention(
        label: 'With photos',
        count: 186,
        filter: ReviewFilter.withPhotos,
      ),
      ReviewMention(label: 'Battery', count: 412),
      ReviewMention(label: 'Camera', count: 365),
      ReviewMention(label: 'Display', count: 298),
    ],
    top: <Review>[
      Review(
        id: 'r-ahmed',
        author: 'Ahmed K.',
        variant: '256 GB',
        date: DateTime.utc(2026, 10, 12),
        stars: 5,
        headline: 'Two days on one charge',
        body:
            'Battery easily lasts two days with heavy use. The camera is '
            'sharp in low light and the screen is bright outdoors.',
        helpful: 24,
      ),
      Review(
        id: 'r-priya',
        author: 'Priya N.',
        variant: '512 GB',
        date: DateTime.utc(2026, 10, 8),
        stars: 5,
        headline: 'Fast delivery, great screen',
        body:
            'Arrived next morning in Dubai Marina. Smooth 120 Hz display '
            'and the 65 W charger fills it in about 40 minutes.',
        helpful: 17,
      ),
    ],
    total: 642,
  ),
  questions: const Questions(
    top: <ProductQuestion>[
      ProductQuestion(
        question: 'Does it support dual eSIM?',
        answer: 'Yes. You can use two eSIMs, or one nano-SIM with one eSIM.',
        answeredBy: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 12,
      ),
      ProductQuestion(
        question: 'Is a charger included in the box?',
        answer:
            'No, the box has a USB-C cable only. The 65 W charger is sold '
            'separately for AED 129.',
        answeredBy: 'Ahmed K.',
        by: AnswerBy.buyer,
        helpful: 9,
      ),
    ],
    total: 38,
  ),
  alsoViewed: const <Product>[
    Product(
      id: 'nova-s-lite',
      name: 'Nova S Lite · 128GB',
      image: Assets.productsNovaSLite,
      price: Money.units(1499),
      rating: 4.6,
      ratingCount: 980,
      tag: BestsellerTag(),
    ),
    Product(
      id: 'slate-tab-11',
      name: 'Slate Tab 11 · Wi-Fi',
      image: Assets.productsSlateTab11,
      price: Money.units(2299),
      rating: 4.7,
      ratingCount: 640,
      tag: FreeDeliveryTag(),
    ),
    Product(
      id: 'pulse-studio',
      name: 'Pulse Studio Wireless',
      image: Assets.productsPulseStudio,
      price: Money.units(649),
      rating: 4.7,
      ratingCount: 1800,
      tag: BestsellerTag(),
    ),
    Product(
      id: 'buds-air-3',
      name: 'Buds Air 3 · ANC',
      image: Assets.productsBudsAir3,
      price: Money.units(399),
      was: Money.units(499),
      rating: 4.6,
      ratingCount: 1100,
      tag: SaleTag(20),
    ),
  ],
);

const ProductSpecifications _novaXProSpecs = ProductSpecifications(
  id: 'nova-x-pro',
  name: 'Nova X Pro 5G',
  variant: '256 GB, 12 GB RAM · Titanium Black',
  image: Assets.productsNovaXPro,
  rating: 4.7,
  ratingCount: 2318,
  price: Money.units(3499),
  freeDelivery: true,
  overview:
      'Nova X Pro 5G pairs a 6.7-inch 120 Hz LTPO display with a 200 MP '
      'triple camera and an all-day 5,000 mAh battery. A titanium frame '
      'keeps it light at 205 g, and 65 W charging gets you to 50% in 15 '
      'minutes.',
  features: <String>[
    '200 MP main camera with 5× optical zoom',
    'Brightest Nova display yet: 2,600 nits peak',
    'IP68 water and dust resistance',
    '7 years of software updates',
  ],
  groups: <SpecGroup>[
    SpecGroup(
      kind: SpecGroupKind.general,
      title: 'General',
      rows: <Spec>[
        Spec(label: 'Brand', value: 'Nova'),
        Spec(label: 'Model', value: 'NX-P256 · 2026'),
        Spec(label: 'Software', value: 'Android 15 · 7 years of updates'),
        Spec(label: 'SIM', value: 'Dual nano-SIM + eSIM'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.display,
      title: 'Display',
      chip: 'Display',
      rows: <Spec>[
        Spec(label: 'Size', value: '6.7 inches'),
        Spec(label: 'Type', value: 'LTPO OLED, 1–120 Hz'),
        Spec(label: 'Resolution', value: '1440 × 3120 px'),
        Spec(label: 'Brightness', value: '2,600 nits peak'),
        Spec(label: 'Protection', value: 'Armor glass, front and back'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.performance,
      title: 'Performance',
      chip: 'Performance',
      rows: <Spec>[
        Spec(label: 'Processor', value: 'Octa-core 3.3 GHz, 3 nm'),
        Spec(label: 'Memory', value: '12 GB RAM'),
        Spec(label: 'Storage', value: '256 GB UFS 4.0'),
        Spec(label: 'Expandable', value: 'No'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.camera,
      title: 'Camera',
      chip: 'Camera',
      rows: <Spec>[
        Spec(label: 'Main', value: '200 MP, f/1.7, OIS'),
        Spec(label: 'Ultra-wide', value: '50 MP, 120°'),
        Spec(label: 'Telephoto', value: '12 MP, 5× optical'),
        Spec(label: 'Front', value: '32 MP, autofocus'),
        Spec(label: 'Video', value: '8K 30 fps · 4K 120 fps'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.battery,
      title: 'Battery & charging',
      chip: 'Battery',
      rows: <Spec>[
        Spec(label: 'Capacity', value: '5,000 mAh'),
        Spec(label: 'Wired', value: '65 W · 50% in 15 min'),
        Spec(label: 'Wireless', value: '15 W · 5 W reverse'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.connectivity,
      title: 'Connectivity',
      rows: <Spec>[
        Spec(label: 'Network', value: '5G, 4G LTE'),
        Spec(label: 'Wi-Fi', value: 'Wi-Fi 7'),
        Spec(label: 'Bluetooth', value: '5.4'),
        Spec(label: 'NFC', value: 'Yes'),
        Spec(label: 'Port', value: 'USB-C 3.2'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.design,
      title: 'Design',
      chip: 'Design',
      rows: <Spec>[
        Spec(label: 'Dimensions', value: '162.3 × 76.8 × 8.2 mm'),
        Spec(label: 'Weight', value: '205 g'),
        Spec(label: 'Frame', value: 'Titanium'),
        Spec(label: 'Rating', value: 'IP68'),
      ],
    ),
    SpecGroup(
      kind: SpecGroupKind.inTheBox,
      title: 'In the box & warranty',
      rows: <Spec>[
        Spec(label: 'In the box', value: 'Phone, USB-C cable, SIM tool'),
        Spec(label: 'Warranty', value: '2 years, Nova UAE'),
        Spec(label: 'Returns', value: '15 days, free pickup'),
      ],
    ),
  ],
);
