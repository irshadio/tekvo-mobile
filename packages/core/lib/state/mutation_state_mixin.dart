import 'package:core/error/failure.dart';
import 'package:core/state/submission_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Drives `inProgress -> (success | failure)` from a repository `Either` for
/// a `@riverpod` ViewModel whose state is `SubmissionState<T>`.
///
/// Like `RemoteStateMixin`, the `on $Notifier` clause names a
/// riverpod_generator internal; only the two state mixins may. After any
/// Riverpod bump, run `test/core/state/mutation_state_mixin_test.dart`.
mixin MutationStateMixin<T> on $Notifier<SubmissionState<T>> {
  /// Sets `inProgress`, awaits [request] and maps the result. A call while a
  /// submit is in flight is dropped, so a double tap never sends twice; give
  /// each independent mutation its own ViewModel. A throw becomes
  /// `Failure.unexpected` rather than a stuck `inProgress`.
  Future<void> runMutation(
    Future<Either<Failure, T>> Function() request,
  ) async {
    if (state.isInProgress) return;
    state = SubmissionState<T>.inProgress();
    final Either<Failure, T> result;
    try {
      result = await request();
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = SubmissionState<T>.failure(
        Failure.unexpected(detail: '$error\n$stackTrace'),
      );
      return;
    }
    if (!ref.mounted) return;
    state = result.fold(
      SubmissionState<T>.failure,
      SubmissionState<T>.success,
    );
  }
}
