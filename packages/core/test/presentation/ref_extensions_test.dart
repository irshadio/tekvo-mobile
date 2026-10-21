import 'package:core/error/failure.dart';
import 'package:core/l10n/app_locale.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

class _Probe extends Notifier<ViewState<int>> {
  @override
  ViewState<int> build() => const ViewState<int>.idle();

  // ignore: use_setters_to_change_properties test-only state driver
  void emit(ViewState<int> next) => state = next;
}

final _probeProvider = NotifierProvider<_Probe, ViewState<int>>(_Probe.new);

class _Submission extends Notifier<SubmissionState<int>> {
  @override
  SubmissionState<int> build() => const SubmissionState<int>.idle();

  // ignore: use_setters_to_change_properties test-only state driver
  void emit(SubmissionState<int> next) => state = next;
}

final _submissionProvider = NotifierProvider<_Submission, SubmissionState<int>>(
  _Submission.new,
);

class _Host extends ConsumerWidget {
  const _Host({this.includeFirstLoad = false, this.onSuccess});

  final bool includeFirstLoad;
  final void Function(int value)? onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listenRefreshFailures(
        _probeProvider,
        context,
        includeFirstLoad: includeFirstLoad,
      )
      ..listenSubmission(
        _submissionProvider,
        context,
        onSuccess: onSuccess ?? (_) {},
      );
    return const SizedBox.shrink();
  }
}

void main() {
  final l10n = lookupCoreLocalizations(AppLocale.current);

  Future<ProviderContainer> pumpHost(
    WidgetTester tester, {
    _Host host = const _Host(),
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(home: Scaffold(body: host)),
      ),
    );
    return container;
  }

  testWidgets('a failed refresh (data retained) surfaces a snackbar', (
    tester,
  ) async {
    final container = await pumpHost(tester);
    expect(find.byType(SnackBar), findsNothing);

    container
        .read(_probeProvider.notifier)
        .emit(
          const ViewState<int>.error(
            Failure.unexpected(message: 'refresh boom'),
            previous: 7,
          ),
        );
    await tester.pump(); // run the listener
    await tester.pump(); // animate the snackbar in

    expect(find.text(l10n.errorUnexpected), findsOneWidget);
  });

  testWidgets('a first-load failure (no data) does not snackbar', (
    tester,
  ) async {
    final container = await pumpHost(tester);

    container
        .read(_probeProvider.notifier)
        .emit(
          const ViewState<int>.error(Failure.unexpected(message: 'first boom')),
        );
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.errorUnexpected), findsNothing);
  });

  testWidgets('includeFirstLoad surfaces a first-load failure', (
    tester,
  ) async {
    final container = await pumpHost(
      tester,
      host: const _Host(includeFirstLoad: true),
    );

    container
        .read(_probeProvider.notifier)
        .emit(
          const ViewState<int>.error(Failure.unexpected(message: 'first boom')),
        );
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.errorUnexpected), findsOneWidget);
  });

  testWidgets('a refresh that goes offline uses the no-connection wording', (
    tester,
  ) async {
    final container = await pumpHost(tester);

    container
        .read(_probeProvider.notifier)
        .emit(const ViewState<int>.noInternet(previous: 7));
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.errorNoConnection), findsOneWidget);
  });

  testWidgets('listenSubmission runs onSuccess once, and snackbars failures', (
    tester,
  ) async {
    final successes = <int>[];
    final container = await pumpHost(
      tester,
      host: _Host(onSuccess: successes.add),
    );
    final submission = container.read(_submissionProvider.notifier)
      ..emit(const SubmissionState<int>.inProgress());
    await tester.pump();
    submission.emit(const SubmissionState<int>.success(5));
    await tester.pump();

    expect(successes, <int>[5]);

    submission.emit(
      const SubmissionState<int>.failure(
        Failure.validation(message: 'Name is required', isServerMessage: true),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
  });
}
