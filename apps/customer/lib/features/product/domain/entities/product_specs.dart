import 'package:flutter/foundation.dart';

enum HighlightKind { display, camera, battery, connectivity }

/// A headline fact, such as the screen size.
@immutable
final class Highlight {
  const Highlight({
    required this.kind,
    required this.label,
    required this.value,
  });

  final HighlightKind kind;

  /// Such as `Display`.
  final String label;

  /// Such as `6.7" 120 Hz OLED`.
  final String value;
}

/// A line of the specification.
@immutable
final class Spec {
  const Spec({required this.label, required this.value});

  final String label;
  final String value;
}
