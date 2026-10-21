import 'package:core/error/failure.dart';
import 'package:customer/features/product/data/sources/product_local_data_source.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Serves products from the stand-in source until the catalogue is served.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl([this._local = const ProductLocalDataSource()]);

  final ProductLocalDataSource _local;

  @override
  Future<Either<Failure, ProductDetails>> details(String id) async =>
      right(_local.details(id));

  @override
  Future<Either<Failure, ProductSpecifications>> specifications(
    String id,
  ) async => right(_local.specifications(id));

  /// The sample product every id shows.
  static ProductDetails get sample =>
      const ProductLocalDataSource().details('');
}
