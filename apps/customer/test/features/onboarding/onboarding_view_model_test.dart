import 'package:core/error/error_reporter.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/storage/onboarding_store.dart';
import 'package:customer/features/onboarding/presentation/view_model/onboarding_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Store implements OnboardingStore {
  _Store({this.fails = false});

  final bool fails;
  bool completed = false;

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> markOnboardingCompleted() async {
    if (fails) throw StateError('disk full');
    completed = true;
  }
}

class _Reporter implements ErrorReporter {
  final List<Object> reported = <Object>[];

  @override
  void report(Object error, StackTrace stackTrace, {String? context}) =>
      reported.add(error);

  @override
  void reportFlutterError(FlutterErrorDetails details) =>
      reported.add(details.exception);
}

void main() {
  ProviderContainer containerWith(_Store store, _Reporter reporter) {
    final container = ProviderContainer(
      overrides: [
        onboardingStoreProvider.overrideWithValue(store),
        errorReporterProvider.overrideWithValue(reporter),
      ],
    );
    addTearDown(container.dispose);
    container.listen(onboardingViewModelProvider, (_, _) {});
    return container;
  }

  test('completing records onboarding as done', () async {
    final store = _Store();
    final container = containerWith(store, _Reporter());

    await container.read(onboardingViewModelProvider.notifier).complete();

    expect(store.completed, isTrue);
    expect(
      container.read(onboardingViewModelProvider),
      isA<SubmissionSuccess<dynamic>>(),
    );
  });

  test('a failed save is reported and surfaces as a failure', () async {
    final reporter = _Reporter();
    final container = containerWith(_Store(fails: true), reporter);

    await container.read(onboardingViewModelProvider.notifier).complete();

    expect(reporter.reported, hasLength(1));
    expect(
      container.read(onboardingViewModelProvider),
      isA<SubmissionFailure<dynamic>>(),
    );
  });
}
