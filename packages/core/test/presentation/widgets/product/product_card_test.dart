import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:core/presentation/widgets/product/cart_shortcut.dart';
import 'package:core/presentation/widgets/product/product_card.dart';
import 'package:core/presentation/widgets/product/product_card_parts.dart';
import 'package:core/presentation/widgets/product/wishlist_heart_button.dart';
import 'package:core/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/design_screen.dart';
import '../../../support/test_app.dart';

final CoreLocalizations _en = lookupCoreLocalizations(const Locale('en'));
const Product _product = Product(
  id: 'pulse-anc-max',
  name: 'Pulse ANC Max Headphones',
  image: Assets.productsPulseAncMax,
  price: Money.units(1099),
  was: Money.units(1399),
  rating: 4.8,
  ratingCount: 3200,
  tag: SaleTag(21),
);

Future<(ProviderContainer, List<String>)> _pump(
  WidgetTester tester, {
  VoidCallback? onOpenCart,
  bool flat = false,
}) async {
  useDesignScreen(tester);
  final container = ProviderContainer.test();
  final opened = <String>[];
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(
        home: Scaffold(
          body: CartShortcut(
            onOpenCart: onOpenCart ?? () {},
            child: Center(
              child: ProductCard(
                product: _product,
                width: 160,
                flat: flat,
                onOpen: () => opened.add(_product.id),
              ),
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

  testWidgets('Add puts it in the cart once; the check opens the cart', (
    tester,
  ) async {
    var cartOpened = 0;
    final (container, _) = await _pump(
      tester,
      onOpenCart: () => cartOpened++,
    );

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

  testWidgets('the heart pops when saved', (tester) async {
    await _pump(tester);
    double scale() => tester
        .widget<ScaleTransition>(
          find
              .descendant(
                of: find.byType(WishlistHeartButton),
                matching: find.byType(ScaleTransition),
              )
              .first,
        )
        .scale
        .value;

    expect(scale(), 1);
    await tester.tap(find.byType(WishlistHeartButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), greaterThan(1));

    await tester.pumpAndSettle();
    expect(scale(), 1);
  });

  testWidgets('tapping the card opens the product', (tester) async {
    final (_, opened) = await _pump(tester);

    await tester.tap(find.text(_product.name));

    expect(opened, [_product.id]);
  });

  testWidgets('a flat card is square', (
    tester,
  ) async {
    await _pump(tester, flat: true);

    final card = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(ProductCard),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(card.borderRadius, BorderRadius.zero);
  });
}
