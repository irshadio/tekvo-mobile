import 'package:core/theme/app_color_schemes.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_fonts.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_type_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The light and dark themes, built from the Figma variables and text styles.
/// Read them inside `DesignScale`: `.sp` and `.r` need ScreenUtil.
abstract final class AppTheme {
  static ThemeData get light =>
      _themeFrom(appLightColorScheme, AppColors.light);

  static ThemeData get dark => _themeFrom(appDarkColorScheme, AppColors.dark);

  static TextTheme textTheme(Color color) {
    TextStyle s(TextStyle style) => style.copyWith(color: color);
    double sp(double v) => v.sp;
    return TextTheme(
      displayLarge: s(AppTypeScale.displayLarge.style(sp)),
      displayMedium: s(AppTypeScale.displayMedium.style(sp)),
      displaySmall: s(AppTypeScale.displaySmall.style(sp)),
      headlineLarge: s(AppTypeScale.headlineLarge.style(sp)),
      headlineMedium: s(AppTypeScale.headlineMedium.style(sp)),
      headlineSmall: s(AppTypeScale.headlineSmall.style(sp)),
      titleLarge: s(AppTypeScale.titleLarge.style(sp)),
      titleMedium: s(AppTypeScale.titleMedium.style(sp)),
      titleSmall: s(AppTypeScale.titleSmall.style(sp)),
      bodyLarge: s(AppTypeScale.bodyLarge.style(sp)),
      bodyMedium: s(AppTypeScale.bodyMedium.style(sp)),
      bodySmall: s(AppTypeScale.bodySmall.style(sp)),
      labelLarge: s(AppTypeScale.labelLarge.style(sp)),
      labelMedium: s(AppTypeScale.labelMedium.style(sp)),
      labelSmall: s(AppTypeScale.labelSmall.style(sp)),
    );
  }

  static ThemeData _themeFrom(ColorScheme scheme, AppColors colors) {
    final text = textTheme(scheme.onSurface);
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md.r),
    );
    final controlSize = Size.fromHeight(AppSizes.controlLg.r);
    final controlPadding = EdgeInsets.symmetric(horizontal: AppSpacing.s20.w);
    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      fontFamily: AppFonts.inter,
      package: 'core',
      scaffoldBackgroundColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: text.labelLarge,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: controlShape,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        border: inputBorder(scheme.outlineVariant, AppBorders.thin),
        enabledBorder: inputBorder(scheme.outlineVariant, AppBorders.thin),
        focusedBorder: inputBorder(scheme.primary, AppBorders.focus),
        errorBorder: inputBorder(scheme.error, AppBorders.thin),
        focusedErrorBorder: inputBorder(scheme.error, AppBorders.focus),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: AppBorders.thin,
        space: AppBorders.thin,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl.r),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
      ),
    );
  }
}
