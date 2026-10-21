import 'package:core/config/app_config.dart';
import 'package:core/logging/app_logger.dart';

/// The build flavour, chosen by its entrypoint (`main_<flavour>.dart`), never
/// inferred at runtime.
enum AppEnvironment {
  dev,
  qa,
  uat,
  prod;

  /// Resolves the `APP_ENV` dart-define for the flavour-less `main.dart`
  /// (default [dev]).
  static AppEnvironment fromEnv() =>
      switch (const String.fromEnvironment('APP_ENV', defaultValue: 'dev')) {
        'prod' => AppEnvironment.prod,
        'uat' => AppEnvironment.uat,
        'qa' => AppEnvironment.qa,
        _ => AppEnvironment.dev,
      };

  EnvConfig get config => switch (this) {
    AppEnvironment.dev => EnvConfig(
      name: 'dev',
      apiBaseUrl: AppConfig.apiBaseUrlDev,
      minLogLevel: LogLevel.debug,
    ),
    AppEnvironment.qa => EnvConfig(
      name: 'qa',
      apiBaseUrl: AppConfig.apiBaseUrlQa,
      minLogLevel: LogLevel.info,
    ),
    AppEnvironment.uat => EnvConfig(
      name: 'uat',
      apiBaseUrl: AppConfig.apiBaseUrlUat,
      minLogLevel: LogLevel.info,
    ),
    AppEnvironment.prod => EnvConfig(
      name: 'prod',
      apiBaseUrl: AppConfig.apiBaseUrlProd,
      minLogLevel: LogLevel.warning,
    ),
  };

  bool get isProd => this == AppEnvironment.prod;

  /// The display name of an app called [name] in this flavour, matching the
  /// platform app label (for example "Tekvo QA"; prod is just [name]).
  String appTitle(String name) => switch (this) {
    AppEnvironment.dev => '$name Dev',
    AppEnvironment.qa => '$name QA',
    AppEnvironment.uat => '$name UAT',
    AppEnvironment.prod => name,
  };
}

/// Per-flavour configuration.
class EnvConfig {
  const EnvConfig({
    required this.name,
    required this.apiBaseUrl,
    required this.minLogLevel,
  });

  final String name;

  final String apiBaseUrl;

  /// Lowest level the [AppLogger] emits in this flavour.
  final LogLevel minLogLevel;
}
