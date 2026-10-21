import 'package:flutter/painting.dart';

/// The weight the design gives a run inside a text style, such as a link or
/// a number within a sentence.
extension AppTextEmphasis on TextStyle {
  /// Semi bold, the design's emphasis inside body text.
  TextStyle get emphasized => copyWith(fontWeight: FontWeight.w600);

  /// Bold, for counts in badges.
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
}
