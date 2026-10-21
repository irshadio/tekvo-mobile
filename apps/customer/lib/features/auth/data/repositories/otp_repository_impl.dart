import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the sign-in endpoints exist: every code is sent, and
/// every complete code is accepted.
class OtpRepositoryImpl implements OtpRepository {
  const OtpRepositoryImpl();

  @override
  Future<Either<Failure, Unit>> send(MobileContact contact) async =>
      right(unit);

  @override
  Future<Either<Failure, Unit>> verify({
    required MobileContact contact,
    required String code,
  }) async => right(unit);
}
