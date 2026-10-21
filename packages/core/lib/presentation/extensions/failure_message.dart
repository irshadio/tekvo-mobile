import 'package:core/error/failure.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:flutter/widgets.dart';

extension FailureMessageX on BuildContext {
  /// What to tell the user about [failure]: the server's own words where it
  /// wrote them, otherwise the app's localized text.
  String failureMessage(Failure failure) =>
      localizedFailureMessage(failure, coreL10n);
}

String localizedFailureMessage(Failure failure, CoreLocalizations l10n) =>
    switch (failure) {
      ValidationFailure(isServerMessage: true, :final message) ||
      UnauthorizedFailure(isServerMessage: true, :final message) ||
      ForbiddenFailure(isServerMessage: true, :final message) => message,
      ValidationFailure() => l10n.errorValidation,
      UnauthorizedFailure() => l10n.errorSessionExpired,
      ForbiddenFailure() => l10n.errorForbidden,
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      NoConnectionFailure() => l10n.errorNoConnection,
      CancelledFailure() => l10n.errorCancelled,
      CacheFailure() => l10n.errorStorage,
      UnexpectedFailure() => l10n.errorUnexpected,
      ServerFailure(:final statusCode) => switch (statusCode) {
        404 => l10n.errorNotFound,
        409 => l10n.errorConflict,
        429 => l10n.errorTooManyRequests,
        503 => l10n.errorServiceUnavailable,
        _ => l10n.errorServer,
      },
    };
