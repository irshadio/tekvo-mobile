import 'package:core/bootstrap/start_app.dart';
import 'package:core/config/app_environment.dart';
import 'package:customer/app/app.dart';
import 'package:customer/config/app_identity.dart';
import 'package:customer/features/auth/auth_overrides.dart';
import 'package:customer/features/home/home_overrides.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/features/registration/registration_overrides.dart';
import 'package:customer/features/search/search_overrides.dart';
import 'package:customer/features/store/store_overrides.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

/// Composition root shared by every entrypoint. Each feature adds its
/// `<name>Overrides` to `featureOverrides` and the local stores holding user
/// data to `userDataStores`.
Future<void> runCustomerApp(AppEnvironment env) => startApp(
  env: env,
  appName: appName,
  featureOverrides: <Override>[
    ...authOverrides,
    ...homeOverrides,
    ...productOverrides,
    ...storeOverrides,
    ...searchOverrides,
    ...registrationOverrides,
  ],
  app: (title) => App(title: title),
);
