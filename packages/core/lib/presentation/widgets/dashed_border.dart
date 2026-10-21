import 'package:flutter/material.dart';

/// A dashed outline in [color] around [child], following [radius].
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    required this.color,
    required this.radius,
    required this.child,
    this.width = 1,
    this.dash = 4,
    this.gap = 3,
    super.key,
  });

  final Color color;
  final BorderRadius radius;
  final Widget child;
  final double width;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedPainter(
      color: color,
      radius: radius,
      width: width,
      dash: dash,
      gap: gap,
    ),
    child: child,
  );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({
    required this.color,
    required this.radius,
    required this.width,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final BorderRadius radius;
  final double width;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = width / 2;
    final outline = Path()
      ..addRRect(
        radius.toRRect(
          Rect.fromLTWH(inset, inset, size.width - width, size.height - width),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += dash + gap) {
        canvas.drawPath(metric.extractPath(at, at + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.width != width ||
      old.dash != dash ||
      old.gap != gap;
}
