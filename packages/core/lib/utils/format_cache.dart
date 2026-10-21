import 'package:intl/intl.dart';

/// Date and number formats built once per pattern and locale, not on every
/// build. The only place in `lib/` that constructs them.
///
/// Every caller shares the returned instance: never mutate it (fraction or
/// integer digits, grouping, significant digits, added patterns). For a
/// variant, add a pattern here instead.
abstract final class FormatCache {
  static final Map<(String, String), DateFormat> _dates =
      <(String, String), DateFormat>{};
  static final Map<(String, String), NumberFormat> _numbers =
      <(String, String), NumberFormat>{};
  static final Map<String, NumberFormat> _decimals = <String, NumberFormat>{};

  /// `DateFormat(pattern, locale)`; a skeleton such as `E` or `MMM` gives
  /// the locale's pattern for it.
  static DateFormat date(String pattern, String locale) =>
      _dates.putIfAbsent((pattern, locale), () => DateFormat(pattern, locale));

  /// `NumberFormat(pattern, locale)`.
  static NumberFormat number(String pattern, String locale) => _numbers
      .putIfAbsent((pattern, locale), () => NumberFormat(pattern, locale));

  /// `NumberFormat.decimalPattern(locale)`: the locale's own grouping.
  static NumberFormat decimal(String locale) =>
      _decimals.putIfAbsent(locale, () => NumberFormat.decimalPattern(locale));
}
