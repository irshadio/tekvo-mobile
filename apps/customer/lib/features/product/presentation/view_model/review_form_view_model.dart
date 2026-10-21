import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_form_view_model.g.dart';

/// The purchase a review is being written for.
@riverpod
class ReviewFormViewModel extends _$ReviewFormViewModel
    with RemoteStateMixin<ReviewForm> {
  @override
  ViewState<ReviewForm> build(String productId) => const ViewState.idle();

  Future<void> load() => runRequest(
    () => ref.read(productRepositoryProvider).reviewForm(productId),
  );
}
