import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_foreground.g.dart';

/// Whether the app is on screen and in use. Off screen, the OS throttles or
/// suspends network work, so its results cannot be trusted.
abstract interface class AppForeground {
  /// The current state first, then each change.
  Stream<bool> get changes;
}

/// Only [AppLifecycleState.resumed] is foreground: locking passes through
/// `inactive` before `paused`. An unreported state counts as foreground.
class AppForegroundImpl implements AppForeground {
  @override
  Stream<bool> get changes {
    AppLifecycleListener? listener;
    late final StreamController<bool> controller;
    controller = StreamController<bool>(
      onListen: () {
        final initial = WidgetsBinding.instance.lifecycleState;
        controller.add(initial == null || initial == AppLifecycleState.resumed);
        listener = AppLifecycleListener(
          onStateChange: (state) =>
              controller.add(state == AppLifecycleState.resumed),
        );
      },
      onCancel: () => listener?.dispose(),
    );
    return controller.stream.distinct();
  }
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
AppForeground appForeground(Ref ref) => throw UnimplementedError(
  'appForegroundProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
