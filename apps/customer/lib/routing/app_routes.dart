/// Route names for Navigator 1.0 (`onGenerateRoute`). Never hard-code a route
/// string elsewhere.
abstract final class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String locationPermission = '/permissions/location';

  /// Takes a `NotificationEntry`, which sets how the screen comes in.
  static const String notificationPermission = '/permissions/notifications';
  static const String signIn = '/sign-in';

  /// Takes the `MobileContact` the code was sent to; pops `true` to change
  /// the number.
  static const String otp = '/sign-in/code';

  /// The new account's profile, after the code is verified.
  static const String profile = '/sign-in/profile';

  /// The mobile number check after a Google or Apple sign-in.
  static const String verifyMobile = '/sign-in/verify-mobile';
  static const String home = '/home';
}
