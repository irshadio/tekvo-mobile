import 'package:core/network/app_foreground.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('only resumed is foreground, and repeats are dropped', () async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final seen = <bool>[];
    final subscription = AppForegroundImpl().changes.listen(seen.add);
    const <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(binding.handleAppLifecycleStateChanged);
    await pumpEventQueue();
    expect(seen, <bool>[true, false, true]);
    await subscription.cancel();
  });
}
