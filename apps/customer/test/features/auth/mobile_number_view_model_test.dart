import 'package:core/utils/mobile_contact.dart';
import 'package:country/country.dart';
import 'package:customer/features/auth/presentation/view_model/mobile_number_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test()
      ..listen(mobileNumberViewModelProvider(NumberStep.signIn), (_, _) {});
  });

  MobileNumberViewModel notifier() =>
      container.read(mobileNumberViewModelProvider(NumberStep.signIn).notifier);
  MobileNumberFormState state() =>
      container.read(mobileNumberViewModelProvider(NumberStep.signIn));

  test('each step keeps its own form', () {
    notifier().numberChanged('501234567');

    expect(
      container.read(mobileNumberViewModelProvider(NumberStep.afterSocial)),
      const MobileNumberFormState(),
    );
  });

  test('starts empty in the UAE', () {
    expect(state().country, Countries.are);
    expect(state().number, isEmpty);
    expect(state().isValid, isFalse);
  });

  test('is valid once the number reads as a mobile', () {
    notifier().numberChanged('50123456');
    expect(state().isValid, isFalse);

    notifier().numberChanged('501234567');
    expect(state().isValid, isTrue);
    expect(
      state().contact,
      const MobileContact(country: Countries.are, number: '501234567'),
    );
  });

  test('a new country cuts a number longer than it allows', () {
    notifier()
      ..selectCountry(Countries.gbr)
      ..numberChanged('74001234567')
      ..selectCountry(Countries.qat);

    expect(state().country, Countries.qat);
    expect(state().number, '7400123');
  });
}
