import 'package:core/config/app_environment.dart';
import 'package:core/config/app_environment_provider.dart';
import 'package:core/network/connectivity.dart';
import 'package:core/presentation/widgets/not_found_view.dart';
import 'package:core/routing/app_routes.dart';
import 'package:customer/app/app.dart';
import 'package:customer/features/splash/presentation/view/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(AppEnvironment env) => ProviderScope(
  overrides: [
    appEnvironmentProvider.overrideWith((ref) => env),
    connectivityStatusProvider.overrideWith((ref) => Stream<bool>.value(true)),
  ],
  child: App(title: env.appTitle('Tekvo')),
);

/// Long enough for the splash timeline to settle; its loader keeps looping,
/// so the tests pump time rather than settle.
const Duration _splashTimeline = Duration(milliseconds: 2500);

void main() {
  testWidgets('starts at the splash with the flavour title', (tester) async {
    await tester.pumpWidget(_app(AppEnvironment.qa));
    await tester.pump(_splashTimeline);

    expect(find.byType(SplashView), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      'Tekvo QA',
    );
  });

  testWidgets('follows the system dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(_app(AppEnvironment.prod));
    await tester.pump(_splashTimeline);

    final context = tester.element(find.byType(SplashView));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('an unknown route shows the not-found page', (tester) async {
    await tester.pumpWidget(_app(AppEnvironment.dev));
    await tester.pump(_splashTimeline);

    rootNavigatorKey.currentState!.pushNamed<void>('/missing').ignore();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NotFoundView), findsOneWidget);
  });
}
