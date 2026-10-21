import 'package:core/error/failure.dart';
import 'package:customer/features/search/data/sources/search_local_data_source.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Serves search from the stand-in catalogue until search is served.
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({this._local = const SearchLocalDataSource()});

  final SearchLocalDataSource _local;

  @override
  Future<Either<Failure, SearchHome>> home() async => right(_local.home());

  @override
  Future<Either<Failure, Suggestions>> suggestions(String query) async =>
      right(_local.suggestions(query));

  @override
  Future<Either<Failure, SearchResults>> results(
    String query, {
    required SearchSort sort,
    required SearchFilters filters,
  }) async => right(_local.results(query, sort: sort, filters: filters));
}
