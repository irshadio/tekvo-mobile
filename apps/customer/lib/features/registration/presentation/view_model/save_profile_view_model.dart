import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:customer/features/registration/domain/repositories/profile_repository.dart';
import 'package:customer/features/registration/presentation/view_model/profile_view_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_profile_view_model.g.dart';

/// Saving the entered profile.
@riverpod
class SaveProfileViewModel extends _$SaveProfileViewModel
    with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build() => const SubmissionState.idle();

  Future<void> save(ProfileFormState form) {
    final email = form.email.trim();
    return runMutation(
      () => ref
          .read(profileRepositoryProvider)
          .save(name: form.name.trim(), email: email.isEmpty ? null : email),
    );
  }
}
