import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  test('whole units are minor units times a hundred', () {
    expect(const Money.units(1099), const Money(109900));
    expect(const Money(1250).isWhole, isFalse);
  });

  testWidgets('formats with the currency code and grouping', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      testApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(context.money(const Money.units(1099)), 'AED 1,099');
    expect(context.money(const Money.units(3499)), 'AED 3,499');
    expect(context.money(const Money(1250)), 'AED 12.50');
  });
}
