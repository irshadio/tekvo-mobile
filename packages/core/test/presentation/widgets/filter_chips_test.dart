import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/design_screen.dart';
import '../../support/test_app.dart';

const List<String> _labels = <String>[
  'Overview',
  'Display',
  'Performance',
  'Camera',
  'Battery',
  'Design',
  'Connectivity',
];

Widget _chips(int selected, ValueChanged<int> onSelect) => testApp(
  home: Scaffold(
    body: FilterChips(
      labels: _labels,
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

double _rowOffset(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;

void main() {
  testWidgets('reports the tapped chip', (tester) async {
    useDesignScreen(tester);
    final picked = <int>[];
    await tester.pumpWidget(_chips(0, picked.add));

    await tester.tap(find.text('Display'));

    expect(picked, [1]);
  });

  testWidgets('scrolls a chosen chip off the edge into view', (tester) async {
    useDesignScreen(tester);
    await tester.pumpWidget(_chips(0, (_) {}));
    expect(_rowOffset(tester), 0);

    await tester.pumpWidget(_chips(_labels.length - 1, (_) {}));
    await tester.pumpAndSettle();

    expect(_rowOffset(tester), greaterThan(0));
    final chip = tester.getRect(find.text('Connectivity'));
    expect(chip.right, lessThanOrEqualTo(393));
  });
}
