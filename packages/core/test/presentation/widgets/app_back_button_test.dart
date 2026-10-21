import 'package:core/presentation/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/design_screen.dart';
import '../../support/test_app.dart';

void main() {
  testWidgets('pops the route at the design size', (tester) async {
    useDesignScreen(tester);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      testApp(navigatorKey: navigator, home: const SizedBox()),
    );
    navigator.currentState!
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: AppBackButton()),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AppBackButton)), const Size(44, 44));

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBackButton), findsNothing);
  });

  testWidgets('runs its own action instead, when given', (tester) async {
    useDesignScreen(tester);
    var pressed = 0;
    await tester.pumpWidget(
      testApp(
        home: Scaffold(body: AppBackButton(onPressed: () => pressed++)),
      ),
    );

    await tester.tap(find.byTooltip('Back'));

    expect(pressed, 1);
  });
}
