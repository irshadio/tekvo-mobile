import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'submit_review_view_model.g.dart';

/// Sending a written review.
@riverpod
class SubmitReviewViewModel extends _$SubmitReviewViewModel
    with MutationStateMixin<ReviewReceipt> {
  @override
  SubmissionState<ReviewReceipt> build(String productId) =>
      const SubmissionState.idle();

  Future<void> submit(ReviewDraft draft) => runMutation(
    () => ref.read(productRepositoryProvider).submitReview(productId, draft),
  );
}
