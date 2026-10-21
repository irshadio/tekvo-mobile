import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/main/presentation/view/main_view.dart';
import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final container = ProviderContainer.test();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(
        home: const MainView(pages: {MainTab.home: Text('home page')}),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('opens on home with every tab in the bar', (tester) async {
    await _pump(tester);

    expect(find.text('home page'), findsOneWidget);
    for (final label in [
      _en.navHome,
      _en.navExplore,
      _en.navCart,
      _en.navWishlist,
      _en.navProfile,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('a tab without a screen yet shows a placeholder', (
    tester,
  ) async {
    final container = await _pump(tester);

    await tester.tap(find.text(_en.navWishlist));
    await tester.pumpAndSettle();

    expect(container.read(mainTabViewModelProvider), MainTab.wishlist);
    expect(find.text(_en.mainComingSoon), findsOneWidget);
  });

  testWidgets('back on another tab returns home', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text(_en.navProfile));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(container.read(mainTabViewModelProvider), MainTab.home);
  });

  testWidgets('the cart tab counts the items in the cart', (tester) async {
    final container = await _pump(tester);

    expect(find.text('${CartViewModel.sample}'), findsOneWidget);

    container.read(cartViewModelProvider.notifier).add('sample');
    await tester.pumpAndSettle();

    expect(find.text('${CartViewModel.sample + 1}'), findsOneWidget);
  });
}
