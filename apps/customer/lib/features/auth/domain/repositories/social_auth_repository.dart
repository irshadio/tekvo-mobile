import 'package:core/error/failure.dart';
import 'package:core/utils/social_account.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'social_auth_repository.g.dart';

/// Signs in with Google or Apple.
// A contract, bound per build in the overrides.
// ignore: one_member_abstracts
abstract interface class SocialAuthRepository {
  /// The account [provider] signed in, or a failure; a cancelled sign-in
  /// is `Failure.cancelled`.
  Future<Either<Failure, SocialAccount>> signIn(SocialProvider provider);
}

/// Bound in `auth_overrides.dart`.
@riverpod
SocialAuthRepository socialAuthRepository(Ref ref) => throw UnimplementedError(
  'socialAuthRepositoryProvider must be overridden; see auth_overrides.dart.',
);
