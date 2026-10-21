import 'package:core/utils/format_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const _datePatterns = <String>[
  'd MMM, EEE',
  'd MMM, h:mm a',
  'h a',
  'h:mm a',
  'd MMM y',
  'dd MMM y',
  'd MMM',
  'EEEE d MMMM',
  'MMM',
  'MMM d',
];

const _numberPatterns = <String>[
  '#,##0',
  '#,##0.##',
  '#,##0.00',
  '0',
  '0.0',
  '0.#',
];

void main() {
  setUpAll(initializeDateFormatting);

  test('builds one format per pattern and locale', () {
    final date = FormatCache.date('d MMM', 'en');
    final number = FormatCache.number('#,##0', 'en');

    expect(FormatCache.date('d MMM', 'en'), same(date));
    expect(FormatCache.date('d MMM', 'ar'), isNot(same(date)));
    expect(FormatCache.date('d MMM y', 'en'), isNot(same(date)));
    expect(FormatCache.number('#,##0', 'en'), same(number));
    expect(FormatCache.number('#,##0', 'ar'), isNot(same(number)));
    expect(FormatCache.number('0', 'en'), isNot(same(number)));
    final decimal = FormatCache.decimal('en');
    expect(FormatCache.decimal('en'), same(decimal));
    expect(FormatCache.decimal('ar'), isNot(same(decimal)));
  });

  for (final locale in <String>['en', 'ar']) {
    test('formats as a new format would, in $locale', () {
      final moments = <DateTime>[
        DateTime(2024, 7, 25, 14),
        DateTime(2025, 1, 3, 8, 2),
      ];
      for (final pattern in _datePatterns) {
        for (final moment in moments) {
          expect(
            FormatCache.date(pattern, locale).format(moment),
            DateFormat(pattern, locale).format(moment),
            reason: pattern,
          );
        }
      }
      final day = DateTime(2024, 7, 29);
      expect(
        FormatCache.date('E', locale).format(day),
        DateFormat.E(locale).format(day),
      );
      expect(
        FormatCache.date('d', locale).format(day),
        DateFormat.d(locale).format(day),
      );
      expect(
        FormatCache.date('MMM', locale).format(day),
        DateFormat.MMM(locale).format(day),
      );
      for (final pattern in _numberPatterns) {
        for (final value in <num>[0, 4.5, 2490, 96000.125, 12346]) {
          expect(
            FormatCache.number(pattern, locale).format(value),
            NumberFormat(pattern, locale).format(value),
            reason: '$pattern $value',
          );
        }
      }
      for (final value in <num>[0, 4.5, 2490, 96000.125, 1234567]) {
        expect(
          FormatCache.decimal(locale).format(value),
          NumberFormat.decimalPattern(locale).format(value),
          reason: '$value',
        );
      }
    });
  }
}
