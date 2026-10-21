import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_repository.g.dart';

/// Texts a one-time code to a mobile number and checks it.
abstract interface class OtpRepository {
  /// Fails when the code cannot be sent; the server owns rate limits.
  Future<Either<Failure, Unit>> send(MobileContact contact);

  /// Fails when the server rejects [code] for [contact]; the server owns
  /// attempt limits and lockout.
  Future<Either<Failure, Unit>> verify({
    required MobileContact contact,
    required String code,
  });
}

/// Bound in `auth_overrides.dart`.
@riverpod
OtpRepository otpRepository(Ref ref) => throw UnimplementedError(
  'otpRepositoryProvider must be overridden; see auth_overrides.dart.',
);
