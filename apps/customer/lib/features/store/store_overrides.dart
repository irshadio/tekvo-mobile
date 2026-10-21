import 'package:customer/features/store/data/repositories/store_repository_impl.dart';
import 'package:customer/features/store/domain/repositories/store_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the store contracts; aggregated in `app/run_app.dart`.
final List<Override> storeOverrides = <Override>[
  storeRepositoryProvider.overrideWith((ref) => const StoreRepositoryImpl()),
];
