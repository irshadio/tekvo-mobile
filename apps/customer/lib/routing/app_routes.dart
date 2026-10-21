/// Route names for Navigator 1.0 (`onGenerateRoute`). Never hard-code a route
/// string elsewhere.
abstract final class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String locationPermission = '/permissions/location';

  /// Takes a `NotificationEntry`, which sets how the screen comes in.
  static const String notificationPermission = '/permissions/notifications';
  static const String signIn = '/sign-in';

  /// Takes an `OtpRequest`: the number the code went to and any Google or
  /// Apple account. Pops `true` to change the number.
  static const String otp = '/sign-in/code';

  /// The new account's profile, after the code is verified. Takes the
  /// `SocialAccount` that fills it in, if any.
  static const String profile = '/sign-in/profile';

  /// The mobile number check after a Google or Apple sign-in; takes the
  /// `SocialAccount`.
  static const String verifyMobile = '/sign-in/verify-mobile';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String search = '/search';

  /// Takes the product's id.
  static const String product = '/product';

  /// Takes the brand's store name.
  static const String store = '/store';

  /// Takes a `SpecificationsRequest`: the product and the group to open on.
  static const String specifications = '/product/specifications';

  /// Takes a `ReviewsRequest`: the product and the filter to start with.
  static const String reviews = '/product/reviews';

  /// Takes the `ReviewReceipt` of the review sent.
  static const String reviewSubmitted = '/product/reviews/sent';

  /// Each takes the product's id.
  static const String writeReview = '/product/reviews/write';
  static const String questions = '/product/questions';
  static const String askQuestion = '/product/questions/ask';

  static const String addresses = '/addresses';
  static const String orders = '/orders';

  /// Takes the `ShopCategory` to list.
  static const String productList = '/products';
}
