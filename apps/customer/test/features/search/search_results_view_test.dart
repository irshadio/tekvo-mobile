import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/presentation/view/search_filters_view.dart';
import 'package:customer/features/search/presentation/view/search_results_view.dart';
import 'package:customer/features/search/search_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

Future<void> _pump(WidgetTester tester, String query) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: searchOverrides,
      child: testApp(
        home: SearchResultsView(query: query),
        onGenerateRoute: (settings) => switch (settings.arguments) {
          final FiltersRequest request
              when settings.name == Routes.searchFilters =>
            MaterialPageRoute<SearchFilters>(
              builder: (_) => SearchFiltersView(
                query: request.query,
                filters: request.filters,
              ),
            ),
          _ => MaterialPageRoute<void>(builder: (_) => const SizedBox()),
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists what the search finds, with its store', (tester) async {
    await _pump(tester, 'nova');

    expect(find.text(_en.searchResultsCount(6, 'nova')), findsOneWidget);
    expect(find.text('Nova Official Store'), findsOneWidget);
  });

  testWidgets('a quick filter narrows the results', (tester) async {
    await _pump(tester, 'nova');

    await tester.ensureVisible(find.text(_en.searchQuickUnder));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.searchQuickUnder));
    await tester.pumpAndSettle();

    expect(find.text(_en.searchResultsCount(3, 'nova')), findsOneWidget);
  });

  testWidgets('filters count as they are chosen and apply', (tester) async {
    await _pump(tester, 'nova');

    await tester.tap(find.text(_en.searchFilters));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.searchFacetCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phones'));
    await tester.pumpAndSettle();
    expect(find.text(_en.searchShowResults(2)), findsOneWidget);

    await tester.tap(find.text(_en.searchShowResults(2)));
    await tester.pumpAndSettle();

    expect(find.text(_en.searchResultsCount(2, 'nova')), findsOneWidget);
  });

  testWidgets('nothing found suggests a spelling and a category', (
    tester,
  ) async {
    await _pump(tester, 'nova x pro max 1tb');

    expect(find.text(_en.searchNoResults('nova x pro max 1tb')), findsOne);
    expect(find.text(_en.searchDidYouMean('nova x pro')), findsOneWidget);
    expect(find.text(_en.searchBrowseAll('phones')), findsOneWidget);
  });
}
