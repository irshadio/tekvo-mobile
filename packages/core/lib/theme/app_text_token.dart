import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// One Figma text style, in design pixels.
@immutable
class AppTextToken {
  const AppTextToken({
    required this.family,
    required this.weight,
    required this.size,
    required this.lineHeight,
    required this.tracking,
  });

  final String family;
  final int weight;
  final double size;
  final double lineHeight;
  final double tracking;

  /// The style with its sizes passed through [scale], which maps design
  /// pixels to the screen (`.sp` inside `DesignScale`).
  TextStyle style(double Function(double) scale) => TextStyle(
    fontFamily: family,
    package: 'core',
    fontWeight: FontWeight.values.firstWhere((w) => w.value == weight),
    fontSize: scale(size),
    height: lineHeight / size,
    letterSpacing: scale(tracking),
    leadingDistribution: TextLeadingDistribution.even,
  );
}
