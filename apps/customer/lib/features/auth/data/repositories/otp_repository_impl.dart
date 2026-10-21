import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the sign-in endpoints exist: every code is sent.
class OtpRepositoryImpl implements OtpRepository {
  const OtpRepositoryImpl();

  @override
  Future<Either<Failure, Unit>> send(MobileContact contact) async =>
      right(unit);
}
