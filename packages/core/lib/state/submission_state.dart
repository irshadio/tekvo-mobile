import 'package:core/error/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_state.freezed.dart';

/// The write-state union every mutating ViewModel exposes. Form fields live in
/// the View; this only tracks whether a submit is in flight and its outcome.
@freezed
sealed class SubmissionState<T> with _$SubmissionState<T> {
  const factory SubmissionState.idle() = SubmissionIdle<T>;

  const factory SubmissionState.inProgress() = SubmissionInProgress<T>;

  const factory SubmissionState.success(T value) = SubmissionSuccess<T>;

  const factory SubmissionState.failure(Failure failure) = SubmissionFailure<T>;
}

extension SubmissionStateX<T> on SubmissionState<T> {
  /// Disable the submit action while this is true.
  bool get isInProgress => this is SubmissionInProgress<T>;
}
