import 'package:core/routing/route_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_screen.dart';

void main() {
  Future<NavigatorState> pump(
    WidgetTester tester, {
    TextDirection direction = TextDirection.ltr,
  }) async {
    useDesignScreen(tester);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        builder: (context, child) =>
            Directionality(textDirection: direction, child: child!),
        onGenerateRoute: (settings) => pushRoute<void>(
          Text(settings.name!, key: ValueKey<String>(settings.name!)),
          settings,
        ),
      ),
    );
    return navigator.currentState!;
  }

  double left(WidgetTester tester, String name) =>
      tester.getTopLeft(find.byKey(ValueKey<String>(name))).dx;

  testWidgets('pushes in from the end while the page under slides out', (
    tester,
  ) async {
    final navigator = await pump(tester);

    navigator.pushNamed<void>('next').ignore();
    await tester.pump();
    await tester.pump(pushDuration ~/ 2);

    expect(left(tester, 'next'), closeTo(393 / 2, 1));
    expect(left(tester, '/'), closeTo(-393 / 2, 1));

    await tester.pumpAndSettle();
    expect(left(tester, 'next'), 0);
  });

  testWidgets('comes in from the left in right-to-left text', (tester) async {
    final navigator = await pump(tester, direction: TextDirection.rtl);

    navigator.pushNamed<void>('next').ignore();
    await tester.pump();
    await tester.pump(pushDuration ~/ 2);

    expect(left(tester, 'next'), closeTo(-393 / 2, 1));
  });
}
