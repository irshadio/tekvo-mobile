import 'dart:async';

import 'package:core/network/app_foreground.dart';
import 'package:core/network/connectivity.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChanges implements NetworkChanges {
  final StreamController<bool> controller = StreamController<bool>();

  @override
  Stream<bool> get onChange => controller.stream;
}

class _FakeForeground implements AppForeground {
  final StreamController<bool> controller = StreamController<bool>();

  @override
  Stream<bool> get changes => controller.stream;
}

/// Answers each probe with [reachable] (read when the probe starts) after
/// [latency]; throws instead while [throws] is set.
class _FakeService implements rc.ConnectivityService {
  bool reachable = true;
  bool throws = false;
  Duration latency = Duration.zero;
  int probes = 0;

  @override
  Future<bool> isConnected() async {
    probes++;
    final answer = reachable;
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (throws) throw StateError('probe failed');
    return answer;
  }
}

/// From the first failed probe to offline being reported.
final Duration _toOffline =
    connectivityConfirmEvery * (connectivityOfflineConfirmations - 1);

void main() {
  late _FakeChanges changes;
  late _FakeForeground foreground;
  late _FakeService service;

  setUp(() {
    changes = _FakeChanges();
    foreground = _FakeForeground();
    service = _FakeService();
  });

  /// Runs [body] with the reported statuses collected in order (a repeat of
  /// the current one is not reported again). The
  /// app starts on screen unless [onScreen] is false.
  void run(
    void Function(FakeAsync async, List<bool> statuses) body, {
    bool onScreen = true,
  }) {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [
          networkChangesProvider.overrideWithValue(changes),
          appForegroundProvider.overrideWithValue(foreground),
          connectivityServiceProvider.overrideWithValue(service),
        ],
      );
      final statuses = <bool>[];
      final subscription = container.listen(
        connectivityStatusProvider,
        (_, next) => statuses.add(next.requireValue),
      );
      foreground.controller.add(onScreen);
      async.elapse(Duration.zero);
      body(async, statuses);
      subscription.close();
      container.dispose();
      async.flushMicrotasks();
    });
  }

  void detach(FakeAsync async) {
    changes.controller.add(false);
    async.flushMicrotasks();
  }

  void attach(FakeAsync async) {
    changes.controller.add(true);
    async.flushMicrotasks();
  }

  void setOnScreen(FakeAsync async, {required bool onScreen}) {
    foreground.controller.add(onScreen);
    async.flushMicrotasks();
  }

  test('probes once on start and reports online', () {
    run((async, statuses) {
      expect(statuses, <bool>[true]);
      expect(service.probes, 1);
    });
  });

  test('one failed probe on start reports nothing', () {
    service.reachable = false;
    run((async, statuses) {
      expect(statuses, isEmpty);
      service.reachable = true;
      async.elapse(connectivityConfirmEvery);
      expect(statuses, <bool>[true]);
    });
  });

  test('offline needs every confirmation to fail', () {
    service.reachable = false;
    run((async, statuses) {
      async.elapse(_toOffline - const Duration(milliseconds: 1));
      expect(statuses, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(statuses, <bool>[false]);
      expect(service.probes, connectivityOfflineConfirmations);
    });
  });

  test('a throwing probe counts as a failure, never an error', () {
    service.throws = true;
    run((async, statuses) {
      async.elapse(_toOffline);
      expect(statuses, <bool>[false]);
    });
  });

  test("the OS's first false is checked, not trusted", () {
    run((async, statuses) {
      detach(async);
      async.elapse(_toOffline);
      expect(statuses, <bool>[true]);
      expect(service.probes, 2);
    });
  });

  test('a detached network is offline once confirmed', () {
    run((async, statuses) {
      service.reachable = false;
      detach(async);
      expect(statuses, <bool>[true]);
      async.elapse(_toOffline);
      expect(statuses, <bool>[true, false]);
    });
  });

  test('re-attaching within the confirmation window stays online', () {
    run((async, statuses) {
      service.reachable = false;
      detach(async);
      async.elapse(connectivityConfirmEvery);
      service.reachable = true;
      attach(async);
      async.elapse(_toOffline);
      expect(statuses, <bool>[true]);
    });
  });

  test('an attached network is online once a probe confirms it', () {
    run((async, statuses) {
      service.reachable = false;
      detach(async);
      async.elapse(_toOffline);
      service.reachable = true;
      attach(async);
      expect(statuses, <bool>[true, false, true]);
    });
  });

  test('a single failed poll reports nothing', () {
    run((async, statuses) {
      service.reachable = false;
      async.elapse(connectivityPollEvery);
      expect(statuses, <bool>[true]);
      service.reachable = true;
      async.elapse(connectivityConfirmEvery);
      expect(statuses, <bool>[true]);
      expect(service.probes, 3);
    });
  });

  test('polls while attached, catching a lost internet once confirmed', () {
    run((async, statuses) {
      service.reachable = false;
      async.elapse(connectivityPollEvery + _toOffline);
      expect(statuses, <bool>[true, false]);
    });
  });

  test('a poll does not restart a running check', () {
    run((async, statuses) {
      async.elapse(connectivityPollEvery - connectivityConfirmEvery);
      service.reachable = false;
      detach(async);
      async.elapse(_toOffline);
      expect(statuses, <bool>[true, false]);
      expect(service.probes, 1 + connectivityOfflineConfirmations);
    });
  });

  test('a probe overtaken by a newer check is dropped', () {
    run((async, statuses) {
      service
        ..latency = const Duration(milliseconds: 500)
        ..reachable = false;
      attach(async);
      service.reachable = true;
      detach(async);
      async.elapse(const Duration(seconds: 1));
      expect(statuses, <bool>[true]);
    });
  });

  test('nothing is probed off screen', () {
    run((async, statuses) {
      setOnScreen(async, onScreen: false);
      final before = service.probes;
      service.reachable = false;
      detach(async);
      async.elapse(connectivityPollEvery * 6);
      expect(service.probes, before);
      expect(statuses, <bool>[true]);
    });
  });

  test('a probe in flight when the app leaves the screen is dropped', () {
    run((async, statuses) {
      service
        ..latency = const Duration(seconds: 3)
        ..reachable = false;
      async.elapse(connectivityPollEvery);
      setOnScreen(async, onScreen: false);
      async.elapse(const Duration(minutes: 5));
      service.reachable = true;
      setOnScreen(async, onScreen: true);
      async.elapse(connectivityResumeGrace + service.latency);
      expect(statuses, <bool>[true]);
    });
  });

  test('waits out the grace period on resume, then checks afresh', () {
    run((async, statuses) {
      setOnScreen(async, onScreen: false);
      service.reachable = false;
      setOnScreen(async, onScreen: true);
      detach(async);
      final before = service.probes;
      async.elapse(connectivityResumeGrace - const Duration(milliseconds: 1));
      expect(service.probes, before);
      service.reachable = true;
      async.elapse(const Duration(milliseconds: 1));
      expect(statuses, <bool>[true]);
      expect(service.probes, before + 1);
    });
  });

  test('a start off screen waits for the app to come on screen', () {
    run(onScreen: false, (async, statuses) {
      async.elapse(connectivityPollEvery);
      expect(service.probes, 0);
      setOnScreen(async, onScreen: true);
      async.elapse(connectivityResumeGrace);
      expect(statuses, <bool>[true]);
    });
  });
}
