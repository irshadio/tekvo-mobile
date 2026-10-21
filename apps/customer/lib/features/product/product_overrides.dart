import 'package:customer/features/product/data/repositories/product_repository_impl.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the product contracts; aggregated in `app/run_app.dart`.
final List<Override> productOverrides = <Override>[
  productRepositoryProvider.overrideWith(
    (ref) => const ProductRepositoryImpl(),
  ),
];
