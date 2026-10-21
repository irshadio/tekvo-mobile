import 'package:core/error/failure.dart';
import 'package:core/state/view_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Drives `loading -> (data | error | noInternet)` from a repository `Either`
/// for a `@riverpod` ViewModel whose state is `ViewState<T>`.
///
/// The `on $Notifier` clause names a riverpod_generator internal: the
/// generated `_$X` extends `$Notifier<State>`, not the public `Notifier`. Only
/// this file and `mutation_state_mixin.dart` may name it. After any Riverpod
/// bump, run `test/core/state/remote_state_mixin_test.dart`.
mixin RemoteStateMixin<T> on $Notifier<ViewState<T>> {
  // Only the latest request may commit state, so overlapping requests cannot
  // overwrite a newer result.
  int _activeRequestId = 0;

  /// Sets `loading(previous:)`, awaits [request] and maps the result, keeping
  /// the last data as `previous` on failure. A throw becomes
  /// `Failure.unexpected` rather than a stuck spinner.
  Future<void> runRequest(
    Future<Either<Failure, T>> Function() request,
  ) async {
    final previous = state.dataOrNull;
    final requestId = ++_activeRequestId;
    state = ViewState<T>.loading(previous: previous);
    final Either<Failure, T> result;
    try {
      result = await request();
    } on Object catch (error, stackTrace) {
      if (!_isCurrent(requestId)) return;
      state = ViewState<T>.error(
        Failure.unexpected(detail: '$error\n$stackTrace'),
        previous: previous,
      );
      return;
    }
    if (!_isCurrent(requestId)) return;
    state = result.fold(
      (failure) => switch (failure) {
        NoConnectionFailure() => ViewState<T>.noInternet(previous: previous),
        _ => ViewState<T>.error(failure, previous: previous),
      },
      ViewState<T>.data,
    );
  }

  /// Back to `idle`, dropping the data and ignoring any request in flight:
  /// for a list whose parent changed, so the old list never shows as
  /// `previous`.
  void reset() {
    _activeRequestId++;
    state = ViewState<T>.idle();
  }

  bool _isCurrent(int requestId) =>
      ref.mounted && requestId == _activeRequestId;
}
