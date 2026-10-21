import 'package:core/error/failure.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:country/country.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:customer/features/auth/presentation/view/otp_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';
import 'fakes.dart';

final AppLocalizations _en = AppLocalizationsEn();

const MobileContact _contact = MobileContact(
  country: Countries.are,
  number: '501234567',
);

/// Opens the code entry from a first screen; returns the routes it opened
/// and what it popped with.
Future<({List<String?> opened, List<bool?> popped})> _pump(
  WidgetTester tester,
  FakeOtpRepository repository,
) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <String?>[];
  final popped = <bool?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [otpRepositoryProvider.overrideWithValue(repository)],
      child: testApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => popped.add(
              await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const OtpView(contact: _contact),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
        onGenerateRoute: (settings) {
          opened.add(settings.name);
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox(),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return (opened: opened, popped: popped);
}

ButtonStyleButton _verify(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(_en.otpVerify),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );

void main() {
  testWidgets('shows where the code went', (tester) async {
    await _pump(tester, FakeOtpRepository());

    expect(
      find.textContaining('+971 50 123 4567', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('Verify waits for all six digits', (tester) async {
    await _pump(tester, FakeOtpRepository());

    await tester.enterText(find.byType(TextField), '48291');
    await tester.pump();
    expect(_verify(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '482916');
    await tester.pump();
    expect(_verify(tester).onPressed, isNotNull);
  });

  testWidgets('keeps digits only, at most six', (tester) async {
    await _pump(tester, FakeOtpRepository());

    await tester.enterText(find.byType(TextField), '4a8 29167');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '482916');
  });

  testWidgets('a verified code opens the profile in its place', (
    tester,
  ) async {
    final repository = FakeOtpRepository();
    final result = await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), '482916');
    await tester.pump();
    await tester.tap(find.text(_en.otpVerify));
    await tester.pumpAndSettle();

    expect(repository.checked, ['482916']);
    expect(result.opened, [Routes.profile]);
    expect(find.byType(OtpView), findsNothing);
  });

  testWidgets('a rejected code stays with an error', (tester) async {
    final result = await _pump(
      tester,
      FakeOtpRepository(
        failure: const Failure.validation(message: 'Wrong code'),
      ),
    );

    await tester.enterText(find.byType(TextField), '482916');
    await tester.pump();
    await tester.tap(find.text(_en.otpVerify));
    await tester.pumpAndSettle();

    expect(result.opened, isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  for (final (name, link) in [
    ('Edit', () => _en.otpEdit),
    ('Try another number', () => _en.otpTryAnother),
  ]) {
    testWidgets('$name goes back to change the number', (tester) async {
      final result = await _pump(tester, FakeOtpRepository());

      await tester.tapOnText(find.textRange.ofSubstring(link()));
      await tester.pumpAndSettle();

      expect(result.popped, [true]);
    });
  }

  testWidgets('Back returns without asking to change the number', (
    tester,
  ) async {
    final result = await _pump(tester, FakeOtpRepository());

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(result.popped, [null]);
  });

  testWidgets('a code can be resent once the countdown ends', (tester) async {
    final repository = FakeOtpRepository();
    await _pump(tester, repository);

    expect(find.text(_en.otpResend), findsNothing);
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.otpResend));
    await tester.pumpAndSettle();

    expect(repository.sent, [_contact]);
    expect(find.text(_en.otpResent), findsOneWidget);
    expect(find.text(_en.otpResend), findsNothing);
    expect(find.textContaining('00:30', findRichText: true), findsOneWidget);
  });
}
