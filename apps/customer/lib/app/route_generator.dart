import 'package:core/presentation/widgets/not_found_view.dart';
import 'package:core/routing/route_transitions.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/app/customer_shell.dart';
import 'package:customer/app/shell_navigation.dart';
import 'package:customer/features/auth/presentation/view/login_view.dart';
import 'package:customer/features/auth/presentation/view/otp_view.dart';
import 'package:customer/features/auth/presentation/view/verify_mobile_view.dart';
import 'package:customer/features/main/presentation/view/main_view.dart';
import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:customer/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:customer/features/permissions/presentation/view/location_permission_view.dart';
import 'package:customer/features/permissions/presentation/view/notification_permission_view.dart';
import 'package:customer/features/product/presentation/view/product_view.dart';
import 'package:customer/features/product/presentation/view/reviews_view.dart';
import 'package:customer/features/product/presentation/view/specifications_view.dart';
import 'package:customer/features/registration/presentation/view/profile_view.dart';
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
      final OtpRequest request => pushRoute<bool>(
        OtpView(contact: request.contact, account: request.account),
        settings,
      ),
      _ => materialRoute<bool>(const NotFoundView(), settings),
    },
    Routes.verifyMobile => switch (settings.arguments) {
      final SocialAccount account => pushRoute<void>(
        VerifyMobileView(account: account),
        settings,
      ),
      _ => materialRoute<void>(const NotFoundView(), settings),
    },
    // Dissolves in after sign-up or Skip, as in the prototype.
    Routes.home => fadeRoute(
      const CustomerShell(),
      settings,
      duration: MainView.entryFade,
    ),
    Routes.product => switch (settings.arguments) {
      final String id => pushRoute<void>(
        ProductView(
          id: id,
          onOpenCart: (context) => openShellTab(context, MainTab.cart),
        ),
        settings,
        duration: ProductView.entryDuration,
      ),
      _ => materialRoute<void>(const NotFoundView(), settings),
    },
    Routes.specifications => switch (settings.arguments) {
      final SpecificationsRequest request => pushRoute<void>(
        SpecificationsView(id: request.id, start: request.start),
        settings,
      ),
      _ => materialRoute<void>(const NotFoundView(), settings),
    },
    Routes.reviews => switch (settings.arguments) {
      final ReviewsRequest request => pushRoute<void>(
        ReviewsView(id: request.id, filter: request.filter),
        settings,
      ),
      _ => materialRoute<void>(const NotFoundView(), settings),
    },
    Routes.profile => pushRoute<void>(
      ProfileView(
        account: switch (settings.arguments) {
          final SocialAccount account => account,
          _ => null,
        },
      ),
      settings,
    ),
    _ => materialRoute<void>(const NotFoundView(), settings),
  };
}
