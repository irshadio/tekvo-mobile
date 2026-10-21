import 'dart:async';

import 'package:core/error/error_reporter.dart';
import 'package:core/permissions/permission_service.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/permissions/presentation/view/location_permission_view.dart';
import 'package:customer/features/permissions/presentation/view/notification_permission_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';
import 'fakes.dart';

final AppLocalizations _en = AppLocalizationsEn();

/// The route the screen continued to, and its arguments.
typedef _Next = ({String? name, Object? arguments});

Future<List<_Next>> _pump(
  WidgetTester tester,
  Widget screen,
  FakePermissionService service,
) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <_Next>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        permissionServiceProvider.overrideWithValue(service),
        errorReporterProvider.overrideWithValue(FakeErrorReporter()),
      ],
      child: testApp(
        home: screen,
        onGenerateRoute: (settings) {
          opened.add((name: settings.name, arguments: settings.arguments));
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox(),
          );
        },
      ),
    ),
  );
  return opened;
}

void main() {
  group('location', () {
    testWidgets('Allow asks the system, then dissolves to notifications', (
      tester,
    ) async {
      final service = FakePermissionService();
      final opened = await _pump(
        tester,
        const LocationPermissionView(),
        service,
      );

      await tester.tap(find.text(_en.locationPermissionAllow));
      await tester.pumpAndSettle();

      expect(service.asked, <AppPermission>[AppPermission.location]);
      expect(opened.single, (
        name: Routes.notificationPermission,
        arguments: NotificationEntry.afterPrompt,
      ));
    });

    testWidgets('entering the area manually goes on without asking', (
      tester,
    ) async {
      final service = FakePermissionService();
      final opened = await _pump(
        tester,
        const LocationPermissionView(),
        service,
      );

      await tester.tap(find.text(_en.locationPermissionManual));
      await tester.pumpAndSettle();

      expect(service.asked, isEmpty);
      expect(opened.single, (
        name: Routes.notificationPermission,
        arguments: NotificationEntry.skipped,
      ));
    });

    testWidgets('the buttons wait while the system prompt is open', (
      tester,
    ) async {
      final answer = Completer<void>();
      await _pump(
        tester,
        const LocationPermissionView(),
        FakePermissionService(answer: answer),
      );

      await tester.tap(find.text(_en.locationPermissionAllow));
      await tester.pump();

      for (final label in [
        _en.locationPermissionAllow,
        _en.locationPermissionManual,
      ]) {
        final button = tester.widget<ButtonStyleButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          ),
        );
        expect(button.onPressed, isNull);
      }
      answer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a failing prompt never strands the user', (tester) async {
      final opened = await _pump(
        tester,
        const LocationPermissionView(),
        FakePermissionService(fails: true),
      );

      await tester.tap(find.text(_en.locationPermissionAllow));
      await tester.pumpAndSettle();

      expect(opened.single.name, Routes.notificationPermission);
    });
  });

  group('notifications', () {
    testWidgets('Turn on asks the system, then goes to sign in', (
      tester,
    ) async {
      final service = FakePermissionService(outcome: PermissionOutcome.denied);
      final opened = await _pump(
        tester,
        const NotificationPermissionView(),
        service,
      );

      await tester.tap(find.text(_en.notificationPermissionAllow));
      await tester.pumpAndSettle();

      expect(service.asked, <AppPermission>[AppPermission.notifications]);
      expect(opened.single.name, Routes.signIn);
    });

    testWidgets('Maybe later goes to sign in without asking', (tester) async {
      final service = FakePermissionService();
      final opened = await _pump(
        tester,
        const NotificationPermissionView(),
        service,
      );

      await tester.tap(find.text(_en.notificationPermissionLater));
      await tester.pumpAndSettle();

      expect(service.asked, isEmpty);
      expect(opened.single.name, Routes.signIn);
    });
  });
}
