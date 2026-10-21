import 'package:country/country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'country_picker_view_model.freezed.dart';
part 'country_picker_view_model.g.dart';

/// The picker's search, the countries it shows in order, and the country
/// just picked, if any.
// The list is built here and never handed out to change; an unmodifiable
// wrapper would need the generator's `final` parameters, which this SDK
// rejects.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class CountrySearch with _$CountrySearch {
  const factory CountrySearch({
    required List<Country> countries,
    @Default('') String query,
    Country? picked,
  }) = _CountrySearch;
}

/// Countries for the picker in [languageCode]: the Gulf and the most dialled
/// first, then the rest by name. A search keeps those whose name has a word
/// starting with the query, or whose dial code does; whole-name matches lead.
@riverpod
class CountryPickerViewModel extends _$CountryPickerViewModel {
  static const List<Country> featured = <Country>[
    Countries.are,
    Countries.sau,
    Countries.qat,
    Countries.kwt,
    Countries.bhr,
    Countries.omn,
    Countries.ind,
    Countries.egy,
    Countries.gbr,
    Countries.usa,
  ];

  late final List<Country> _all = <Country>[
    ...featured,
    ...(Countries.values.where((c) => !featured.contains(c)).toList()..sort(
      (a, b) => _normalize(
        countryName(a, languageCode),
      ).compareTo(_normalize(countryName(b, languageCode))),
    )),
  ];

  @override
  CountrySearch build(String languageCode) => CountrySearch(countries: _all);

  void pick(Country country) => state = state.copyWith(picked: country);

  void search(String query) {
    final q = _normalize(query.trim().replaceAll('+', ''));
    if (q.isEmpty) {
      state = CountrySearch(countries: _all, picked: state.picked);
      return;
    }
    final leading = <Country>[];
    final rest = <Country>[];
    for (final country in _all) {
      final names = <String>{
        _normalize(countryName(country, languageCode)),
        _normalize(country.isoShortName),
      };
      if (names.any((name) => name.startsWith(q)) ||
          country.countryCode.startsWith(q)) {
        leading.add(country);
      } else if (names.any((name) => _hasWordStarting(name, q))) {
        rest.add(country);
      }
    }
    state = CountrySearch(
      countries: <Country>[...leading, ...rest],
      query: q,
      picked: state.picked,
    );
  }

  static bool _hasWordStarting(String name, String prefix) =>
      name.split(_wordBreak).any((word) => word.startsWith(prefix));

  static final RegExp _wordBreak = RegExp(r"[\s,()'-]+");
  static final RegExp _arabicMarks = RegExp('[\u064B-\u065F\u0670\u0640]');
  static final RegExp _alefForms = RegExp('[\u0622\u0623\u0625]');

  /// Lower case, Western digits, and Arabic without diacritics or hamza
  /// forms of alef, so `الامارات` finds `الإمارات`.
  static String _normalize(String text) {
    final digits = String.fromCharCodes(
      text.codeUnits.map((unit) {
        if (unit >= 0x0660 && unit <= 0x0669) return unit - 0x0660 + 0x30;
        if (unit >= 0x06F0 && unit <= 0x06F9) return unit - 0x06F0 + 0x30;
        return unit;
      }),
    );
    return digits
        .toLowerCase()
        .replaceAll(_arabicMarks, '')
        .replaceAll(_alefForms, 'ا');
  }
}

/// [country]'s short name in [languageCode], or its ISO name.
String countryName(Country country, String languageCode) =>
    country.isoShortNameByLocale[languageCode] ?? country.isoShortName;
