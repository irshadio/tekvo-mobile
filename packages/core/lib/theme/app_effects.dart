import 'package:flutter/painting.dart';

/// Drop shadows the designs use outside the elevation scale, converted from
/// Figma (blur 2 x sigma) to Flutter's blurRadius.
abstract final class AppEffects {
  /// A photo card lifted off the page (Figma: y 16, blur 32, 18%).
  static const List<BoxShadow> raisedImage = <BoxShadow>[
    BoxShadow(
      color: Color(0x2E0D1433),
      offset: Offset(0, 16),
      blurRadius: 26.85,
    ),
  ];

  /// A small chip floating over a photo (Figma: y 6, blur 16, 12%).
  static const List<BoxShadow> floatingChip = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F0D1433),
      offset: Offset(0, 6),
      blurRadius: 12.99,
    ),
  ];

  /// The pinned header's shadow over the scrolling page (Figma: y 4,
  /// blur 12, 6%).
  static const List<BoxShadow> pinnedHeader = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F080D1A),
      offset: Offset(0, 4),
      blurRadius: 9.53,
    ),
  ];
}
