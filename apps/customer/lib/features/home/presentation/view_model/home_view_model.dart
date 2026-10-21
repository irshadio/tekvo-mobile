import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:customer/features/home/domain/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

/// The home tab's feed.
@riverpod
class HomeViewModel extends _$HomeViewModel with RemoteStateMixin<HomeFeed> {
  @override
  ViewState<HomeFeed> build() => const ViewState.idle();

  Future<void> load() =>
      runRequest(() => ref.read(homeRepositoryProvider).feed());
}
