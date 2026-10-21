import 'package:core/presentation/widgets/app_logo_mark.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_palette.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, ThemeMode mode) => tester.pumpWidget(
  DesignScale(
    builder: (_) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const Center(child: AppLogoMark(size: 32)),
    ),
  ),
);

Color? _tile(WidgetTester tester) =>
    (tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(AppLogoMark),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration)
        .color;

void main() {
  testWidgets('draws the tile in the theme primary', (tester) async {
    await _pump(tester, ThemeMode.light);
    expect(_tile(tester), AppPalette.brand600);
    expect(tester.getSize(find.byType(AppLogoMark)), const Size.square(32));

    await _pump(tester, ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(_tile(tester), AppPalette.brand300);
  });

  test('the spark uses the deal colour in both themes', () {
    expect(AppColors.light.commerceDeal, AppPalette.volt300);
    expect(AppColors.dark.commerceDeal, AppPalette.volt300);
  });
}
