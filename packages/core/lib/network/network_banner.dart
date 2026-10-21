import 'dart:async';

import 'package:core/network/connectivity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_banner.g.dart';

/// A looping connectivity script that replaces the real status, for
/// testing: whether connected, then how long it lasts. Empty uses the
/// device.
const List<(bool, Duration)> _simulation = <(bool, Duration)>[];

/// What the network banner says, if anything.
enum NetworkBanner { hidden, offline, online }

/// The network banner: offline while the device is offline, then online
/// for [onlineFor] once it reconnects. While the status is loading or
/// failed, the app is assumed online.
@Riverpod(keepAlive: true)
class NetworkBannerStatus extends _$NetworkBannerStatus {
  static const Duration onlineFor = Duration(seconds: 2);

  Timer? _hide;
  Timer? _script;

  @override
  NetworkBanner build() {
    ref.onDispose(() {
      _hide?.cancel();
      _script?.cancel();
    });
    if (_simulation.isNotEmpty) {
      _script = Timer(Duration.zero, () => _simulate(0));
      return NetworkBanner.hidden;
    }
    ref.listen(
      connectivityStatusProvider,
      (_, next) => _update(next.value),
      fireImmediately: true,
    );
    return NetworkBanner.hidden;
  }

  void _simulate(int step) {
    final (connected, lasts) = _simulation[step];
    _update(connected);
    _script = Timer(lasts, () => _simulate((step + 1) % _simulation.length));
  }

  void _update(bool? connected) {
    if (connected == null) return;
    if (!connected) {
      _hide?.cancel();
      state = NetworkBanner.offline;
      return;
    }
    if (state != NetworkBanner.offline) return;
    state = NetworkBanner.online;
    _hide = Timer(onlineFor, () => state = NetworkBanner.hidden);
  }
}
