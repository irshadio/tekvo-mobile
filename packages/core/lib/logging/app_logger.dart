import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_logger.g.dart';

/// Ordered: `debug < info < warning < error`.
enum LogLevel { debug, info, warning, error }

/// App-wide logging contract. Never `print`; never log tokens, passwords,
/// OTPs or unnecessary personal data.
abstract interface class AppLogger {
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });

  void debug(String message);
  void info(String message);
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// `dart:developer`-backed [AppLogger] that drops anything below [minLevel].
class ConsoleLogger implements AppLogger {
  ConsoleLogger({this.minLevel = LogLevel.debug});

  final LogLevel minLevel;

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;
    developer.log(
      message,
      name: 'tekvo',
      level: _value(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void debug(String message) => log(LogLevel.debug, message);

  @override
  void info(String message) => log(LogLevel.info, message);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  // dart:developer level values, as in package:logging.
  int _value(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => throw UnimplementedError(
  'appLoggerProvider must be overridden in ProviderScope (core/bootstrap).',
);
