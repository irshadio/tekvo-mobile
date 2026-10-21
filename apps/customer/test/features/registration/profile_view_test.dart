import 'package:core/error/failure.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/registration/domain/repositories/profile_repository.dart';
import 'package:customer/features/registration/presentation/view/profile_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

const SocialAccount _google = SocialAccount(
  provider: SocialProvider.google,
  name: 'Sam Rivera',
  email: 'sam.rivera@gmail.com',
);

class _FakeProfileRepository implements ProfileRepository {
  final List<({String name, String? email})> saved =
      <({String name, String? email})>[];

  @override
  Future<Either<Failure, Unit>> save({
    required String name,
    String? email,
  }) async {
    saved.add((name: name, email: email));
    return right(unit);
  }
}

Future<List<String?>> _pump(
  WidgetTester tester,
  _FakeProfileRepository repository, {
  SocialAccount? account,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <String?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
      child: testApp(
        home: ProfileView(account: account),
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
  await tester.pumpAndSettle();
  return opened;
}

ButtonStyleButton _button(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );

void main() {
  testWidgets('Continue waits for a name and a well-formed email', (
    tester,
  ) async {
    await _pump(tester, _FakeProfileRepository());

    expect(_button(tester, _en.profileContinue).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Sam Rivera');
    await tester.pump();
    expect(_button(tester, _en.profileContinue).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField).last, 'sam@');
    await tester.pump();
    expect(_button(tester, _en.profileContinue).onPressed, isNull);
  });

  testWidgets('saves the profile and opens home on its own', (tester) async {
    final repository = _FakeProfileRepository();
    final opened = await _pump(tester, repository);

    await tester.enterText(find.byType(TextField).first, '  Sam Rivera ');
    await tester.pump();
    await tester.tap(find.text(_en.profileContinue));
    await tester.pumpAndSettle();

    expect(repository.saved.single, (name: 'Sam Rivera', email: null));
    expect(opened, [Routes.home]);
    expect(find.byType(ProfileView), findsNothing);
  });

  testWidgets('a Google account fills in the details to check', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    await _pump(tester, repository, account: _google);

    expect(find.text(_en.profileCheckTitle), findsOneWidget);
    expect(find.text(_en.profileVerifiedNote('Google')), findsOneWidget);
    expect(find.text('Sam Rivera'), findsOneWidget);

    await tester.tap(find.text(_en.profileLooksGood));
    await tester.pumpAndSettle();

    expect(repository.saved.single, (
      name: 'Sam Rivera',
      email: 'sam.rivera@gmail.com',
    ));
  });
}
