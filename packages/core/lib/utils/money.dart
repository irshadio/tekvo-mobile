import 'package:flutter/foundation.dart';

/// An amount as the server sends it, in minor units (fils for AED), so it
/// is never rounded on the client.
@immutable
final class Money {
  const Money(this.minor, {this.currency = defaultCurrency});

  /// Whole units: `Money.units(1099)` is AED 1,099.00.
  const Money.units(int units, {this.currency = defaultCurrency})
    : minor = units * minorPerUnit;

  static const String defaultCurrency = 'AED';
  static const int minorPerUnit = 100;

  final int minor;

  /// The ISO 4217 code.
  final String currency;

  bool get isWhole => minor % minorPerUnit == 0;

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);
}
