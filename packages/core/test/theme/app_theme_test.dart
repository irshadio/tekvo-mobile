import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_palette.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_screen.dart';

/// Builds both themes inside [DesignScale], where `.sp` is defined.
Future<(ThemeData, ThemeData)> _themes(WidgetTester tester) async {
  useDesignScreen(tester);
  late ThemeData light;
  late ThemeData dark;
  await tester.pumpWidget(
    DesignScale(
      builder: (_) {
        light = AppTheme.light;
        dark = AppTheme.dark;
        return const SizedBox();
      },
    ),
  );
  return (light, dark);
}

void main() {
  testWidgets('colour roles follow the Figma variables', (tester) async {
    final (light, dark) = await _themes(tester);
    expect(light.colorScheme.brightness, Brightness.light);
    expect(light.colorScheme.primary, AppPalette.brand600);
    expect(light.colorScheme.onPrimary, AppPalette.neutral0);
    expect(light.colorScheme.surface, AppPalette.neutral25);
    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(dark.colorScheme.primary, AppPalette.brand300);
    expect(dark.colorScheme.surface, AppPalette.neutral975);
    expect(light.extension<AppColors>(), AppColors.light);
    expect(dark.extension<AppColors>(), AppColors.dark);
  });

  testWidgets('text follows the Figma text styles', (tester) async {
    final (light, dark) = await _themes(tester);
    final bodySmall = light.textTheme.bodySmall!;
    expect(bodySmall.fontFamily, 'packages/core/Inter');
    expect(bodySmall.fontWeight, FontWeight.w400);
    expect(bodySmall.fontSize, 12);
    expect(bodySmall.height, 16 / 12);
    final titleLarge = light.textTheme.titleLarge!;
    expect(titleLarge.fontWeight, FontWeight.w600);
    expect(titleLarge.fontSize, 20);
    expect(titleLarge.height, 28 / 20);
    expect(titleLarge.letterSpacing, -0.2);
    expect(dark.textTheme.bodyMedium!.color, dark.colorScheme.onSurface);
  });

  test('colour roles blend between the light and dark sets', () {
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(
      mid.statusSuccess,
      Color.lerp(
        AppColors.light.statusSuccess,
        AppColors.dark.statusSuccess,
        0.5,
      ),
    );
    expect(AppColors.light.lerp(null, 0.5), AppColors.light);
  });
}
