import 'package:core/bootstrap/start_app.dart';
import 'package:core/config/app_environment.dart';
import 'package:customer/app/app.dart';
import 'package:customer/config/app_identity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

/// Composition root shared by every entrypoint. Each feature adds its
/// `<name>Overrides` to `featureOverrides` and the local stores holding user
/// data to `userDataStores`.
Future<void> runCustomerApp(AppEnvironment env) => startApp(
  env: env,
  appName: appName,
  featureOverrides: const <Override>[],
  app: (title) => App(title: title),
);
