import 'package:core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_reporter.g.dart';

/// App-wide crash and error sink. The global handlers and any `catch` site
/// report through it, so a crash-reporting service is a one-class swap.
abstract interface class ErrorReporter {
  void report(Object error, StackTrace stackTrace, {String? context});

  void reportFlutterError(FlutterErrorDetails details);
}

/// Forwards everything to the [AppLogger].
class LoggingErrorReporter implements ErrorReporter {
  LoggingErrorReporter(this._logger);

  final AppLogger _logger;

  @override
  void report(Object error, StackTrace stackTrace, {String? context}) {
    _logger.error(
      context == null ? 'Uncaught error' : 'Uncaught error [$context]',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void reportFlutterError(FlutterErrorDetails details) {
    _logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  }
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
ErrorReporter errorReporter(Ref ref) => throw UnimplementedError(
  'errorReporterProvider must be overridden in ProviderScope (core/bootstrap).',
);
