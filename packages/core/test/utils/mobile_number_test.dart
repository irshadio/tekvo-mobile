import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/mobile_number.dart';
import 'package:core/utils/otp_input.dart';
import 'package:country/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValid', () {
    test('a UAE mobile is 9 digits starting with 5', () {
      expect(MobileNumber.isValid('501234567', Countries.are), isTrue);
      expect(MobileNumber.isValid('41234567', Countries.are), isFalse);
      expect(MobileNumber.isValid('401234567', Countries.are), isFalse);
      expect(MobileNumber.isValid('50123456', Countries.are), isFalse);
    });

    test('other countries take any of their number lengths', () {
      expect(MobileNumber.isValid('9876543210', Countries.ind), isTrue);
      expect(MobileNumber.isValid('987654321', Countries.ind), isFalse);
      expect(MobileNumber.isValid('0876543210', Countries.ind), isFalse);
    });
  });

  test('maxLength is the longest number length', () {
    expect(MobileNumber.maxLength(Countries.are), 9);
    expect(MobileNumber.maxLength(Countries.gbr), 11);
  });

  test('group splits a number as it is read', () {
    expect(MobileNumber.group(''), '');
    expect(MobileNumber.group('5012'), '5012');
    expect(MobileNumber.group('50123'), '5 0123');
    expect(MobileNumber.group('1234567'), '123 4567');
    expect(MobileNumber.group('12345678'), '1234 5678');
    expect(MobileNumber.group('501234567'), '50 123 4567');
    expect(MobileNumber.group('9876543210'), '987 654 3210');
  });

  test('a contact shows its dial code and grouped number', () {
    const contact = MobileContact(country: Countries.are, number: '501234567');

    expect(contact.display, '+971 50 123 4567');
    expect(
      contact,
      const MobileContact(country: Countries.are, number: '501234567'),
    );
  });

  test('a code is complete at six digits', () {
    expect(OtpInput.isComplete('482916'), isTrue);
    expect(OtpInput.isComplete('48291'), isFalse);
    expect(OtpInput.isComplete('48291a'), isFalse);
  });
}
