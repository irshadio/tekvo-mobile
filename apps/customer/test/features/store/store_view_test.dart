import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/store/presentation/view/store_view.dart';
import 'package:customer/features/store/store_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

Future<List<RouteSettings>> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <RouteSettings>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: storeOverrides,
      child: testApp(
        home: const StoreView(brand: 'Nova'),
        onGenerateRoute: (settings) {
          opened.add(settings);
          return MaterialPageRoute<void>(builder: (_) => const SizedBox());
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
  return opened;
}

final Finder _page = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _page.first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows who the store is and how it does', (tester) async {
    await _pump(tester);

    expect(find.text('Nova Official Store'), findsOneWidget);
    expect(find.text(_en.storeSearchHint('Nova')), findsOneWidget);
    expect(find.text('126k'), findsOneWidget);
    expect(find.text(_en.storeHours(24)), findsOneWidget);
  });

  testWidgets('Follow turns into Following and back', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.storeFollow));
    await tester.pumpAndSettle();
    expect(find.text(_en.storeFollowing), findsOneWidget);

    await tester.tap(find.text(_en.storeFollowing));
    await tester.pumpAndSettle();
    expect(find.text(_en.storeFollow), findsOneWidget);
  });

  testWidgets('collecting a coupon marks it collected', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.storeCollect).first);
    expect(find.text(_en.storeCollected), findsOneWidget);
    await tester.tap(find.text(_en.storeCollect).first);
    await tester.pumpAndSettle();

    expect(find.text(_en.storeCollected), findsNWidgets(2));
    expect(find.text(_en.storeCouponCollected), findsOneWidget);
  });

  testWidgets('On sale keeps only discounted products', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.storeSortOnSale));
    await tester.tap(find.text(_en.storeSortOnSale));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Nova Book 14 · 16GB'));

    expect(find.text('Nova Pulse ANC'), findsNothing);
  });

  testWidgets('the Products tab jumps to the product grid', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.storeTabProducts));
    await tester.pumpAndSettle();

    expect(find.text(_en.storeAllProducts), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(_en.storeAllProducts)).dy,
      lessThan(tester.getBottomLeft(_page.first).dy),
    );
  });

  testWidgets('a category opens its product list', (tester) async {
    final opened = await _pump(tester);

    await _reveal(tester, find.text('Tablets & PCs'));
    await tester.tap(find.text('Tablets & PCs'));
    await tester.pumpAndSettle();

    expect(opened.last.name, Routes.productList);
    expect(opened.last.arguments, ShopCategory.laptops);
  });
}
