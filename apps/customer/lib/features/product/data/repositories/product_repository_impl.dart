import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/error/failure.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the catalogue is served: every product shows the
/// design's sample, the Nova X Pro.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl();

  @override
  Future<Either<Failure, ProductDetails>> details(String id) async =>
      right(sample);

  static const ProductDetails sample = ProductDetails(
    id: 'nova-x-pro',
    title: 'Nova X Pro 5G · 256 GB, 12 GB RAM · Titanium Black',
    store: 'Nova',
    officialStore: true,
    images: <String>[
      Assets.productsNovaXPro,
      Assets.productsNovaSLite,
      Assets.productsNovaXPro,
      Assets.productsNovaSLite,
      Assets.productsNovaXPro,
      Assets.productsNovaSLite,
    ],
    tags: <ProductTag>[SaleTag(12), BestsellerTag()],
    rating: 4.7,
    ratingCount: 2318,
    soldThisWeek: 1200,
    price: Money.units(3499),
    was: Money.units(3999),
    saving: Money.units(500),
    instalments: Instalments(count: 4, amount: Money(87475)),
    coupon: Coupon(
      title: 'Extra AED 150 off',
      detail: 'Code TEKVO150 · orders above AED 2,000',
    ),
    freeDelivery: true,
  );
}
