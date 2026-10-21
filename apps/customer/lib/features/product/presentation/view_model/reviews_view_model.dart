import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:customer/features/product/presentation/view_model/review_query_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_view_model.g.dart';

/// A product's reviews for the current query, fetched again whenever the
/// query changes.
@riverpod
class ReviewsViewModel extends _$ReviewsViewModel
    with RemoteStateMixin<ReviewsPage> {
  @override
  ViewState<ReviewsPage> build(String productId) {
    ref.listen(reviewQueryViewModelProvider(productId), (_, _) => load());
    return const ViewState.idle();
  }

  Future<void> load() {
    final query = ref.read(reviewQueryViewModelProvider(productId));
    return runRequest(
      () => ref
          .read(productRepositoryProvider)
          .reviews(
            productId,
            filter: query.filter,
            sort: query.sort,
            pages: query.pages,
          ),
    );
  }
}
