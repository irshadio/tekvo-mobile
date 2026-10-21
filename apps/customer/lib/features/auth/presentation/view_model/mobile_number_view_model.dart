import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/mobile_number.dart';
import 'package:country/country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mobile_number_view_model.freezed.dart';
part 'mobile_number_view_model.g.dart';

/// The mobile number being entered, in digits, and its country.
@freezed
abstract class MobileNumberFormState with _$MobileNumberFormState {
  const factory MobileNumberFormState({
    @Default(MobileNumber.defaultCountry) Country country,
    @Default('') String number,
  }) = _MobileNumberFormState;

  const MobileNumberFormState._();

  bool get isValid => MobileNumber.isValid(number, country);

  MobileContact get contact => MobileContact(country: country, number: number);
}

/// The screens that ask for a mobile number, each with its own form.
enum NumberStep {
  /// Signing in with a mobile number.
  signIn,

  /// Adding a mobile number after a Google or Apple sign-in.
  afterSocial,
}

/// A mobile number form, valid once the number reads as a mobile in its
/// country.
@riverpod
class MobileNumberViewModel extends _$MobileNumberViewModel {
  @override
  MobileNumberFormState build(NumberStep step) => const MobileNumberFormState();

  /// [digits] is the field's text without its group spaces.
  void numberChanged(String digits) => state = state.copyWith(number: digits);

  /// A number longer than [country] allows is cut to fit.
  void selectCountry(Country country) {
    final limit = MobileNumber.maxLength(country);
    final number = state.number;
    state = MobileNumberFormState(
      country: country,
      number: number.length > limit ? number.substring(0, limit) : number,
    );
  }
}
