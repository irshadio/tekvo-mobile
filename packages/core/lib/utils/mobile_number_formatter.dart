import 'dart:math';

import 'package:core/utils/mobile_number.dart';
import 'package:country/country.dart';
import 'package:flutter/services.dart';

/// Keeps a mobile number's digits, at most [country]'s length, grouped as
/// they are read (`50 123 4567`) with the caret after the same digit. Run
/// after `WesternDigitsFormatter`.
class MobileNumberFormatter extends TextInputFormatter {
  const MobileNumberFormatter(this.country);

  final Country country;

  static final RegExp _nonDigits = RegExp('[^0-9]');

  static String digitsOf(String text) => text.replaceAll(_nonDigits, '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final caret = newValue.selection.isValid
        ? newValue.selection.extentOffset
        : newValue.text.length;
    var digits = digitsOf(newValue.text);
    var digitsBefore = digitsOf(newValue.text.substring(0, caret)).length;

    // Deleting a group space removes the digit before it instead, or the
    // grouping would put the space straight back.
    final removedSpace =
        newValue.text.length < oldValue.text.length &&
        digits == digitsOf(oldValue.text);
    if (removedSpace && digitsBefore > 0) {
      digits =
          digits.substring(0, digitsBefore - 1) +
          digits.substring(digitsBefore);
      digitsBefore--;
    }

    final limit = MobileNumber.maxLength(country);
    if (digits.length > limit) {
      digits = digits.substring(0, limit);
      digitsBefore = min(digitsBefore, limit);
    }

    final text = MobileNumber.group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: _offsetAfter(text, digitsBefore),
      ),
    );
  }

  /// The offset in [text] just after its [count]th digit.
  static int _offsetAfter(String text, int count) {
    if (count == 0) return 0;
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) != 0x20 && ++seen == count) return i + 1;
    }
    return text.length;
  }
}
