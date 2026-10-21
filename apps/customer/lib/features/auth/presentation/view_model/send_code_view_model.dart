import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'send_code_view_model.g.dart';

/// Sending the sign-in code to the entered number.
@riverpod
class SendCodeViewModel extends _$SendCodeViewModel
    with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build() => const SubmissionState.idle();

  Future<void> send(MobileContact contact) =>
      runMutation(() => ref.read(otpRepositoryProvider).send(contact));
}
