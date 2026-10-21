import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flash_sale_timer_view_model.g.dart';

/// Time left in the flash sale, counting down each second to zero.
@riverpod
class FlashSaleTimerViewModel extends _$FlashSaleTimerViewModel {
  static const Duration _tick = Duration(seconds: 1);

  Timer? _timer;

  @override
  Duration build() {
    ref.onDispose(() => _timer?.cancel());
    return Duration.zero;
  }

  /// Counts down from [left], as the feed reported it.
  void start(Duration left) {
    _timer?.cancel();
    state = left.isNegative ? Duration.zero : left;
    if (state == Duration.zero) return;
    _timer = Timer.periodic(_tick, (timer) {
      state -= _tick;
      if (state <= Duration.zero) {
        state = Duration.zero;
        timer.cancel();
      }
    });
  }
}
