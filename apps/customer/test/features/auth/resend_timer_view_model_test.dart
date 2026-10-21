import 'package:customer/features/auth/presentation/view_model/resend_timer_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts down each second and stops at zero', () {
    fakeAsync((async) {
      final container = ProviderContainer.test()
        ..listen(resendTimerViewModelProvider, (_, _) {});

      expect(container.read(resendTimerViewModelProvider), 30);
      async.elapse(const Duration(seconds: 6));
      expect(container.read(resendTimerViewModelProvider), 24);
      async.elapse(const Duration(seconds: 40));
      expect(container.read(resendTimerViewModelProvider), 0);
    });
  });

  test('restarts only once the wait is over', () {
    fakeAsync((async) {
      final container = ProviderContainer.test()
        ..listen(resendTimerViewModelProvider, (_, _) {});
      final timer = container.read(resendTimerViewModelProvider.notifier);

      async.elapse(const Duration(seconds: 10));
      timer.restart();
      expect(container.read(resendTimerViewModelProvider), 20);

      async.elapse(const Duration(seconds: 20));
      timer.restart();
      expect(container.read(resendTimerViewModelProvider), 30);
      async.elapse(const Duration(seconds: 1));
      expect(container.read(resendTimerViewModelProvider), 29);
    });
  });
}
