import 'package:core/error/error_reporter.dart';
import 'package:core/permissions/permission_service.dart';
import 'package:core/state/submission_state.dart';
import 'package:customer/features/permissions/presentation/view_model/permission_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  ProviderContainer containerWith(
    FakePermissionService service,
    FakeErrorReporter reporter,
  ) {
    final container = ProviderContainer(
      overrides: [
        permissionServiceProvider.overrideWithValue(service),
        errorReporterProvider.overrideWithValue(reporter),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('asks for its own permission and keeps the answer', () async {
    final service = FakePermissionService(
      outcome: PermissionOutcome.permanentlyDenied,
    );
    final container = containerWith(service, FakeErrorReporter());
    final provider = permissionViewModelProvider(AppPermission.notifications);
    container.listen(provider, (_, _) {});

    await container.read(provider.notifier).request();

    expect(service.asked, <AppPermission>[AppPermission.notifications]);
    expect(
      container.read(provider),
      const SubmissionState<PermissionOutcome>.success(
        PermissionOutcome.permanentlyDenied,
      ),
    );
  });

  test('a failing prompt is reported and surfaces as a failure', () async {
    final reporter = FakeErrorReporter();
    final container = containerWith(
      FakePermissionService(fails: true),
      reporter,
    );
    final provider = permissionViewModelProvider(AppPermission.location);
    container.listen(provider, (_, _) {});

    await container.read(provider.notifier).request();

    expect(reporter.contexts, <String>['permission location']);
    expect(
      container.read(provider),
      isA<SubmissionFailure<PermissionOutcome>>(),
    );
  });
}
