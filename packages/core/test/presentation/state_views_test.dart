import 'package:core/error/failure.dart';
import 'package:core/l10n/app_locale.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/presentation/widgets/state_views.dart';
import 'package:core/theme/app_palette.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  final l10n = lookupCoreLocalizations(AppLocale.current);

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    testApp(
      home: Scaffold(body: child),
    ),
  );

  testWidgets('error view shows the failure message and retries', (
    tester,
  ) async {
    var retries = 0;
    await pump(
      tester,
      AppErrorView(
        failure: const Failure.server(statusCode: 500, message: 'Try later'),
        onRetry: () => retries++,
      ),
    );

    expect(find.text(l10n.errorServer), findsOneWidget);
    expect(find.text('Try later'), findsNothing);
    await tester.tap(find.text(l10n.commonRetry));
    expect(retries, 1);
  });

  testWidgets('no retry button without a callback', (tester) async {
    await pump(tester, const AppNoInternetView());

    expect(find.text(l10n.errorNoConnection), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsNothing);
  });

  testWidgets('loading view shows its optional message', (tester) async {
    await pump(tester, const AppLoadingView(message: 'Loading bookings'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading bookings'), findsOneWidget);
  });

  testWidgets('error view survives large text scaling', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(3)),
        child: testApp(
          home: Scaffold(
            body: AppErrorView(
              failure: const Failure.unexpected(
                message: 'A long message that has to wrap over several lines',
              ),
              onRetry: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the theme pins the brand primary', (tester) async {
    late ColorScheme scheme;
    await tester.pumpWidget(
      DesignScale(
        builder: (_) {
          scheme = AppTheme.light.colorScheme;
          return const SizedBox();
        },
      ),
    );

    expect(scheme.primary, AppPalette.brand600);
    expect(scheme.onPrimary, AppPalette.neutral0);
  });
}
