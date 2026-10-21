import 'package:core/error/error_reporter.dart';
import 'package:core/error/failure.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reports handled failures that indicate a system problem.
///
/// `runRequest` / `runMutation` turn failures into state instead of throwing,
/// so the global handlers never see them. This observer reports them, minus
/// the expected, user-facing ones (offline, validation, session expiry,
/// cancellation). Wired once in `app/run_app.dart`.
final class ErrorReportingObserver extends ProviderObserver {
  const ErrorReportingObserver(this._reporter);

  final ErrorReporter _reporter;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) =>
      _maybeReport(context, value);

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) => _maybeReport(context, newValue);

  void _maybeReport(ProviderObserverContext context, Object? state) {
    final failure = _reportableFailure(state);
    if (failure == null) return;
    _reporter.report(
      failure,
      StackTrace.current,
      context: '${context.provider}',
    );
  }

  Failure? _reportableFailure(Object? state) {
    final failure = switch (state) {
      ViewError<Object?>(:final failure) => failure,
      SubmissionFailure<Object?>(:final failure) => failure,
      _ => null,
    };
    return switch (failure) {
      null ||
      NoConnectionFailure() ||
      ValidationFailure() ||
      UnauthorizedFailure() ||
      CancelledFailure() => null,
      _ => failure,
    };
  }
}
