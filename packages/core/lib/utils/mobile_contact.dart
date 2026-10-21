import 'package:core/utils/mobile_number.dart';
import 'package:country/country.dart';
import 'package:flutter/foundation.dart';

/// The mobile number a user signs in with.
@immutable
final class MobileContact {
  const MobileContact({required this.country, required this.number});

  final Country country;

  /// The national number in digits, without the dial code.
  final String number;

  /// As shown to the user: `+971 50 123 4567`.
  String get display => '+${country.countryCode} ${MobileNumber.group(number)}';

  @override
  bool operator ==(Object other) =>
      other is MobileContact &&
      other.country == country &&
      other.number == number;

  @override
  int get hashCode => Object.hash(country, number);
}
