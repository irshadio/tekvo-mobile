import 'package:core/error/failure.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Stand-in until the Google and Apple sign-in SDKs are set up: every
/// sign-in returns the design's sample account.
class SocialAuthRepositoryImpl implements SocialAuthRepository {
  const SocialAuthRepositoryImpl();

  @override
  Future<Either<Failure, SocialAccount>> signIn(
    SocialProvider provider,
  ) async => right(
    SocialAccount(
      provider: provider,
      name: 'Sam Rivera',
      email: switch (provider) {
        SocialProvider.google => 'sam.rivera@gmail.com',
        SocialProvider.apple => 'sam.rivera@icloud.com',
      },
    ),
  );
}
