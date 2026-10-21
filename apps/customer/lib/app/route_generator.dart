import 'package:core/presentation/widgets/not_found_view.dart';
import 'package:core/routing/route_transitions.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/presentation/view/login_view.dart';
import 'package:customer/features/auth/presentation/view/otp_view.dart';
import 'package:customer/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:customer/features/permissions/presentation/view/location_permission_view.dart';
import 'package:customer/features/permissions/presentation/view/notification_permission_view.dart';
import 'package:customer/features/splash/presentation/view/splash_view.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';

/// Maps route names to screens. Lives in `app/` because it imports feature
/// views.
///
/// A route's type argument is its result type and must match the caller's
/// `pushNamed<T>`, or Navigator's internal cast throws on push.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return switch (settings.name) {
    Routes.splash => materialRoute<void>(const SplashView(), settings),
    // Dissolves in from the splash, as in the prototype.
    Routes.onboarding => fadeRoute(
      const OnboardingView(),
      settings,
      duration: SplashView.handOff,
    ),
    Routes.locationPermission => materialRoute<void>(
      const LocationPermissionView(),
      settings,
    ),
    Routes.notificationPermission => switch (settings.arguments) {
      NotificationEntry.afterPrompt => fadeRoute(
        const NotificationPermissionView(),
        settings,
        duration: NotificationPermissionView.entryFade,
      ),
      _ => materialRoute<void>(const NotificationPermissionView(), settings),
    },
    Routes.signIn => pushRoute<void>(
      const LoginView(),
      settings,
      duration: LoginView.entryDuration,
    ),
    Routes.otp => switch (settings.arguments) {
      final MobileContact contact => pushRoute<bool>(
        OtpView(contact: contact),
        settings,
      ),
      _ => materialRoute<bool>(const NotFoundView(), settings),
    },
    _ => materialRoute<void>(const NotFoundView(), settings),
  };
}
