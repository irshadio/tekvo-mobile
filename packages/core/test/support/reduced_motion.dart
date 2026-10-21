import 'package:flutter_test/flutter_test.dart';

/// Turns on the platform's reduce-motion setting, which stops looping
/// animations (such as the urgent banner's sheen) so `pumpAndSettle` can
/// settle.
void useReducedMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
