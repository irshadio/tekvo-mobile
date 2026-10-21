import 'package:core/error/failure.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_repository.g.dart';

/// Serves a brand's store.
abstract interface class StoreRepository {
  /// The store of [brand], its products in [sort] order.
  Future<Either<Failure, Store>> store(String brand, {required StoreSort sort});

  Future<Either<Failure, Unit>> follow(String storeId, {required bool on});

  Future<Either<Failure, Unit>> collectCoupon(String storeId, String couponId);
}

/// Bound in `store_overrides.dart`.
@riverpod
StoreRepository storeRepository(Ref ref) => throw UnimplementedError(
  'storeRepositoryProvider must be overridden; see store_overrides.dart.',
);
