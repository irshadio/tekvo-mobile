import 'package:core/error/failure.dart';
import 'package:core/l10n/app_locale.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  final l10n = lookupCoreLocalizations(AppLocale.current);

  Widget host(ViewState<int> state) => testApp(
    home: Scaffold(
      body: ViewStateSwitcher<int>(
        state: state,
        onData: (value) => Text('value $value'),
      ),
    ),
  );

  testWidgets('data renders onData', (tester) async {
    await tester.pumpWidget(host(const ViewState<int>.data(7)));
    expect(find.text('value 7'), findsOneWidget);
  });

  testWidgets('loading renders the default loading view', (tester) async {
    await tester.pumpWidget(host(const ViewState<int>.loading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error renders the failure message', (tester) async {
    await tester.pumpWidget(
      host(const ViewState<int>.error(Failure.unexpected(message: 'boom'))),
    );
    expect(find.text(l10n.errorUnexpected), findsOneWidget);
    expect(find.text('boom'), findsNothing);
  });

  testWidgets('noInternet renders the offline view', (tester) async {
    await tester.pumpWidget(host(const ViewState<int>.noInternet()));
    expect(find.text(l10n.errorNoConnection), findsOneWidget);
  });

  testWidgets('loading with previous keeps data visible (no spinner)', (
    tester,
  ) async {
    await tester.pumpWidget(host(const ViewState<int>.loading(previous: 7)));
    expect(find.text('value 7'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('error with previous keeps data visible (no error view)', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const ViewState<int>.error(
          Failure.unexpected(message: 'boom'),
          previous: 7,
        ),
      ),
    );
    expect(find.text('value 7'), findsOneWidget);
    expect(find.text(l10n.errorUnexpected), findsNothing);
  });
}
