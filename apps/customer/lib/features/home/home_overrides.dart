import 'package:customer/features/home/data/repositories/home_repository_impl.dart';
import 'package:customer/features/home/domain/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the home contracts; aggregated in `app/run_app.dart`.
final List<Override> homeOverrides = <Override>[
  homeRepositoryProvider.overrideWith((ref) => const HomeRepositoryImpl()),
];
