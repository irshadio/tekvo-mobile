import 'package:core/presentation/widgets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/design_screen.dart';
import '../../support/test_app.dart';

Future<List<int?>> _open(WidgetTester tester) async {
  useDesignScreen(tester);
  final results = <int?>[];
  await tester.pumpWidget(
    testApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => results.add(
            await ChoiceSheet.show(
              context,
              title: 'Sort by',
              options: const <String>['Most helpful', 'Newest', 'Lowest'],
              selected: 0,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  testWidgets('closes with the tapped option', (tester) async {
    final results = await _open(tester);

    expect(find.text('Sort by'), findsOneWidget);
    await tester.tap(find.text('Newest'));
    await tester.pumpAndSettle();

    expect(results, [1]);
    expect(find.text('Sort by'), findsNothing);
  });

  testWidgets('close dismisses without a choice', (tester) async {
    final results = await _open(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
