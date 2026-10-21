import 'package:core/error/failure.dart';
import 'package:customer/features/registration/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the profile endpoint exists: every profile is saved.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl();

  @override
  Future<Either<Failure, Unit>> save({
    required String name,
    String? email,
  }) async => right(unit);
}
