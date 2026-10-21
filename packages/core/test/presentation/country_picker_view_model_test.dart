import 'package:core/presentation/view_model/country_picker_view_model.dart';
import 'package:country/country.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer.test());

  CountrySearch search(String query, {String language = 'en'}) {
    final provider = countryPickerViewModelProvider(language);
    container.listen(provider, (_, _) {});
    container.read(provider.notifier).search(query);
    return container.read(provider);
  }

  test('lists the Gulf and the most dialled first, then the rest by name', () {
    final countries = container
        .read(countryPickerViewModelProvider('en'))
        .countries;

    expect(countries.take(10), CountryPickerViewModel.featured);
    expect(countries.length, Countries.values.length);
    final rest = countries
        .skip(10)
        .map((c) => countryName(c, 'en').toLowerCase())
        .toList();
    expect(rest, [...rest]..sort());
  });

  test(
    'finds names with a word starting with the query, whole names first',
    () {
      final found = search('in').countries;

      expect(found.take(2), [Countries.ind, Countries.idn]);
      expect(found, isNot(contains(Countries.arg)));
      expect(
        found.every((c) => countryName(c, 'en').contains(RegExp('[Ii]n'))),
        isTrue,
      );
    },
  );

  test('finds dial codes, with or without the plus', () {
    expect(search('+97').countries, contains(Countries.are));
    expect(search('971').countries.first, Countries.are);
  });

  test('matches the English name whatever the language', () {
    expect(search('united king', language: 'ar').countries, [Countries.gbr]);
  });

  test('ignores Arabic diacritics and hamza forms', () {
    expect(search('الامارات', language: 'ar').countries.first, Countries.are);
  });

  test('an empty query lists every country again', () {
    search('qa');
    final all = search('  ');

    expect(all.query, isEmpty);
    expect(all.countries.length, Countries.values.length);
  });
}
