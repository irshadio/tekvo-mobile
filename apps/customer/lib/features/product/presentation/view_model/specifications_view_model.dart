import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'specifications_view_model.g.dart';

/// One product's full specification.
@riverpod
class SpecificationsViewModel extends _$SpecificationsViewModel
    with RemoteStateMixin<ProductSpecifications> {
  @override
  ViewState<ProductSpecifications> build(String id) => const ViewState.idle();

  Future<void> load() =>
      runRequest(() => ref.read(productRepositoryProvider).specifications(id));
}
