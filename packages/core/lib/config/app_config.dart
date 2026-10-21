import 'package:envied/envied.dart';

part 'app_config.g.dart';

/// Build-time configuration generated from `.env` by envied.
///
/// After editing `.env`, run `dart run build_runner clean` before `build`:
/// envied does not track `.env` as an input. Never put backend secrets here;
/// anything in the app binary can be extracted.
@Envied(path: '.env', obfuscate: true)
abstract final class AppConfig {
  @EnviedField(varName: 'API_BASE_URL_DEV')
  static final String apiBaseUrlDev = _AppConfig.apiBaseUrlDev;

  @EnviedField(varName: 'API_BASE_URL_QA')
  static final String apiBaseUrlQa = _AppConfig.apiBaseUrlQa;

  @EnviedField(varName: 'API_BASE_URL_UAT')
  static final String apiBaseUrlUat = _AppConfig.apiBaseUrlUat;

  @EnviedField(varName: 'API_BASE_URL_PROD')
  static final String apiBaseUrlProd = _AppConfig.apiBaseUrlProd;

  /// On-device sembast database file name.
  static const String databaseName = 'tekvo.db';
}
