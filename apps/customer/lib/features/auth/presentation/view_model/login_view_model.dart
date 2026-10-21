import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/mobile_number.dart';
import 'package:country/country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_view_model.freezed.dart';
part 'login_view_model.g.dart';

/// The mobile number being entered, in digits, and its country.
@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default(MobileNumber.defaultCountry) Country country,
    @Default('') String number,
  }) = _LoginFormState;

  const LoginFormState._();

  bool get isValid => MobileNumber.isValid(number, country);

  MobileContact get contact => MobileContact(country: country, number: number);
}

/// The sign-in form: a mobile number, valid once it reads as a mobile in
/// its country.
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginFormState build() => const LoginFormState();

  /// [digits] is the field's text without its group spaces.
  void numberChanged(String digits) => state = state.copyWith(number: digits);

  /// A number longer than [country] allows is cut to fit.
  void selectCountry(Country country) {
    final limit = MobileNumber.maxLength(country);
    final number = state.number;
    state = LoginFormState(
      country: country,
      number: number.length > limit ? number.substring(0, limit) : number,
    );
  }
}
