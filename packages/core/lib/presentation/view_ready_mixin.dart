import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs [onReady] once after the first frame. Trigger a ViewModel's first
/// load there: changing a provider during `build` or `initState` throws.
mixin ViewReadyMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void onReady();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onReady();
    });
  }
}
