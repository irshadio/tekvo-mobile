import 'package:core/assets/assets.gen.dart';
import 'package:core/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Colours of the brand screens (splash), which in dark mode sit on the deep
/// brand blue rather than the dark surface. Read with `context.brandColors`.
@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  const AppBrandColors({
    required this.background,
    required this.glowPrimary,
    required this.glowAccent,
    required this.wordmark,
    required this.tagline,
    required this.footer,
    required this.loaderTrack,
    required this.loaderBar,
    required this.logoMark,
  });

  static const AppBrandColors light = AppBrandColors(
    background: AppPalette.neutral25,
    glowPrimary: AppPalette.brand200,
    glowAccent: AppPalette.volt300,
    wordmark: AppPalette.neutral950,
    tagline: AppPalette.neutral700,
    footer: AppPalette.neutral700,
    loaderTrack: AppPalette.neutral150,
    loaderBar: AppPalette.brand600,
    logoMark: Assets.brandLogoMark,
  );

  static const AppBrandColors dark = AppBrandColors(
    background: AppPalette.brand950,
    glowPrimary: AppPalette.brand600,
    glowAccent: AppPalette.volt300,
    wordmark: AppPalette.neutral0,
    tagline: AppPalette.brand200,
    footer: AppPalette.brand300,
    loaderTrack: Color(0x33FFFFFF),
    loaderBar: AppPalette.volt300,
    logoMark: Assets.brandLogoMarkDark,
  );

  final Color background;
  final Color glowPrimary;
  final Color glowAccent;
  final Color wordmark;
  final Color tagline;
  final Color footer;
  final Color loaderTrack;
  final Color loaderBar;

  /// The logo mark asset drawn for this brightness.
  final String logoMark;

  @override
  AppBrandColors copyWith({
    Color? background,
    Color? glowPrimary,
    Color? glowAccent,
    Color? wordmark,
    Color? tagline,
    Color? footer,
    Color? loaderTrack,
    Color? loaderBar,
    String? logoMark,
  }) => AppBrandColors(
    background: background ?? this.background,
    glowPrimary: glowPrimary ?? this.glowPrimary,
    glowAccent: glowAccent ?? this.glowAccent,
    wordmark: wordmark ?? this.wordmark,
    tagline: tagline ?? this.tagline,
    footer: footer ?? this.footer,
    loaderTrack: loaderTrack ?? this.loaderTrack,
    loaderBar: loaderBar ?? this.loaderBar,
    logoMark: logoMark ?? this.logoMark,
  );

  @override
  AppBrandColors lerp(AppBrandColors? other, double t) {
    if (other == null) return this;
    return AppBrandColors(
      background: Color.lerp(background, other.background, t)!,
      glowPrimary: Color.lerp(glowPrimary, other.glowPrimary, t)!,
      glowAccent: Color.lerp(glowAccent, other.glowAccent, t)!,
      wordmark: Color.lerp(wordmark, other.wordmark, t)!,
      tagline: Color.lerp(tagline, other.tagline, t)!,
      footer: Color.lerp(footer, other.footer, t)!,
      loaderTrack: Color.lerp(loaderTrack, other.loaderTrack, t)!,
      loaderBar: Color.lerp(loaderBar, other.loaderBar, t)!,
      logoMark: t < 0.5 ? logoMark : other.logoMark,
    );
  }
}
