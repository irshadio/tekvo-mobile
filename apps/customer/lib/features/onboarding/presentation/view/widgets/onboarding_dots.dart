import 'dart:ui' show lerpDouble;

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The page dots. The dot of the page on screen stretches into a bar; while
/// a page is swiped, the bar moves with the finger.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    required this.count,
    required this.position,
    super.key,
  });

  final int count;

  /// The page shown, fractional while swiping.
  final double position;

  static const double _dot = 8;
  static const double _bar = 24;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = position.round();
    return Semantics(
      label: context.l10n.onboardingPageLabel(current + 1, count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap.w,
          children: <Widget>[
            for (var i = 0; i < count; i++)
              _dotFor(colors, (1 - (position - i).abs()).clamp(0, 1)),
          ],
        ),
      ),
    );
  }

  /// A dot [t] of the way to the active bar.
  Widget _dotFor(ColorScheme colors, double t) => Container(
    width: lerpDouble(_dot, _bar, t)!.w,
    height: _dot.r,
    decoration: BoxDecoration(
      color: Color.lerp(colors.outlineVariant, colors.primary, t),
      borderRadius: BorderRadius.circular(_dot.r / 2),
    ),
  );
}
