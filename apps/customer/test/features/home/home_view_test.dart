import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/home/data/repositories/home_repository_impl.dart';
import 'package:customer/features/home/domain/entities/shop_category.dart';
import 'package:customer/features/home/home_overrides.dart';
import 'package:customer/features/home/presentation/view/home_view.dart';
import 'package:customer/features/home/presentation/view/widgets/page_dots.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

typedef _Next = ({String? name, Object? arguments});

Future<({List<_Next> opened, List<String> tabs})> _pump(
  WidgetTester tester,
) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <_Next>[];
  final tabs = <String>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: homeOverrides,
      child: testApp(
        home: Scaffold(
          body: HomeView(
            onOpenExplore: () => tabs.add('explore'),
            onOpenCart: () => tabs.add('cart'),
          ),
        ),
        onGenerateRoute: (settings) {
          opened.add((name: settings.name, arguments: settings.arguments));
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox(),
          );
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return (opened: opened, tabs: tabs);
}

void main() {
  testWidgets('shows where orders go and the shop promises', (tester) async {
    await _pump(tester);
    const feed = HomeRepositoryImpl.sample;

    expect(find.text(feed.deliveryArea), findsOneWidget);
    expect(find.text(_en.homeDeliverTo(feed.deliveryEta)), findsOneWidget);
    expect(find.text(_en.homeFreeDelivery('AED 200')), findsOneWidget);
    expect(find.text(feed.hero.first.title), findsOneWidget);
  });

  testWidgets('a category opens its products', (tester) async {
    final result = await _pump(tester);

    await tester.tap(find.text(_en.categoryAudio));
    await tester.pumpAndSettle();

    expect(result.opened.single, (
      name: Routes.productList,
      arguments: ShopCategory.audio,
    ));
  });

  testWidgets('See all and the cart switch tabs', (tester) async {
    final result = await _pump(tester);

    await tester.tap(find.text(_en.homeSeeAll).first);
    await tester.tap(find.byTooltip(_en.homeCart(3)));

    expect(result.tabs, ['explore', 'cart']);
  });

  testWidgets('search and notifications open their screens', (tester) async {
    final result = await _pump(tester);

    await tester.tap(find.text(_en.homeSearchHint));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(_en.homeNotifications));
    await tester.pumpAndSettle();

    expect(result.opened.map((r) => r.name), [
      Routes.search,
      Routes.notifications,
    ]);
  });

  testWidgets('swiping the hero moves the dots', (tester) async {
    await _pump(tester);

    expect(tester.widget<PageDots>(find.byType(PageDots)).current, 0);
    await tester.drag(
      find.text(HomeRepositoryImpl.sample.hero.first.title),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<PageDots>(find.byType(PageDots)).current, 1);
  });

  testWidgets('a promotion opens its product', (tester) async {
    final result = await _pump(tester);

    await tester.tap(find.text(HomeRepositoryImpl.sample.hero.first.title));
    await tester.pumpAndSettle();

    expect(result.opened.single, (
      name: Routes.product,
      arguments: HomeRepositoryImpl.sample.hero.first.id,
    ));
  });
}
