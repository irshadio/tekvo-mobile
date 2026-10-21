import 'package:core/error/error_reporter.dart';
import 'package:core/error/error_reporting_observer.dart';
import 'package:core/presentation/widgets/error_fallback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

/// Routes framework and uncaught asynchronous errors to [reporter], and
/// shows [ErrorFallback] where a widget fails to build. The framework reports
/// that failure through [FlutterError.onError] first.
void installErrorHandlers(ErrorReporter reporter) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reporter.reportFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.report(error, stack, context: 'PlatformDispatcher');
    return true;
  };
  ErrorWidget.builder = (_) => const ErrorFallback();
}

/// The root scope: [overrides] plus the observer that reports handled
/// failures.
Widget buildRoot({
  required ErrorReporter reporter,
  required List<Override> overrides,
  required Widget child,
}) {
  return ProviderScope(
    observers: [ErrorReportingObserver(reporter)],
    overrides: overrides,
    child: child,
  );
}
