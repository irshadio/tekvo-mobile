import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/home/data/repositories/home_repository_impl.dart';
import 'package:customer/features/home/domain/entities/product.dart';
import 'package:customer/features/home/presentation/view/widgets/product_card.dart';
import 'package:customer/features/home/presentation/view/widgets/product_card_parts.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();
const Product _product = HomeRepositoryImpl.pulseAncMax;

Future<(ProviderContainer, List<String>)> _pump(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  final container = ProviderContainer.test();
  final opened = <String>[];
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(
        home: Scaffold(
          body: Center(
            child: ProductCard(
              product: _product,
              width: 160,
              onOpen: () => opened.add(_product.id),
            ),
          ),
        ),
      ),
    ),
  );
  return (container, opened);
}

void main() {
  testWidgets('shows the tag, rating, name and both prices', (tester) async {
    await _pump(tester);

    expect(find.text(_en.productDiscount(21)), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text(_en.productRatingCount('3.2k')), findsOneWidget);
    expect(find.text(_product.name), findsOneWidget);
    expect(find.text('AED 1,099'), findsOneWidget);
    expect(find.text('AED 1,399'), findsOneWidget);
  });

  testWidgets('Add puts it in the cart once and turns into a check', (
    tester,
  ) async {
    final (container, _) = await _pump(tester);

    await tester.tap(find.byType(AddToCartButton));
    await tester.pumpAndSettle();

    final cart = container.read(cartViewModelProvider);
    expect(cart.count, CartViewModel.sample + 1);
    expect(cart.added, {_product.id});
    expect(
      tester.widget<AddToCartButton>(find.byType(AddToCartButton)).added,
      isTrue,
    );

    await tester.tap(find.byType(AddToCartButton));
    await tester.pumpAndSettle();
    expect(
      container.read(cartViewModelProvider).count,
      CartViewModel.sample + 1,
    );
  });

  testWidgets('the heart saves and unsaves it', (tester) async {
    final (container, _) = await _pump(tester);

    await tester.tap(find.byTooltip(_en.productSave(_product.name)));
    await tester.pumpAndSettle();
    expect(container.read(wishlistViewModelProvider), {_product.id});

    await tester.tap(find.byTooltip(_en.productUnsave(_product.name)));
    await tester.pumpAndSettle();
    expect(container.read(wishlistViewModelProvider), isEmpty);
  });

  testWidgets('tapping the card opens the product', (tester) async {
    final (_, opened) = await _pump(tester);

    await tester.tap(find.text(_product.name));

    expect(opened, [_product.id]);
  });
}
