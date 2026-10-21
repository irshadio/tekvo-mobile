import 'dart:async';

import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/features/store/domain/repositories/store_repository.dart';
import 'package:customer/features/store/presentation/view_model/store_choices_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_view_model.g.dart';

/// A brand's store, fetched again when the product order changes.
@riverpod
class StoreViewModel extends _$StoreViewModel with RemoteStateMixin<Store> {
  @override
  ViewState<Store> build(String brand) {
    ref.listen(storeChoicesViewModelProvider(brand), (previous, next) {
      if (previous?.sort != next.sort) unawaited(load());
    });
    return const ViewState.idle();
  }

  Future<void> load() => runRequest(
    () => ref
        .read(storeRepositoryProvider)
        .store(
          brand,
          sort: ref.read(storeChoicesViewModelProvider(brand)).sort,
        ),
  );
}
