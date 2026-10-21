import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_screen.dart';

void main() {
  Future<double> scaled(
    WidgetTester tester,
    TextScaler scaler,
    double length,
  ) async {
    late double result;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: scaler),
        child: Builder(
          builder: (context) {
            result = context.textScaled(length, fontSize: 12);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('textScaled keeps a length at the default text size', (
    tester,
  ) async {
    expect(await scaled(tester, TextScaler.noScaling, 43), 43);
    expect(await scaled(tester, TextScaler.noScaling, 9.3), 9.3);
  });

  testWidgets('textScaled grows a length with the text', (tester) async {
    expect(await scaled(tester, const TextScaler.linear(2), 43), 86);
    expect(await scaled(tester, const TextScaler.linear(1.5), 10), 15);
  });

  Future<double> box(WidgetTester tester, double scale) async {
    useDesignScreen(tester);
    late double result;
    await tester.pumpWidget(
      DesignScale(
        builder: (_) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              result = context.textBox(20, size: 14);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return result;
  }

  testWidgets('textBox is the line height at the default text size', (
    tester,
  ) async {
    expect(await box(tester, 1), 20);
  });

  testWidgets('textBox grows with the text and rounds up to a pixel', (
    tester,
  ) async {
    expect(await box(tester, 1.33), 27);
  });
}
