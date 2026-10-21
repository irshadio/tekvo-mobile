import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/presentation/view/specifications_view.dart';
import 'package:customer/features/product/presentation/view_model/spec_section_view_model.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();
const String _id = 'nova-x-pro';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  SpecGroupKind? start,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: productOverrides,
      child: testApp(
        home: SpecificationsView(id: _id, start: start),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(
    tester.element(find.byType(SpecificationsView)),
  );
}

final Finder _page = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

double _top(WidgetTester tester, String title) =>
    tester.getTopLeft(find.text(title).last).dy;

void main() {
  testWidgets('lists every group and the note', (tester) async {
    await _pump(tester);

    expect(find.text(_en.productSpecsTitle), findsOneWidget);
    expect(find.text('Nova X Pro 5G'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(_en.productSpecsNote),
      400,
      scrollable: _page.first,
    );
    expect(find.text('In the box & warranty'), findsOneWidget);
  });

  testWidgets('a chip jumps to its group and stays chosen', (tester) async {
    final container = await _pump(tester);
    final listTop = tester.getTopLeft(_page.first).dy;

    await tester.ensureVisible(find.text('Camera').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera').first);
    await tester.pumpAndSettle();

    expect(_top(tester, 'Camera').floorToDouble(), greaterThan(listTop));
    expect(container.read(specSectionViewModelProvider(_id)), 3);
  });

  testWidgets('the chosen chip follows the scroll', (tester) async {
    final container = await _pump(tester);

    await tester.scrollUntilVisible(
      find.text('Ultra-wide'),
      300,
      scrollable: _page.first,
    );
    await tester.pumpAndSettle();

    expect(container.read(specSectionViewModelProvider(_id)), 3);
  });

  testWidgets('opens on the group it was asked for', (tester) async {
    await _pump(tester, start: SpecGroupKind.battery);

    expect(find.text('Capacity'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Capacity')).dy,
      lessThan(tester.getBottomLeft(_page.first).dy),
    );
  });

  testWidgets('Add to cart adds the product', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text(_en.productAddToCart));
    await tester.pumpAndSettle();

    expect(container.read(cartViewModelProvider).quantityOf(_id), 1);
  });
}
