import 'package:core/bootstrap/bootstrap.dart';
import 'package:core/config/app_environment.dart';
import 'package:core/config/app_environment_provider.dart';
import 'package:core/error/error_reporter.dart';
import 'package:core/logging/app_logger.dart';
import 'package:core/network/app_foreground.dart';
import 'package:core/network/connectivity.dart';
import 'package:core/network/remote_client_provider.dart';
import 'package:core/network/token_provider.dart';
import 'package:core/network/unauthorized_handler.dart';
import 'package:core/storage/local_store.dart';
import 'package:core/storage/onboarding_store.dart';
import 'package:core/storage/secure_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late Database database;

  setUp(() async {
    database = await newDatabaseFactoryMemory().openDatabase('boot.db');
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'access_token': 'token',
    });
    final logger = ConsoleLogger(minLevel: LogLevel.error);
    container = ProviderContainer(
      overrides: await buildCoreOverrides(
        env: AppEnvironment.uat,
        logger: logger,
        reporter: LoggingErrorReporter(logger),
        userDataStores: const <String>['profile'],
        database: database,
      ),
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('binds every core contract', () {
    expect(container.read(appEnvironmentProvider), AppEnvironment.uat);
    expect(container.read(appLoggerProvider), isA<ConsoleLogger>());
    expect(container.read(errorReporterProvider), isA<ErrorReporter>());
    expect(container.read(secureStoreProvider), isA<SecureStoreImpl>());
    expect(container.read(localStoreProvider), isA<LocalStoreImpl>());
    expect(
      container.read(onboardingStoreProvider),
      isA<OnboardingStoreImpl>(),
    );
    expect(container.read(tokenProviderProvider), isA<SecureTokenProvider>());
    expect(
      container.read(unauthorizedHandlerProvider),
      isA<AppUnauthorizedHandler>(),
    );
    expect(container.read(connectivityServiceProvider), isNotNull);
    expect(container.read(networkChangesProvider), isA<NetworkChangesImpl>());
    expect(container.read(appForegroundProvider), isA<AppForegroundImpl>());
    expect(container.read(remoteClientProvider), isNotNull);
  });

  test('the token provider reads the bound secure store', () async {
    expect(
      await container.read(tokenProviderProvider).getAccessToken(),
      'token',
    );
  });

  test('ending the session clears tokens and the listed stores', () async {
    final store = container.read(localStoreProvider);
    await store.write('profile', 'me', <String, Object?>{'name': 'A'});
    await store.write('settings', 'x', <String, Object?>{'v': 1});

    await container.read(unauthorizedHandlerProvider).handleUnauthorized();

    expect(await container.read(secureStoreProvider).readAccessToken(), isNull);
    expect(await store.readAll('profile'), isEmpty);
    expect(await store.readAll('settings'), isNotEmpty);
  });

  test('ending the session keeps onboarding completed', () async {
    final onboarding = container.read(onboardingStoreProvider);
    await onboarding.markOnboardingCompleted();

    await container.read(unauthorizedHandlerProvider).handleUnauthorized();

    expect(await onboarding.hasCompletedOnboarding(), isTrue);
  });
}
