import 'package:customer/features/search/data/repositories/search_repository_impl.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the search contracts; aggregated in `app/run_app.dart`.
final List<Override> searchOverrides = <Override>[
  searchRepositoryProvider.overrideWith((ref) => const SearchRepositoryImpl()),
];
