import 'package:core/utils/western_digits_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String format(String text) => const WesternDigitsFormatter()
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
      .text;

  test('turns Arabic-Indic and Persian digits into 0-9', () {
    expect(format('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(format('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
  });

  test('leaves other text alone', () {
    expect(format('a1@b.c'), 'a1@b.c');
  });
}
