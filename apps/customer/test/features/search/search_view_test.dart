import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/search/presentation/view/search_view.dart';
import 'package:customer/features/search/presentation/view_model/search_home_view_model.dart';
import 'package:customer/features/search/search_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

typedef _Pumped = ({ProviderContainer container, List<RouteSettings> opened});

Future<_Pumped> _pump(WidgetTester tester, {String query = ''}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <RouteSettings>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: searchOverrides,
      child: testApp(
        home: SearchView(query: query),
        onGenerateRoute: (settings) {
          opened.add(settings);
          return MaterialPageRoute<void>(builder: (_) => const SizedBox());
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
  return (
    container: ProviderScope.containerOf(
      tester.element(find.byType(SearchView)),
    ),
    opened: opened,
  );
}

void main() {
  testWidgets('before typing it shows recent and trending searches', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(_en.searchRecent), findsOneWidget);
    expect(find.text('gaming laptop'), findsOneWidget);
    expect(find.text('foldable phones'), findsOneWidget);
  });

  testWidgets('typing shows suggestions, the store and products', (
    tester,
  ) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'nova');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Nova Official Store'), findsOneWidget);
    expect(find.text(_en.searchProducts), findsOneWidget);
    expect(find.text(_en.searchRecent), findsNothing);
  });

  testWidgets('searching opens the results and remembers it', (tester) async {
    final pumped = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'buds');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(pumped.opened.last.name, Routes.searchResults);
    expect(pumped.opened.last.arguments, 'buds');
    expect(
      pumped.container.read(searchHistoryViewModelProvider)!.first,
      'buds',
    );
  });

  testWidgets('Clear forgets recent searches', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.searchClearRecent));
    await tester.pumpAndSettle();

    expect(find.text(_en.searchRecent), findsNothing);
  });
}
