import 'package:core/error/failure.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/failure_message.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ProviderListenable comes from riverpod_annotation, not flutter_riverpod.
import 'package:riverpod_annotation/riverpod_annotation.dart';

extension WidgetRefX on WidgetRef {
  /// Shows a failed refresh as a snackbar; the data stays on screen.
  ///
  /// Call once in `build` for every screen with a `ViewStateSwitcher`. Pass
  /// [includeFirstLoad] when the state feeds a widget directly instead, or the
  /// first failure is silent.
  void listenRefreshFailures<T>(
    ProviderListenable<ViewState<T>> provider,
    BuildContext context, {
    bool includeFirstLoad = false,
  }) {
    listen<ViewState<T>>(provider, (previous, next) {
      if (next.dataOrNull == null && !includeFirstLoad) return;
      final message = switch (next) {
        ViewError<T>(:final failure) => context.failureMessage(failure),
        ViewNoInternet<T>() => context.coreL10n.errorNoConnection,
        _ => null,
      };
      if (message != null && context.mounted) {
        context.showSnackBar(message, isError: true);
      }
    });
  }

  /// Reacts once to a mutation's outcome: [onSuccess] on success, [onFailure]
  /// (default: an error snackbar) on failure.
  void listenSubmission<T>(
    ProviderListenable<SubmissionState<T>> provider,
    BuildContext context, {
    required void Function(T value) onSuccess,
    void Function(Failure failure)? onFailure,
  }) {
    listen<SubmissionState<T>>(provider, (previous, next) {
      if (!context.mounted) return;
      switch (next) {
        case SubmissionSuccess<T>(:final value):
          onSuccess(value);
        case SubmissionFailure<T>(:final failure):
          if (onFailure != null) {
            onFailure(failure);
          } else {
            context.showSnackBar(
              context.failureMessage(failure),
              isError: true,
            );
          }
        case SubmissionIdle<T>() || SubmissionInProgress<T>():
          break;
      }
    });
  }
}
