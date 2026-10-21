import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_home_view_model.g.dart';

/// What search shows before the user types.
@riverpod
class SearchHomeViewModel extends _$SearchHomeViewModel
    with RemoteStateMixin<SearchHome> {
  @override
  ViewState<SearchHome> build() => const ViewState.idle();

  Future<void> load() =>
      runRequest(() => ref.read(searchRepositoryProvider).home());
}

/// The user's recent searches on this device, newest first; null until
/// they search or clear, when the server's list shows.
@Riverpod(keepAlive: true)
class SearchHistoryViewModel extends _$SearchHistoryViewModel {
  static const int _kept = 8;

  @override
  List<String>? build() => null;

  /// Puts [query] first, after the searches already shown as [shown].
  void add(String query, {required List<String> shown}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    state = <String>[
      trimmed,
      for (final past in state ?? shown)
        if (past.toLowerCase() != trimmed.toLowerCase()) past,
    ].take(_kept).toList();
  }

  void clear() => state = const <String>[];
}
