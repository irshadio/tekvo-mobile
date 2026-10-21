import 'package:core/config/app_environment.dart';
import 'package:core/config/secure_url.dart';
import 'package:core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requireHttpsUrl', () {
    test('accepts an absolute https URL', () {
      expect(requireHttpsUrl('https://api.example.test/v1'), isNotEmpty);
    });

    for (final url in <String>[
      'http://api.example.test',
      'api.example.test',
      'https://',
      '',
      'ftp://api.example.test',
      'https://user:secret@api.example.test',
    ]) {
      test('rejects "$url"', () {
        expect(() => requireHttpsUrl(url), throwsStateError);
      });
    }
  });

  group('AppEnvironment', () {
    test('defaults to dev without APP_ENV', () {
      expect(AppEnvironment.fromEnv(), AppEnvironment.dev);
    });

    test('each flavour has its own title and log level', () {
      expect(AppEnvironment.dev.appTitle('Tekvo'), 'Tekvo Dev');
      expect(AppEnvironment.qa.appTitle('Tekvo'), 'Tekvo QA');
      expect(AppEnvironment.uat.appTitle('Tekvo Rider'), 'Tekvo Rider UAT');
      expect(AppEnvironment.prod.appTitle('Tekvo Rider'), 'Tekvo Rider');
      expect(AppEnvironment.prod.config.minLogLevel, LogLevel.warning);
      expect(AppEnvironment.prod.isProd, isTrue);
      expect(AppEnvironment.dev.isProd, isFalse);
    });

    test('every flavour base URL is https', () {
      for (final env in AppEnvironment.values) {
        expect(() => requireHttpsUrl(env.config.apiBaseUrl), returnsNormally);
      }
    });
  });
}
