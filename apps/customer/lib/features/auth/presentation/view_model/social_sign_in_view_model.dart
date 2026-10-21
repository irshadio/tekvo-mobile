import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'social_sign_in_view_model.g.dart';

/// Signing in with Google or Apple.
@riverpod
class SocialSignInViewModel extends _$SocialSignInViewModel
    with MutationStateMixin<SocialAccount> {
  @override
  SubmissionState<SocialAccount> build() => const SubmissionState.idle();

  Future<void> signIn(SocialProvider provider) => runMutation(
    () => ref.read(socialAuthRepositoryProvider).signIn(provider),
  );
}
