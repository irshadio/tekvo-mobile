import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/social_account.dart';
import 'package:country/country.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:customer/features/auth/presentation/view/verify_mobile_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';
import 'fakes.dart';

final AppLocalizations _en = AppLocalizationsEn();

const SocialAccount _account = SocialAccount(
  provider: SocialProvider.google,
  name: 'Sam Rivera',
  email: 'sam.rivera@gmail.com',
);

typedef _Next = ({String? name, Object? arguments});

Future<List<_Next>> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <_Next>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [otpRepositoryProvider.overrideWithValue(FakeOtpRepository())],
      child: testApp(
        home: const VerifyMobileView(account: _account),
        onGenerateRoute: (settings) {
          opened.add((name: settings.name, arguments: settings.arguments));
          return MaterialPageRoute<bool>(
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
  testWidgets('shows which account signed in', (tester) async {
    await _pump(tester);

    expect(find.text(_en.verifyMobileSignedIn('Google')), findsOneWidget);
    expect(find.text(_account.email), findsOneWidget);
  });

  testWidgets('Send code texts the number and carries the account on', (
    tester,
  ) async {
    final opened = await _pump(tester);

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text(_en.verifyMobileSend));
    await tester.pumpAndSettle();

    expect(opened.single, (
      name: Routes.otp,
      arguments: (
        contact: const MobileContact(
          country: Countries.are,
          number: '501234567',
        ),
        account: _account,
      ),
    ));
  });

  testWidgets('Skip goes on to the profile without a number', (tester) async {
    final opened = await _pump(tester);

    await tester.tap(find.text(_en.signInSkip));
    await tester.pumpAndSettle();

    expect(opened.single, (name: Routes.profile, arguments: _account));
  });
}
