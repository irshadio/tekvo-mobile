import 'dart:async';

import 'package:core/error/failure.dart';
import 'package:core/state/mutation_state_mixin.dart';
import 'package:core/state/submission_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mutation_state_mixin_test.g.dart';

// Guard: stops compiling if a Riverpod upgrade breaks the mixin's `on` clause.
@riverpod
class ProbeMutation extends _$ProbeMutation with MutationStateMixin<int> {
  @override
  SubmissionState<int> build() => const SubmissionState.idle();

  Future<void> run(Either<Failure, int> result) =>
      runMutation(() async => result);

  Future<void> runThrowing() =>
      runMutation(() async => throw StateError('boom'));

  Future<void> runFuture(Future<Either<Failure, int>> future) =>
      runMutation(() => future);
}

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('build() starts idle', () {
    expect(
      container.read(probeMutationProvider),
      const SubmissionState<int>.idle(),
    );
  });

  test('success maps to SubmissionState.success', () async {
    await container
        .read(probeMutationProvider.notifier)
        .run(right<Failure, int>(101));
    expect(
      container.read(probeMutationProvider),
      const SubmissionState<int>.success(101),
    );
  });

  test('failure maps to SubmissionState.failure', () async {
    const failure = Failure.validation(message: 'Title is required');
    await container
        .read(probeMutationProvider.notifier)
        .run(left<Failure, int>(failure));
    expect(
      container.read(probeMutationProvider),
      const SubmissionState<int>.failure(failure),
    );
  });

  test('a THROWN error maps to SubmissionState.failure (no hang)', () async {
    await container.read(probeMutationProvider.notifier).runThrowing();
    final state = container.read(probeMutationProvider);
    expect(state, isA<SubmissionFailure<int>>());
    expect((state as SubmissionFailure<int>).failure, isA<UnexpectedFailure>());
  });

  test('a second submit while one is in flight is dropped', () async {
    final notifier = container.read(probeMutationProvider.notifier);
    final pending = Completer<Either<Failure, int>>();

    final first = notifier.runFuture(pending.future);
    await notifier.run(right<Failure, int>(2));

    expect(
      container.read(probeMutationProvider),
      const SubmissionState<int>.inProgress(),
    );

    pending.complete(right<Failure, int>(1));
    await first;
    expect(
      container.read(probeMutationProvider),
      const SubmissionState<int>.success(1),
    );
  });

  test('a thrown error keeps its stack trace in detail', () async {
    await container.read(probeMutationProvider.notifier).runThrowing();
    final state = container.read(probeMutationProvider);

    final detail = (state as SubmissionFailure<int>).failure.detail;
    expect(detail, contains('boom'));
    expect(detail, contains('mutation_state_mixin_test.dart'));
  });
}
