import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:customer/features/product/presentation/view_model/question_query_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'questions_view_model.g.dart';

/// A product's questions for the current query, fetched again whenever
/// the query changes.
@riverpod
class QuestionsViewModel extends _$QuestionsViewModel
    with RemoteStateMixin<QuestionsPage> {
  @override
  ViewState<QuestionsPage> build(String productId) {
    ref.listen(questionQueryViewModelProvider(productId), (_, _) => load());
    return const ViewState.idle();
  }

  Future<void> load() {
    final query = ref.read(questionQueryViewModelProvider(productId));
    return runRequest(
      () => ref
          .read(productRepositoryProvider)
          .questions(
            productId,
            topic: query.topic,
            search: query.search,
            sort: query.sort,
          ),
    );
  }
}

/// The questions whose other answers are showing, by id.
@riverpod
class OpenAnswersViewModel extends _$OpenAnswersViewModel {
  @override
  Set<String> build(String productId) => const <String>{};

  void toggle(String id) => state = state.contains(id)
      ? (Set<String>.of(state)..remove(id))
      : <String>{...state, id};
}
