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
}
