import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'added_toast_view_model.g.dart';

/// Whether the "Added to cart" toast shows; it hides after [shown].
@riverpod
class AddedToastViewModel extends _$AddedToastViewModel {
  static const Duration shown = Duration(seconds: 4);

  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  void show() {
    _timer?.cancel();
    state = true;
    _timer = Timer(shown, hide);
  }

  void hide() {
    _timer?.cancel();
    state = false;
  }
}
