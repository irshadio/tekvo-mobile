import 'package:core/utils/mobile_number_formatter.dart';
import 'package:country/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = MobileNumberFormatter(Countries.are);

  TextEditingValue edit(String before, String after, {int? caret}) =>
      formatter.formatEditUpdate(
        TextEditingValue(
          text: before,
          selection: TextSelection.collapsed(offset: before.length),
        ),
        TextEditingValue(
          text: after,
          selection: TextSelection.collapsed(offset: caret ?? after.length),
        ),
      );

  test('groups digits as they are typed', () {
    final value = edit('50 123 456', '50 123 4567');

    expect(value.text, '50 123 4567');
    expect(value.selection.extentOffset, 11);
  });

  test('drops anything but digits', () {
    expect(edit('', '+50-123 abc').text, '5 0123');
  });

  test("stops at the country's longest number", () {
    expect(edit('', '5012345678999').text, '50 123 4567');
  });

  test('deleting a group space deletes the digit before it', () {
    // Caret after "50 " with the space removed: "50123 4567".
    final value = edit('50 123 4567', '50123 4567', caret: 2);

    expect(value.text, '5123 4567');
    expect(value.selection.extentOffset, 1);
  });

  test('keeps the caret after the same digit mid-number', () {
    // Insert "9" after "50 1".
    final value = edit('50 123 456', '50 1923 456', caret: 5);

    expect(value.text, '50 192 3456');
    expect(value.selection.extentOffset, 5);
  });
}
