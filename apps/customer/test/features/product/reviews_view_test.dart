import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/reviews_view.dart';
import 'package:customer/features/product/presentation/view_model/product_choices_view_model.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();
const String _id = 'nova-x-pro';

typedef _Pumped = ({ProviderContainer container, List<RouteSettings> opened});

Future<_Pumped> _pump(
  WidgetTester tester, {
  ReviewFilter filter = ReviewFilter.all,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final opened = <RouteSettings>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: productOverrides,
      child: testApp(
        home: ReviewsView(id: _id, filter: filter),
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
      tester.element(find.byType(ReviewsView)),
    ),
    opened: opened,
  );
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
  testWidgets('shows the summary, topics and the most helpful first', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(_en.productReviewsTitle), findsOneWidget);
    expect(find.text(_en.productWhatBuyersSay), findsOneWidget);
    await _reveal(tester, find.text(_en.productReviewsCount('2,318')));
    await _reveal(tester, find.text('Two days on one charge'));
  });

  testWidgets('a star filter keeps only those reviews', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text(_en.productReviewFilterLow));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.productReviewFilterLow));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Good, but pricey'));

    expect(find.text('Two days on one charge'), findsNothing);
    expect(find.text(_en.productSellerReply('Nova Official Store')), findsOne);
  });

  testWidgets('opens on the filter it was asked for', (tester) async {
    await _pump(tester, filter: ReviewFilter.withPhotos);

    await _reveal(tester, find.text('Best zoom I have used'));
    expect(find.text('Fast delivery, great screen'), findsNothing);
  });

  testWidgets('sorting by newest reorders the list', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.productSortHelpful));
    await tester.tap(find.text(_en.productSortHelpful));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.productSortNewest));
    await tester.pumpAndSettle();

    expect(find.text(_en.productSortNewest), findsOneWidget);
    final ahmed = tester.getTopLeft(find.text('Two days on one charge')).dy;
    final priya = tester
        .getTopLeft(find.text('Fast delivery, great screen'))
        .dy;
    expect(ahmed, lessThan(priya));
  });

  testWidgets('Show more reviews loads the next page', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.productMoreReviews));
    await tester.tap(find.text(_en.productMoreReviews));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Lovely screen, heavy in hand'));

    expect(find.text(_en.productMoreReviews), findsNothing);
  });

  testWidgets('helpful marks are shared with the product page', (
    tester,
  ) async {
    final pumped = await _pump(tester);

    await _reveal(tester, find.text(_en.productHelpful(24)));
    await tester.tap(find.text(_en.productHelpful(24)));
    await tester.pumpAndSettle();

    expect(
      pumped.container.read(productChoicesViewModelProvider(_id)).helpful,
      {'r-ahmed'},
    );
  });

  testWidgets('Write a review opens the form for this product', (
    tester,
  ) async {
    final pumped = await _pump(tester);

    await tester.tap(find.text(_en.productWriteReview));
    await tester.pumpAndSettle();

    expect(pumped.opened.last.name, Routes.writeReview);
    expect(pumped.opened.last.arguments, _id);
  });
}
