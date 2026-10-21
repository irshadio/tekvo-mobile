import 'package:core/error/error_reporter.dart';
import 'package:core/error/failure.dart';
import 'package:core/permissions/permission_service.dart';
import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_view_model.g.dart';

/// Shows the system prompt for one permission and records the answer.
// check_structure: no-repository — asks the core PermissionService contract,
// bound in core/bootstrap.
@riverpod
class PermissionViewModel extends _$PermissionViewModel
    with MutationStateMixin<PermissionOutcome> {
  @override
  SubmissionState<PermissionOutcome> build(AppPermission permission) =>
      const SubmissionState.idle();

  Future<void> request() => runMutation(_ask);

  Future<Either<Failure, PermissionOutcome>> _ask() async {
    try {
      return right(
        await ref.read(permissionServiceProvider).request(permission),
      );
    } on Object catch (error, stackTrace) {
      ref
          .read(errorReporterProvider)
          .report(error, stackTrace, context: 'permission ${permission.name}');
      return left(const Failure.unexpected());
    }
  }
}
