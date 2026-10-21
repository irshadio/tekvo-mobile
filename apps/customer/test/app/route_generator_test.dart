import 'package:customer/app/route_generator.dart';
import 'package:customer/features/permissions/presentation/view/location_permission_view.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications dissolve in after the location prompt only', () {
    final afterPrompt = onGenerateRoute(
      const RouteSettings(
        name: Routes.notificationPermission,
        arguments: NotificationEntry.afterPrompt,
      ),
    );
    final skipped = onGenerateRoute(
      const RouteSettings(
        name: Routes.notificationPermission,
        arguments: NotificationEntry.skipped,
      ),
    );

    expect(afterPrompt, isA<PageRouteBuilder<void>>());
    expect(skipped, isA<MaterialPageRoute<void>>());
  });

  test('sign in pushes in, as in the prototype', () {
    expect(
      onGenerateRoute(const RouteSettings(name: Routes.signIn)),
      isA<PageRouteBuilder<void>>(),
    );
  });

  test('every route name opens a page', () {
    for (final name in [
      Routes.splash,
      Routes.onboarding,
      Routes.locationPermission,
      Routes.notificationPermission,
      Routes.signIn,
    ]) {
      expect(
        onGenerateRoute(RouteSettings(name: name)),
        isA<PageRoute<void>>(),
      );
    }
  });
}
