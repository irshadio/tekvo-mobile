import 'package:core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

/// Saves the new account's profile.
// A contract, bound per build in the overrides.
// ignore: one_member_abstracts
abstract interface class ProfileRepository {
  /// The server validates the details again; [email] is null when left out.
  Future<Either<Failure, Unit>> save({required String name, String? email});
}

/// Bound in `registration_overrides.dart`.
@riverpod
ProfileRepository profileRepository(Ref ref) => throw UnimplementedError(
  'profileRepositoryProvider must be overridden; see '
  'registration_overrides.dart.',
);
