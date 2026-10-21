import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_question_view_model.g.dart';

/// Posting a question about a product, or an answer to one.
@riverpod
class PostQuestionViewModel extends _$PostQuestionViewModel
    with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build(String productId) => const SubmissionState.idle();

  Future<void> post(String text, {String? questionId, bool notify = true}) =>
      runMutation(
        () => ref
            .read(productRepositoryProvider)
            .post(
              productId,
              text.trim(),
              questionId: questionId,
              notify: notify,
            ),
      );
}
