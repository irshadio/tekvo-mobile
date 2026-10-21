import 'dart:async';

import 'package:core/error/failure.dart';
import 'package:core/state/remote_state_mixin.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_state_mixin_test.g.dart';

// Guard: stops compiling if a Riverpod upgrade breaks the mixin's `on` clause.
@riverpod
class ProbeViewModel extends _$ProbeViewModel with RemoteStateMixin<int> {
  @override
  ViewState<int> build() => const ViewState.idle();

  Future<void> run(Either<Failure, int> result) =>
      runRequest(() async => result);

  Future<void> runThrowing() =>
      runRequest(() async => throw StateError('boom'));

  Future<void> runFuture(Future<Either<Failure, int>> future) =>
      runRequest(() => future);
}

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('build() starts idle', () {
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.idle(),
    );
  });

  test('success maps to ViewState.data', () async {
    await container
        .read(probeViewModelProvider.notifier)
        .run(right<Failure, int>(42));
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.data(42),
    );
  });

  test('NoConnectionFailure maps to ViewState.noInternet', () async {
    await container
        .read(probeViewModelProvider.notifier)
        .run(left<Failure, int>(const Failure.noConnection()));
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.noInternet(),
    );
  });

  test('other Failure maps to ViewState.error', () async {
    const failure = Failure.server(statusCode: 500, message: 'boom');
    await container
        .read(probeViewModelProvider.notifier)
        .run(left<Failure, int>(failure));
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.error(failure),
    );
  });

  test('a failed refresh retains the previous data', () async {
    final notifier = container.read(probeViewModelProvider.notifier);
    await notifier.run(right<Failure, int>(42)); // -> data(42)
    await notifier.run(left<Failure, int>(const Failure.noConnection()));
    final state = container.read(probeViewModelProvider);
    expect(state, isA<ViewNoInternet<int>>());
    expect(state.dataOrNull, 42);
  });

  test('a THROWN error maps to ViewState.error (no hang)', () async {
    await container.read(probeViewModelProvider.notifier).runThrowing();
    final state = container.read(probeViewModelProvider);
    expect(state, isA<ViewError<int>>());
    expect((state as ViewError<int>).failure, isA<UnexpectedFailure>());
  });

  test('a thrown error during refresh retains the previous data', () async {
    final notifier = container.read(probeViewModelProvider.notifier);
    await notifier.run(right<Failure, int>(42)); // -> data(42)
    await notifier.runThrowing();
    final state = container.read(probeViewModelProvider);
    expect(state, isA<ViewError<int>>());
    expect(state.dataOrNull, 42);
  });

  test('a superseded (older) request never clobbers a newer result', () async {
    final notifier = container.read(probeViewModelProvider.notifier);
    final older = Completer<Either<Failure, int>>();
    final newer = Completer<Either<Failure, int>>();

    final olderRun = notifier.runFuture(older.future); // request 1, in flight
    final newerRun = notifier.runFuture(newer.future); // request 2 supersedes 1

    newer.complete(right<Failure, int>(2)); // the newer request resolves first
    await newerRun;
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.data(2),
    );

    older.complete(right<Failure, int>(1)); // stale result lands later...
    await olderRun;
    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.data(2),
    );
  });

  test('reset drops the data and ignores a request in flight', () async {
    final notifier = container.read(probeViewModelProvider.notifier);
    await notifier.run(right<Failure, int>(1));
    final pending = Completer<Either<Failure, int>>();
    final run = notifier.runFuture(pending.future);

    notifier.reset();
    pending.complete(right<Failure, int>(2));
    await run;

    expect(
      container.read(probeViewModelProvider),
      const ViewState<int>.idle(),
    );
  });
}
