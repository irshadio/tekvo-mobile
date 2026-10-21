import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A soft light behind the logo: a filled circle under a layer blur, as the
/// Figma glow ellipses are drawn.
class SplashGlow extends StatelessWidget {
  const SplashGlow({
    required this.color,
    required this.diameter,
    required this.blur,
    super.key,
  });

  final Color color;

  /// In design pixels.
  final double diameter;

  /// The Figma layer blur radius, in design pixels.
  final double blur;

  @override
  Widget build(BuildContext context) {
    // Figma's blur radius is twice the Gaussian sigma Flutter takes.
    final sigma = blur.r / 2;
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.decal,
        ),
        child: SizedBox.square(
          dimension: diameter.r,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
