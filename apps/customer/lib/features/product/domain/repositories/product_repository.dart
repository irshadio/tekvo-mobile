import 'package:core/error/failure.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository.g.dart';

/// Serves a product's details and the screens they open.
abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetails>> details(String id);

  Future<Either<Failure, ProductSpecifications>> specifications(String id);

  /// The first [pages] pages of reviews that [filter] keeps, in [sort]
  /// order.
  Future<Either<Failure, ReviewsPage>> reviews(
    String id, {
    required ReviewFilter filter,
    required ReviewSort sort,
    required int pages,
  });
}

/// Bound in `product_overrides.dart`.
@riverpod
ProductRepository productRepository(Ref ref) => throw UnimplementedError(
  'productRepositoryProvider must be overridden; see product_overrides.dart.',
);
