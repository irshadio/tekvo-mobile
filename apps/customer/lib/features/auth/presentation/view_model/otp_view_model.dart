import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_view_model.g.dart';

/// Verifying the entered code; any edit returns it to idle.
@riverpod
class OtpViewModel extends _$OtpViewModel with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build() => const SubmissionState.idle();

  Future<void> verify({required MobileContact contact, required String code}) =>
      runMutation(
        () => ref
            .read(otpRepositoryProvider)
            .verify(contact: contact, code: code),
      );

  void reset() {
    if (state is! SubmissionIdle<Unit>) state = const SubmissionState.idle();
  }
}
