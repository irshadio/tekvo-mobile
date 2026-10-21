import 'package:core/config/app_config.dart';
import 'package:core/config/app_environment.dart';
import 'package:core/config/app_environment_provider.dart';
import 'package:core/config/secure_url.dart';
import 'package:core/error/error_reporter.dart';
import 'package:core/logging/app_logger.dart';
import 'package:core/network/app_foreground.dart';
import 'package:core/network/connectivity.dart';
import 'package:core/network/idempotent_retry_policy.dart';
import 'package:core/network/remote_client_provider.dart';
import 'package:core/network/token_provider.dart';
import 'package:core/network/unauthorized_handler.dart';
import 'package:core/storage/local_store.dart';
import 'package:core/storage/secure_store.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast_io.dart';

/// Binds every core contract to its implementation.
///
/// [logger] and [reporter] come from `app/run_app.dart` so the global error
/// handlers share them. [userDataStores] names the local stores wiped when
/// the session ends; features supply them through `run_app.dart`. [database]
/// replaces the on-device database (tests).
Future<List<Override>> buildCoreOverrides({
  required AppEnvironment env,
  required AppLogger logger,
  required ErrorReporter reporter,
  List<String> userDataStores = const <String>[],
  Database? database,
}) async {
  final baseUrl = requireHttpsUrl(env.config.apiBaseUrl);
  final db = database ?? await _openDatabase();

  return <Override>[
    appEnvironmentProvider.overrideWith((ref) => env),
    appLoggerProvider.overrideWith((ref) => logger),
    errorReporterProvider.overrideWith((ref) => reporter),

    secureStoreProvider.overrideWith(
      (ref) => SecureStoreImpl(
        // iOS: readable after first unlock, bound to this device (no iCloud
        // sync or restore). Android: v10 encrypts with a KeyStore-wrapped key
        // by default.
        const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
      ),
    ),
    localStoreProvider.overrideWith((ref) => LocalStoreImpl(db)),

    // Host names only: literal IPs "resolve" without a network. Uncached
    // so a probe after a network change sees the change.
    connectivityServiceProvider.overrideWith(
      (ref) => rc.ConnectivityServiceImpl.noCache(
        checkHosts: const <String>['google.com', 'cloudflare.com'],
      ),
    ),
    networkChangesProvider.overrideWith((ref) => NetworkChangesImpl()),
    appForegroundProvider.overrideWith((ref) => AppForegroundImpl()),

    tokenProviderProvider.overrideWith(
      (ref) => SecureTokenProvider(ref.watch(secureStoreProvider)),
    ),
    unauthorizedHandlerProvider.overrideWith(
      (ref) => AppUnauthorizedHandler(
        secureStore: ref.watch(secureStoreProvider),
        localStore: ref.watch(localStoreProvider),
        userDataStores: userDataStores,
        logger: ref.watch(appLoggerProvider),
      ),
    ),

    remoteClientProvider.overrideWith(
      (ref) => rc.RemoteClientFactory.builder()
          .baseUrl(baseUrl)
          .withAuth(
            tokenProvider: ref.watch(tokenProviderProvider),
            unauthorizedHandler: ref.watch(unauthorizedHandlerProvider),
          )
          .withRetry(idempotentRetryPolicy)
          // `{success, data, message}` envelope, pending API confirmation.
          .withResponseParser(const rc.DefaultResponseParser())
          // The client logger prints response bodies (tokens included).
          .enableLogging(enabled: kDebugMode && !env.isProd)
          .build(),
    ),
  ];
}

Future<Database> _openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return databaseFactoryIo.openDatabase(
    p.join(dir.path, AppConfig.databaseName),
  );
}
