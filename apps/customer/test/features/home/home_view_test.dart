import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/home/data/repositories/home_repository_impl.dart';
import 'package:customer/features/home/domain/entities/shop_category.dart';
import 'package:customer/features/home/home_overrides.dart';
import 'package:customer/features/home/presentation/view/home_view.dart';
import 'package:customer/features/home/presentation/view/widgets/hero_carousel.dart';
import 'package:customer/features/home/presentation/view/widgets/page_dots.dart';
import 'package:customer/features/home/presentation/view_model/phone_filter_view_model.dart';
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

  testWidgets('flash deals count down and show how much has sold', (
    tester,
  ) async {
    await _pump(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();

    expect(find.text(_en.homeSold(72)), findsOneWidget);
    expect(find.text('14'), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('36'), findsWidgets);
  });

  testWidgets('a phone filter keeps only its phones', (tester) async {
    await _pump(tester);
    await tester.scrollUntilVisible(
      find.text(_en.homeBestInPhones),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    // Below the pinned header, which takes taps over its area.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 250));
    await tester.pumpAndSettle();
    const sample = HomeRepositoryImpl.sample;

    expect(find.text(HomeRepositoryImpl.novaSLite.name), findsOneWidget);
    await tester.tap(find.text(sample.phoneFacets.first.label));
    await tester.pumpAndSettle();

    expect(find.text(HomeRepositoryImpl.novaXPro.name), findsOneWidget);
    expect(find.text(HomeRepositoryImpl.novaSLite.name), findsNothing);

    ProviderScope.containerOf(tester.element(find.byType(HomeView)))
        .read(phoneFilterViewModelProvider.notifier)
        .select(sample.phoneFacets.length - 1);
    await tester.pumpAndSettle();
    expect(find.text(_en.homeNoProducts), findsOneWidget);
  });

  testWidgets('Show more adds the further recommendations', (tester) async {
    await _pump(tester);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text(_en.homeShowMore),
      600,
      scrollable: scrollable,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.homeShowMore));
    await tester.pumpAndSettle();

    expect(find.text(_en.homeShowMore), findsNothing);
    await tester.scrollUntilVisible(
      find.text(HomeRepositoryImpl.playCore5.name).last,
      400,
      scrollable: scrollable,
    );
    expect(find.text(HomeRepositoryImpl.playCore5.name), findsWidgets);
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

  testWidgets('the hero moves on by itself and loops back to the first', (
    tester,
  ) async {
    await _pump(tester);
    int current() => tester.widget<PageDots>(find.byType(PageDots)).current;

    final count = HomeRepositoryImpl.sample.hero.length;
    for (var i = 1; i <= count; i++) {
      await tester.pump(HeroCarousel.autoAdvance);
      await tester.pump(HeroCarousel.slide);
      expect(current(), i % count);
    }
  });

  testWidgets('the hero swipes back past the first card', (tester) async {
    await _pump(tester);

    await tester.drag(
      find.text(HomeRepositoryImpl.sample.hero.first.title),
      const Offset(300, 0),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<PageDots>(find.byType(PageDots)).current,
      HomeRepositoryImpl.sample.hero.length - 1,
    );
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
