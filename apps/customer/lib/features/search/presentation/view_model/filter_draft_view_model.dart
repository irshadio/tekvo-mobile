import 'dart:async';

import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_draft_view_model.g.dart';

/// Filters being chosen, the facet on show, and how many results they
/// would keep.
@immutable
final class FilterDraft {
  const FilterDraft({
    required this.filters,
    this.facet = FacetKind.price,
    this.matching,
  });

  final SearchFilters filters;
  final FacetKind facet;

  /// Null while it is being counted.
  final int? matching;
}

/// The filters screen's draft for a search; nothing changes the results
/// until it is applied.
@riverpod
class FilterDraftViewModel extends _$FilterDraftViewModel {
  @override
  FilterDraft build(String query) =>
      const FilterDraft(filters: SearchFilters());

  /// Starts from the filters in use.
  void start(SearchFilters filters) {
    state = FilterDraft(filters: filters, facet: state.facet);
    unawaited(_count());
  }

  void show(FacetKind facet) => state = FilterDraft(
    filters: state.filters,
    facet: facet,
    matching: state.matching,
  );

  void toggle(FacetKind kind, String id) {
    final chosen = state.filters.chosen[kind] ?? const <String>{};
    _set(
      state.filters.copyWith(
        chosen: <FacetKind, Set<String>>{
          ...state.filters.chosen,
          kind: chosen.contains(id)
              ? (Set<String>.of(chosen)..remove(id))
              : <String>{...chosen, id},
        },
      ),
    );
  }

  void price(int? min, int? max) =>
      _set(state.filters.copyWith(minPrice: () => min, maxPrice: () => max));

  void clear() => _set(const SearchFilters());

  void _set(SearchFilters filters) {
    state = FilterDraft(filters: filters, facet: state.facet);
    unawaited(_count());
  }

  Future<void> _count() async {
    final asked = state.filters;
    final result = await ref
        .read(searchRepositoryProvider)
        .results(query, sort: SearchSort.relevance, filters: asked);
    if (!ref.mounted || state.filters != asked) return;
    state = FilterDraft(
      filters: asked,
      facet: state.facet,
      matching: result.fold((_) => null, (results) => results.count),
    );
  }
}
