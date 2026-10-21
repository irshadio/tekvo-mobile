import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resend_timer_view_model.g.dart';

/// Seconds left before a code can be resent; 0 once it can.
@riverpod
class ResendTimerViewModel extends _$ResendTimerViewModel {
  static const int wait = 30;
  static const Duration _tick = Duration(seconds: 1);

  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _start();
    return wait;
  }

  bool get canResend => state == 0;

  /// Starts the wait again; ignored while it is still running.
  void restart() {
    if (!canResend) return;
    state = wait;
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (timer) {
      state = state - 1;
      if (state == 0) timer.cancel();
    });
  }
}
