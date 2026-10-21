import 'package:core/error/error_reporter.dart';
import 'package:core/error/failure.dart';
import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/storage/onboarding_store.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_view_model.g.dart';

/// Records that onboarding was finished or skipped.
// check_structure: no-repository — writes the core OnboardingStore contract,
// bound in core/bootstrap.
@riverpod
class OnboardingViewModel extends _$OnboardingViewModel
    with MutationStateMixin<Unit> {
  @override
  SubmissionState<Unit> build() => const SubmissionState.idle();

  Future<void> complete() => runMutation(_markCompleted);

  Future<Either<Failure, Unit>> _markCompleted() async {
    try {
      await ref.read(onboardingStoreProvider).markOnboardingCompleted();
      return right(unit);
    } on Object catch (error, stackTrace) {
      ref
          .read(errorReporterProvider)
          .report(error, stackTrace, context: 'onboarding');
      return left(
        const Failure.cache(
          message: "Couldn't save your progress. Please try again.",
        ),
      );
    }
  }
}
