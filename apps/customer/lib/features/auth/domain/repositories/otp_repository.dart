import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_repository.g.dart';

/// Texts a one-time code to a mobile number.
// A contract, bound per build in the overrides.
// ignore: one_member_abstracts
abstract interface class OtpRepository {
  /// Fails when the code cannot be sent; the server owns rate limits.
  Future<Either<Failure, Unit>> send(MobileContact contact);
}

/// Bound in `auth_overrides.dart`.
@riverpod
OtpRepository otpRepository(Ref ref) => throw UnimplementedError(
  'otpRepositoryProvider must be overridden; see auth_overrides.dart.',
);
