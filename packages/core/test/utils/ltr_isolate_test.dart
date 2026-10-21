import 'package:core/utils/ltr_isolate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wraps text in a left-to-right isolate', () {
    expect(ltrIsolate('+971 50'), '\u2066+971 50\u2069');
  });
}
