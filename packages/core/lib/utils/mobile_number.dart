import 'dart:math';

import 'package:country/country.dart';

/// Format rules for a national mobile number, the part after the dial code.
/// For UX only: the server decides whether a number is valid.
abstract final class MobileNumber {
  static const Country defaultCountry = Countries.are;

  /// The longest number taken for a country that lists no lengths.
  static const int unknownMaxLength = 13;

  /// The shortest number taken for a country that lists no lengths.
  static const int unknownMinLength = 4;

  static const int _lastGroup = 4;
  static const int _group = 3;

  /// Countries whose mobile numbers are narrower than their number lengths,
  /// which include landlines.
  static final Map<Country, RegExp> _mobilePatterns = <Country, RegExp>{
    Countries.are: RegExp(r'^5[0-9]{8}$'),
  };

  static final RegExp _digits = RegExp(r'^[1-9][0-9]*$');

  /// The most digits [country] allows.
  static int maxLength(Country country) => country.nationalNumberLengths.isEmpty
      ? unknownMaxLength
      : country.nationalNumberLengths.reduce(max);

  /// Whether [digits] reads as a mobile number in [country].
  static bool isValid(String digits, Country country) {
    final pattern = _mobilePatterns[country];
    if (pattern != null) return pattern.hasMatch(digits);
    if (!_digits.hasMatch(digits)) return false;
    final lengths = country.nationalNumberLengths;
    return lengths.isEmpty
        ? digits.length >= unknownMinLength && digits.length <= unknownMaxLength
        : lengths.contains(digits.length);
  }

  /// [digits] in the groups it is read in, ending in four:
  /// `501234567` -> `50 123 4567`.
  static String group(String digits) {
    if (digits.length <= _lastGroup) return digits;
    final groups = <String>[digits.substring(digits.length - _lastGroup)];
    var end = digits.length - _lastGroup;
    while (end > 0) {
      final start = max(0, end - _group);
      groups.insert(0, digits.substring(start, end));
      end = start;
    }
    // A lone leading digit joins the next group: `1234 5678`, not
    // `1 234 5678`.
    if (groups.length > 2 && groups.first.length == 1) {
      groups.replaceRange(0, 2, <String>[groups[0] + groups[1]]);
    }
    return groups.join(' ');
  }
}
