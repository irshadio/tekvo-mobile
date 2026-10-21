import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_view_model.g.dart';

/// One product's details.
@riverpod
class ProductViewModel extends _$ProductViewModel
    with RemoteStateMixin<ProductDetails> {
  @override
  ViewState<ProductDetails> build(String id) => const ViewState.idle();

  Future<void> load() =>
      runRequest(() => ref.read(productRepositoryProvider).details(id));
}
