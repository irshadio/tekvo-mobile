import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resend_code_view_model.g.dart';

/// Texting a new code from the code entry screen.
@riverpod
class ResendCodeViewModel extends _$ResendCodeViewModel
    with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build() => const SubmissionState.idle();

  Future<void> resend(MobileContact contact) =>
      runMutation(() => ref.read(otpRepositoryProvider).send(contact));
}
