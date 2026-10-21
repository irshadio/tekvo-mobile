import 'package:core/presentation/widgets/design_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sizes the test view to [size], by default the design canvas, where scaled
/// sizes equal the design's.
void useDesignScreen(
  WidgetTester tester, [
  Size size = DesignScale.designSize,
]) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
}
