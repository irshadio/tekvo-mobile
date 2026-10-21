import 'package:core/theme/app_text_token.dart';

/// Brand lettering outside the type scale, in design pixels.
abstract final class AppBrandType {
  /// The "tekvo" wordmark: Inter ExtraBold 44 on its natural line.
  static const AppTextToken wordmark = AppTextToken(
    family: 'Inter',
    weight: 800,
    size: 44,
    lineHeight: 53,
    tracking: -1.6,
  );

  /// The wordmark beside the 32 px logo mark in a top bar.
  static const AppTextToken wordmarkCompact = AppTextToken(
    family: 'Inter',
    weight: 800,
    size: 20.8,
    lineHeight: 25,
    tracking: -0.8,
  );
}
