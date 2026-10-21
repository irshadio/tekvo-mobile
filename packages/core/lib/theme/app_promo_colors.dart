import 'package:core/theme/app_palette.dart';
import 'package:flutter/painting.dart';

/// Colours of the promotional banners and photo tiles, which keep the brand
/// night blue and white text in both themes.
abstract final class AppPromoColors {
  static const Color night = AppPalette.brand950;
  static const Color glow = AppPalette.brand600;
  static const Color onNightMuted = AppPalette.brand200;
  static const Color onNight = AppPalette.neutral0;

  /// A countdown cell on the night background (Figma: white at 16%).
  static const Color onNightCell = Color(0x29FFFFFF);

  /// The shade that keeps text legible over a photo's lower part (Figma:
  /// #05080F from clear at 40% to 82% at the bottom).
  static const List<Color> photoShade = <Color>[
    Color(0x0005080F),
    Color(0xD105080F),
  ];
  static const List<double> photoShadeStops = <double>[0.4, 1];
}
