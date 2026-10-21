import 'dart:convert';

import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/social_account.dart';
import 'package:country/country.dart';
import 'package:customer/app/customer_shell.dart';
import 'package:customer/features/auth/auth_overrides.dart';
import 'package:customer/features/auth/presentation/view/login_view.dart';
import 'package:customer/features/auth/presentation/view/otp_view.dart';
import 'package:customer/features/auth/presentation/view/verify_mobile_view.dart';
import 'package:customer/features/home/home_overrides.dart';
import 'package:customer/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:customer/features/permissions/presentation/view/location_permission_view.dart';
import 'package:customer/features/permissions/presentation/view/notification_permission_view.dart';
import 'package:customer/features/product/presentation/view/product_view.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/features/registration/presentation/view/profile_view.dart';
import 'package:customer/features/registration/registration_overrides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

const SocialAccount _account = SocialAccount(
  provider: SocialProvider.google,
  name: 'Sam Rivera',
  email: 'sam.rivera@gmail.com',
);

/// Every screen, at small to large phone sizes and enlarged text, scrolled
/// to its end: any overflow fails the test. Uses the real font, whose
/// metrics decide where text wraps.
final Map<String, Widget> _screens = {
  'onboarding': const OnboardingView(),
  'location': const LocationPermissionView(),
  'notifications': const NotificationPermissionView(),
  'login': const LoginView(),
  'otp': const OtpView(
    contact: MobileContact(country: Countries.are, number: '501234567'),
  ),
  'verify-mobile': const VerifyMobileView(account: _account),
  'profile': const ProfileView(account: _account),
  'home': const CustomerShell(),
  'product': ProductView(id: 'nova-x-pro', onOpenCart: (_) {}),
};

const Map<String, Size> _sizes = <String, Size>{
  'SE 320x568': Size(320, 568),
  'small 360x640': Size(360, 640),
  'design 393x852': Size(393, 852),
  'large 430x932': Size(430, 932),
};

Future<void> _fonts() async {
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_fonts);
  for (final MapEntry(key: screen, value: widget) in _screens.entries) {
    for (final MapEntry(key: size, value: dims) in _sizes.entries) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('$screen · $size · text x$scale', (tester) async {
          tester.view
            ..devicePixelRatio = 1
            ..physicalSize = dims
            ..padding = const FakeViewPadding(top: 44, bottom: 34)
            ..viewPadding = const FakeViewPadding(top: 44, bottom: 34);
          addTearDown(tester.view.reset);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                ...authOverrides,
                ...homeOverrides,
                ...registrationOverrides,
                ...productOverrides,
              ],
              child: testApp(home: widget),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          // Down the page in steps, laying out every section.
          final scrollables = find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          );
          for (var i = 0; i < 12 && scrollables.evaluate().isNotEmpty; i++) {
            await tester.drag(scrollables.first, const Offset(0, -400));
            await tester.pump(const Duration(milliseconds: 100));
          }
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
