import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The system bar styles screens set through an `AnnotatedRegion`.
abstract final class AppSystemBars {
  /// Status bar icons readable on [scheme]'s surface, over a navigation bar
  /// of the same colour.
  static SystemUiOverlayStyle surface(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          systemNavigationBarColor: scheme.surface,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        );
  }

  /// Light status bar icons, for a dark header, over a surface navigation
  /// bar.
  static SystemUiOverlayStyle lightOnSurface(ColorScheme scheme) =>
      surface(scheme).copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );

  /// Status bar icons readable on [background], over a navigation bar of the
  /// same colour: for screens with their own backdrop, such as the splash.
  static SystemUiOverlayStyle over(Color background) {
    final dark =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
    return (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          systemNavigationBarColor: background,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        );
  }
}
