import 'package:customer/features/home/presentation/view_model/flash_sale_timer_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts down from the time the feed reported, stopping at zero', () {
    fakeAsync((async) {
      final container = ProviderContainer.test()
        ..listen(flashSaleTimerViewModelProvider, (_, _) {});
      container
          .read(flashSaleTimerViewModelProvider.notifier)
          .start(const Duration(seconds: 3));

      async.elapse(const Duration(seconds: 1));
      expect(
        container.read(flashSaleTimerViewModelProvider),
        const Duration(seconds: 2),
      );
      async.elapse(const Duration(seconds: 10));
      expect(container.read(flashSaleTimerViewModelProvider), Duration.zero);
    });
  });

  test('a sale already over shows zero', () {
    final container = ProviderContainer.test()
      ..listen(flashSaleTimerViewModelProvider, (_, _) {});
    container
        .read(flashSaleTimerViewModelProvider.notifier)
        .start(const Duration(seconds: -5));

    expect(container.read(flashSaleTimerViewModelProvider), Duration.zero);
  });
}
