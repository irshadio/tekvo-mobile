import 'dart:async';

import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/widgets/country_picker_sheet.dart';
import 'package:core/presentation/widgets/country_tile.dart';
import 'package:country/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/design_screen.dart';
import '../../support/test_app.dart';

final CoreLocalizations _en = lookupCoreLocalizations(const Locale('en'));

Future<List<Country>> _open(WidgetTester tester) async {
  useDesignScreen(tester);
  final picked = <Country>[];
  await tester.pumpWidget(
    ProviderScope(
      child: testApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => unawaited(
                  CountryPickerSheet.show(
                    context,
                    selected: Countries.are,
                    onSelected: picked.add,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return picked;
}

Finder _tile(String name) => find.ancestor(
  of: find.text(name),
  matching: find.byType(CountryTile),
);

void main() {
  testWidgets('shows the current country above all the others', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text(_en.countryPickerCurrent), findsOneWidget);
    expect(find.text(_en.countryPickerAll), findsOneWidget);
    expect(_tile('United Arab Emirates'), findsOneWidget);
    expect(
      tester.widget<CountryTile>(_tile('United Arab Emirates')).selected,
      isTrue,
    );
    expect(
      tester.getTopLeft(_tile('Saudi Arabia')).dy,
      greaterThan(tester.getTopLeft(_tile('United Arab Emirates')).dy),
    );
  });

  testWidgets('rises to the design height', (tester) async {
    await _open(tester);

    expect(tester.getSize(find.byType(CountryPickerSheet)).height, 700);
  });

  testWidgets('the keyboard shortens the list instead of overflowing', (
    tester,
  ) async {
    await _open(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.byType(CountryPickerSheet)).dy,
      lessThanOrEqualTo(852 - 336),
    );
  });

  testWidgets('a search lists the matches with their count and a tip', (
    tester,
  ) async {
    await _open(tester);

    await tester.enterText(find.byType(TextField), '+966');
    await tester.pump(CountryPickerSheet.searchDelay);
    await tester.pump();

    expect(find.text(_en.countryPickerCurrent), findsNothing);
    expect(find.text(_en.countryPickerResults(1)), findsOneWidget);
    expect(find.text(_en.countryPickerTip), findsOneWidget);
    expect(_tile('Saudi Arabia'), findsOneWidget);
    expect(_tile('India'), findsNothing);
  });

  testWidgets('picking a country reports it and closes the sheet', (
    tester,
  ) async {
    final picked = await _open(tester);

    await tester.tap(find.text('Qatar'));
    await tester.pumpAndSettle();

    expect(picked, [Countries.qat]);
    expect(find.byType(CountryPickerSheet), findsNothing);
  });

  testWidgets('a second tap while closing is ignored', (tester) async {
    final picked = await _open(tester);

    await tester.tap(find.text('Qatar'));
    await tester.pump();
    await tester.tap(find.text('Kuwait'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(picked, [Countries.qat]);
  });

  testWidgets('Close leaves the country as it was', (tester) async {
    final picked = await _open(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(picked, isEmpty);
    expect(find.byType(CountryPickerSheet), findsNothing);
  });
}
