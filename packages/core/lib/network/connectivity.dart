import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/network/app_foreground.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

/// Network attach and detach events from the OS: `false` when no network
/// is attached, `true` when one is, which may still lack internet. Hints
/// only: iOS reports `false` before its first real reading.
abstract interface class NetworkChanges {
  Stream<bool> get onChange;
}

class NetworkChangesImpl implements NetworkChanges {
  NetworkChangesImpl([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> get onChange => _connectivity.onConnectivityChanged.map(
    (results) => results.any((result) => result != ConnectivityResult.none),
  );
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
NetworkChanges networkChanges(Ref ref) => throw UnimplementedError(
  'networkChangesProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);

/// Internet reachability (DNS probes), bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
rc.ConnectivityService connectivityService(Ref ref) => throw UnimplementedError(
  'connectivityServiceProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);

/// How often reachability is re-checked while nothing else prompts it: no
/// OS event fires when an attached network loses internet.
const Duration connectivityPollEvery = Duration(seconds: 10);

/// Offline is reported only after this many failed probes in a row,
/// [connectivityConfirmEvery] apart, with no success between them.
const int connectivityOfflineConfirmations = 3;
const Duration connectivityConfirmEvery = Duration(seconds: 2);

/// After returning to the foreground, the radio and DNS get this long to
/// come back before the first probe.
const Duration connectivityResumeGrace = Duration(seconds: 2);

/// Reachability for an offline indicator, failing safe: until a check
/// concludes nothing is reported, one successful probe reports online,
/// and offline needs [connectivityOfflineConfirmations] failures in a row.
/// OS network events only start a new check, never decide one. Off screen
/// nothing is probed and in-flight results are dropped. Per-request
/// handling still flows through `Failure.noConnection`.
@riverpod
Stream<bool> connectivityStatus(Ref ref) {
  final service = ref.watch(connectivityServiceProvider);
  final changes = ref.watch(networkChangesProvider);
  final foreground = ref.watch(appForegroundProvider);
  final controller = StreamController<bool>();
  var generation = 0;
  var checking = false;
  var active = false;
  Timer? wake;
  Timer? poll;

  bool stale(int current) => current != generation || controller.isClosed;

  Future<bool> reachable() async {
    try {
      return await service.isConnected();
    } on Object {
      return false;
    }
  }

  Future<void> check() async {
    final current = ++generation;
    checking = true;
    for (var failures = 1; ; failures++) {
      final connected = await reachable();
      if (stale(current)) return;
      if (connected || failures >= connectivityOfflineConfirmations) {
        checking = false;
        controller.add(connected);
        return;
      }
      await Future<void>.delayed(connectivityConfirmEvery);
      if (stale(current)) return;
    }
  }

  void pause() {
    active = false;
    generation++;
    checking = false;
    wake?.cancel();
    poll?.cancel();
  }

  void resume(Duration after) {
    pause();
    active = true;
    wake = Timer(after, () {
      unawaited(check());
      poll = Timer.periodic(connectivityPollEvery, (_) {
        if (!checking) unawaited(check());
      });
    });
  }

  var started = false;
  final lifecycle = foreground.changes.listen((onScreen) {
    if (onScreen) {
      resume(started ? connectivityResumeGrace : Duration.zero);
      started = true;
    } else {
      pause();
    }
  });
  final network = changes.onChange.distinct().listen((_) {
    if (active && wake?.isActive != true) unawaited(check());
  });

  ref.onDispose(() {
    pause();
    unawaited(lifecycle.cancel());
    unawaited(network.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
}
