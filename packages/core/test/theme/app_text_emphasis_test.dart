import 'package:core/theme/app_text_emphasis.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emphasis is semi bold and keeps the rest of the style', () {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    expect(style.emphasized.fontWeight, FontWeight.w600);
    expect(style.emphasized.fontSize, 12);
    expect(style.bold.fontWeight, FontWeight.w700);
  });
}
