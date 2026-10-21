import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/domain/repositories/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestions_view_model.g.dart';

/// Suggestions for what has been typed so far.
@riverpod
class SuggestionsViewModel extends _$SuggestionsViewModel
    with RemoteStateMixin<Suggestions> {
  @override
  ViewState<Suggestions> build() => const ViewState.idle();

  Future<void> load(String query) =>
      runRequest(() => ref.read(searchRepositoryProvider).suggestions(query));
}
