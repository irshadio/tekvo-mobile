import 'package:core/error/failure.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_repository.g.dart';

/// Serves search: what to show before typing, suggestions while typing,
/// and results.
abstract interface class SearchRepository {
  Future<Either<Failure, SearchHome>> home();

  Future<Either<Failure, Suggestions>> suggestions(String query);

  Future<Either<Failure, SearchResults>> results(
    String query, {
    required SearchSort sort,
    required SearchFilters filters,
  });
}

/// Bound in `search_overrides.dart`.
@riverpod
SearchRepository searchRepository(Ref ref) => throw UnimplementedError(
  'searchRepositoryProvider must be overridden; see search_overrides.dart.',
);
