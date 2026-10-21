import 'dart:async';

import 'package:core/error/failure.dart';
import 'package:core/presentation/widgets/country_picker_sheet.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/social_account.dart';
import 'package:country/country.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:customer/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:customer/features/auth/presentation/view/login_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';
import 'fakes.dart';

final AppLocalizations _en = AppLocalizationsEn();

typedef _Next = ({String? name, Object? arguments});

/// Pumps the screen; the code route pops with [codeResult].
Future<List<_Next>> _pump(
  WidgetTester tester,
  FakeOtpRepository repository, {
  bool? codeResult,
  FakeSocialAuthRepository? social,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <_Next>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        otpRepositoryProvider.overrideWithValue(repository),
        socialAuthRepositoryProvider.overrideWithValue(
          social ?? FakeSocialAuthRepository(),
        ),
      ],
      child: testApp(
        home: const LoginView(),
        onGenerateRoute: (settings) {
          opened.add((name: settings.name, arguments: settings.arguments));
          return MaterialPageRoute<bool>(
            settings: settings,
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pop(codeResult),
              child: const Text('back'),
            ),
          );
        },
      ),
    ),
  );
  return opened;
}

ButtonStyleButton _button(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('Continue waits for a valid number', (tester) async {
    await _pump(tester, FakeOtpRepository());

    expect(_button(tester, _en.signInContinue).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '50123456');
    await tester.pump();
    expect(_button(tester, _en.signInContinue).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    expect(_button(tester, _en.signInContinue).onPressed, isNotNull);
    expect(_fieldText(tester), '50 123 4567');
  });

  testWidgets('Continue texts the code and opens its entry', (tester) async {
    final repository = FakeOtpRepository();
    final opened = await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text(_en.signInContinue));
    await tester.pumpAndSettle();

    const contact = MobileContact(country: Countries.are, number: '501234567');
    expect(repository.sent, [contact]);
    expect(opened.single, (
      name: Routes.otp,
      arguments: (contact: contact, account: null),
    ));
  });

  testWidgets('a failed send stays on the screen with an error', (
    tester,
  ) async {
    final opened = await _pump(
      tester,
      FakeOtpRepository(failure: const Failure.noConnection()),
    );

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text(_en.signInContinue));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Continue waits while the code is being sent', (tester) async {
    final answer = Completer<void>();
    await _pump(tester, FakeOtpRepository(answer: answer));

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text(_en.signInContinue));
    await tester.pump();

    expect(_button(tester, _en.signInContinue).onPressed, isNull);
    answer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('changing the number returns focus to the field', (
    tester,
  ) async {
    await _pump(tester, FakeOtpRepository(), codeResult: true);

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text(_en.signInContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('a picked country takes the number and its rules', (
    tester,
  ) async {
    await _pump(tester, FakeOtpRepository());

    await tester.enterText(find.byType(TextField), '501234567');
    await tester.pump();
    await tester.tap(find.text('+971'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Qatar'));
    await tester.pumpAndSettle();

    expect(find.byType(CountryPickerSheet), findsNothing);
    expect(find.text('+974'), findsOneWidget);
    expect(_fieldText(tester), '501 2345');
  });

  testWidgets('Skip opens home on its own', (tester) async {
    final opened = await _pump(tester, FakeOtpRepository());

    await tester.tap(find.text(_en.signInSkip));
    await tester.pumpAndSettle();

    expect(opened.single.name, Routes.home);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets('Google and Apple go on to verify a mobile number', (
    tester,
  ) async {
    final opened = await _pump(tester, FakeOtpRepository());

    await tester.tap(find.text(_en.signInGoogle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.signInApple));
    await tester.pumpAndSettle();

    expect(opened.map((r) => r.arguments), [
      const SocialAccount(
        provider: SocialProvider.google,
        name: FakeSocialAuthRepository.name,
        email: FakeSocialAuthRepository.email,
      ),
      const SocialAccount(
        provider: SocialProvider.apple,
        name: FakeSocialAuthRepository.name,
        email: FakeSocialAuthRepository.email,
      ),
    ]);
    expect(opened.map((r) => r.name).toSet(), {Routes.verifyMobile});
  });

  testWidgets('a cancelled Google sign-in stays without a message', (
    tester,
  ) async {
    final opened = await _pump(
      tester,
      FakeOtpRepository(),
      social: FakeSocialAuthRepository(failure: const Failure.cancelled()),
    );

    await tester.tap(find.text(_en.signInGoogle));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
  });
}
