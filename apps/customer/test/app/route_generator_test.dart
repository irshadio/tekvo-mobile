import 'package:core/utils/mobile_contact.dart';
import 'package:country/country.dart';
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

  test('the code entry pushes in for a number, and pops a bool', () {
    final route = onGenerateRoute(
      const RouteSettings(
        name: Routes.otp,
        arguments: (
          contact: MobileContact(country: Countries.are, number: '501234567'),
          account: null,
        ),
      ),
    );

    expect(route, isA<PageRouteBuilder<bool>>());
    expect(
      onGenerateRoute(const RouteSettings(name: Routes.otp)),
      isA<MaterialPageRoute<bool>>(),
    );
  });

  test('every route name opens a page', () {
    for (final name in [
      Routes.splash,
      Routes.onboarding,
      Routes.locationPermission,
      Routes.notificationPermission,
      Routes.signIn,
      Routes.profile,
      Routes.verifyMobile,
      Routes.home,
    ]) {
      expect(
        onGenerateRoute(RouteSettings(name: name)),
        isA<PageRoute<void>>(),
      );
    }
  });
}
