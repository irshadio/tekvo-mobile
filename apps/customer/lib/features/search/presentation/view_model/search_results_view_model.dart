import 'dart:async';

import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_results_view_model.g.dart';

/// The results' order and filters.
@immutable
final class ResultsQuery {
  const ResultsQuery({
    this.sort = SearchSort.relevance,
    this.filters = const SearchFilters(),
  });

  final SearchSort sort;
  final SearchFilters filters;

  @override
  bool operator ==(Object other) =>
      other is ResultsQuery && other.sort == sort && other.filters == filters;

  @override
  int get hashCode => Object.hash(sort, filters);
}

/// A search's sort and filters.
@riverpod
class ResultsQueryViewModel extends _$ResultsQueryViewModel {
  @override
  ResultsQuery build(String query) => const ResultsQuery();

  void sort(SearchSort sort) =>
      state = ResultsQuery(sort: sort, filters: state.filters);

  void filter(SearchFilters filters) =>
      state = ResultsQuery(sort: state.sort, filters: filters);

  void toggleQuick(QuickFilter quick) {
    final chosen = state.filters.quick;
    filter(
      state.filters.copyWith(
        quick: chosen.contains(quick)
            ? (Set<QuickFilter>.of(chosen)..remove(quick))
            : <QuickFilter>{...chosen, quick},
      ),
    );
  }
}

/// A search's results, fetched again whenever its sort or filters change.
@riverpod
class SearchResultsViewModel extends _$SearchResultsViewModel
    with RemoteStateMixin<SearchResults> {
  @override
  ViewState<SearchResults> build(String query) {
    ref.listen(
      resultsQueryViewModelProvider(query),
      (_, _) => unawaited(load()),
    );
    return const ViewState.idle();
  }

  Future<void> load() {
    final current = ref.read(resultsQueryViewModelProvider(query));
    return runRequest(
      () => ref
          .read(searchRepositoryProvider)
          .results(query, sort: current.sort, filters: current.filters),
    );
  }
}
