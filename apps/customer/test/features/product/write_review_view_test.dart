import 'package:core/media/photo_picker.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/presentation/view/review_submitted_view.dart';
import 'package:customer/features/product/presentation/view/write_review_view.dart';
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

class _FakePicker implements PhotoPicker {
  final List<int> limits = <int>[];

  @override
  Future<List<String>> pick({required int limit}) async {
    limits.add(limit);
    return <String>['/tmp/one.jpg', '/tmp/two.jpg'];
  }
}

final Finder _page = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _page.first);
  await tester.pumpAndSettle();
}

Future<(_FakePicker, List<RouteSettings>)> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final picker = _FakePicker();
  final opened = <RouteSettings>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...productOverrides,
        photoPickerProvider.overrideWithValue(picker),
      ],
      child: testApp(
        home: const WriteReviewView(id: _id),
        onGenerateRoute: (settings) {
          opened.add(settings);
          return MaterialPageRoute<void>(builder: (_) => const SizedBox());
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
  return (picker, opened);
}

FilledButton _submit(WidgetTester tester) => tester.widget<FilledButton>(
  find.widgetWithText(FilledButton, _en.productSubmitReview),
);

void main() {
  testWidgets('submit waits for stars and words, then sends', (tester) async {
    final (_, opened) = await _pump(tester);

    expect(_submit(tester).onPressed, isNull);
    await tester.tap(find.bySemanticsLabel(_en.productRateStars(4)));
    await tester.pumpAndSettle();
    expect(find.text(_en.productRatingWord('4')), findsOneWidget);
    expect(_submit(tester).onPressed, isNull);

    await _reveal(tester, find.text(_en.productYourReview));
    await tester.enterText(
      find.byType(TextField).last,
      'Sharp photos and the battery lasts all day.',
    );
    await tester.pumpAndSettle();
    expect(find.text(_en.productReviewCounter('43', '1,000')), findsOneWidget);

    await tester.tap(find.text(_en.productSubmitReview));
    await tester.pumpAndSettle();

    expect(opened.last.name, Routes.reviewSubmitted);
    expect(opened.last.arguments, isA<ReviewReceipt>());
  });

  testWidgets('likes toggle on and off', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Camera')),
      isSemantics(isSelected: true),
    );

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Camera')),
      isSemantics(isSelected: false),
    );
  });

  testWidgets('photos come from the picker, up to the limit', (tester) async {
    final (picker, _) = await _pump(tester);

    await _reveal(tester, find.text(_en.productAddPhoto));
    await tester.tap(find.text(_en.productAddPhoto));
    await tester.pumpAndSettle();

    expect(picker.limits, [6]);
    expect(find.text(_en.productPhotosOf(2, 6)), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(_en.productRemovePhoto).first);
    await tester.pumpAndSettle();
    expect(find.text(_en.productPhotosOf(1, 6)), findsOneWidget);
  });

  testWidgets('the name can be hidden', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.productShowName));
    expect(find.text(_en.productPostedAs('Sam R.')), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text(_en.productPostedAnonymously), findsOneWidget);
  });

  testWidgets('the thanks screen offers the next purchase and the shop', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = DesignScale.designSize;
    addTearDown(tester.view.reset);
    final shopped = <int>[];
    final opened = <RouteSettings>[];
    await tester.pumpWidget(
      testApp(
        home: ReviewSubmittedView(
          receipt: const ReviewReceipt(
            rewardPoints: 50,
            next: ReviewPrompt(
              productId: 'buds-air-3',
              name: 'Buds Air 3 · ANC',
              image: 'packages/core/assets/images/products/buds_air_3.jpg',
            ),
          ),
          onContinueShopping: (_) => shopped.add(1),
        ),
        onGenerateRoute: (settings) {
          opened.add(settings);
          return MaterialPageRoute<void>(builder: (_) => const SizedBox());
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_en.productReviewThanksBody(50)), findsOneWidget);
    await tester.tap(find.text(_en.productContinueShopping));
    expect(shopped, [1]);

    await tester.tap(find.text('Buds Air 3 · ANC'));
    await tester.pumpAndSettle();
    expect(opened.last.name, Routes.writeReview);
    expect(opened.last.arguments, 'buds-air-3');
  });
}
