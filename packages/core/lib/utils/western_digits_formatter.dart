import 'package:flutter/services.dart';

/// Turns Arabic-Indic and Persian digits into 0-9.
class WesternDigitsFormatter extends TextInputFormatter {
  const WesternDigitsFormatter();

  static const int _arabicZero = 0x0660;
  static const int _persianZero = 0x06F0;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = String.fromCharCodes(
      newValue.text.codeUnits.map((unit) {
        if (unit >= _arabicZero && unit <= _arabicZero + 9) {
          return 0x30 + unit - _arabicZero;
        }
        if (unit >= _persianZero && unit <= _persianZero + 9) {
          return 0x30 + unit - _persianZero;
        }
        return unit;
      }),
    );
    return text == newValue.text ? newValue : newValue.copyWith(text: text);
  }
}
