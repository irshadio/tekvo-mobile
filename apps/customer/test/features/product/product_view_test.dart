import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/sharing/share_service.dart';
import 'package:customer/features/product/data/repositories/product_repository_impl.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/presentation/view/product_view.dart';
import 'package:customer/features/product/presentation/view_model/added_toast_view_model.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();
const ProductDetails _sample = ProductRepositoryImpl.sample;

class _FakeShare implements ShareService {
  final List<String> shared = <String>[];

  @override
  Future<void> shareText(String text, {String? subject}) async =>
      shared.add(text);
}

typedef _Pumped = ({
  ProviderContainer container,
  _FakeShare share,
  List<int> cartOpened,
});

Future<_Pumped> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final share = _FakeShare();
  final cartOpened = <int>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...productOverrides,
        shareServiceProvider.overrideWithValue(share),
      ],
      child: testApp(
        home: ProductView(
          id: _sample.id,
          onOpenCart: (_) => cartOpened.add(1),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(ProductView)),
  );
  return (container: container, share: share, cartOpened: cartOpened);
}

void main() {
  testWidgets('shows the product, its price and saving', (tester) async {
    await _pump(tester);

    expect(find.text(_sample.title), findsOneWidget);
    expect(find.text('AED 3,499'), findsWidgets);
    expect(find.text(_en.productSaving('AED 500')), findsOneWidget);
    expect(
      find.text(_en.productPhotoCount(1, _sample.images.length)),
      findsOneWidget,
    );
  });

  testWidgets('Add to cart becomes a stepper and shows the toast', (
    tester,
  ) async {
    final pumped = await _pump(tester);

    await tester.tap(find.text(_en.productAddToCart));
    await tester.pumpAndSettle();

    expect(
      pumped.container.read(cartViewModelProvider).quantityOf(_sample.id),
      1,
    );
    expect(find.text(_en.productAddedToCart), findsOneWidget);

    await tester.tap(find.byTooltip(_en.productIncrease));
    await tester.pumpAndSettle();
    expect(
      pumped.container.read(cartViewModelProvider).quantityOf(_sample.id),
      2,
    );

    await tester.tap(find.text(_en.productViewCart));
    await tester.pumpAndSettle();
    expect(pumped.cartOpened, [1]);
    expect(find.text(_en.productAddedToCart), findsNothing);
  });

  testWidgets('the toast hides by itself', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.productAddToCart));
    await tester.pumpAndSettle();
    await tester.pump(AddedToastViewModel.shown);
    await tester.pumpAndSettle();

    expect(find.text(_en.productAddedToCart), findsNothing);
  });

  testWidgets('removing the last one brings Add to cart back', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.productAddToCart));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(_en.productDecrease));
    await tester.pumpAndSettle();

    expect(find.text(_en.productAddToCart), findsOneWidget);
  });

  testWidgets('a thumbnail shows its photo', (tester) async {
    await _pump(tester);

    await tester.tap(find.bySemanticsLabel(_en.productPhoto(2, 6)).last);
    await tester.pumpAndSettle();

    expect(find.text(_en.productPhotoCount(2, 6)), findsOneWidget);
  });

  testWidgets('share sends the product name', (tester) async {
    final pumped = await _pump(tester);

    await tester.tap(find.byTooltip(_en.productShare));
    await tester.pump();

    expect(pumped.share.shared, [_sample.title]);
  });

  testWidgets('the coupon applies once', (tester) async {
    await _pump(tester);

    await tester.scrollUntilVisible(
      find.text(_en.productCouponApply),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.productCouponApply));
    await tester.pump();

    expect(find.text(_en.productCouponApplied), findsOneWidget);
    expect(find.text(_en.productCouponAppliedNote), findsOneWidget);
  });
}
