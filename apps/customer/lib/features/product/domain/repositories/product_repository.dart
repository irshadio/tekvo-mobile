import 'package:core/error/failure.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository.g.dart';

/// Serves a product's details.
// A contract, bound per build in the overrides.
// ignore: one_member_abstracts
abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetails>> details(String id);
}

/// Bound in `product_overrides.dart`.
@riverpod
ProductRepository productRepository(Ref ref) => throw UnimplementedError(
  'productRepositoryProvider must be overridden; see product_overrides.dart.',
);
