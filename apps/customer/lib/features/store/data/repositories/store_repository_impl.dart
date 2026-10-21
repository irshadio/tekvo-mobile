import 'package:core/error/failure.dart';
import 'package:customer/features/store/data/sources/store_local_data_source.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/features/store/domain/repositories/store_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Serves stores from the stand-in source until they are served.
class StoreRepositoryImpl implements StoreRepository {
  const StoreRepositoryImpl({this._local = const StoreLocalDataSource()});

  final StoreLocalDataSource _local;

  @override
  Future<Either<Failure, Store>> store(
    String brand, {
    required StoreSort sort,
  }) async => right(_local.store(brand, sort: sort));

  @override
  Future<Either<Failure, Unit>> follow(
    String storeId, {
    required bool on,
  }) async => right(unit);

  @override
  Future<Either<Failure, Unit>> collectCoupon(
    String storeId,
    String couponId,
  ) async => right(unit);
}
