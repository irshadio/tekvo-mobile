import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_model/wishlist_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the cart counts each product once', () {
    final container = ProviderContainer.test();
    container.read(cartViewModelProvider.notifier)
      ..add('a')
      ..add('a')
      ..add('b');

    final cart = container.read(cartViewModelProvider);
    expect(cart.count, CartViewModel.sample + 2);
    expect(cart.added, {'a', 'b'});
  });

  test('a stepper raises and lowers a quantity, the last one leaving', () {
    final container = ProviderContainer.test();
    container.read(cartViewModelProvider.notifier)
      ..add('a')
      ..increase('a')
      ..decrease('a');
    expect(container.read(cartViewModelProvider).quantityOf('a'), 1);

    container.read(cartViewModelProvider.notifier).decrease('a');
    final cart = container.read(cartViewModelProvider);
    expect(cart.added, isEmpty);
    expect(cart.count, CartViewModel.sample);
  });

  test('the wishlist toggles a product in and out', () {
    final container = ProviderContainer.test();
    final wishlist = container.read(wishlistViewModelProvider.notifier)
      ..toggle('a')
      ..toggle('b');
    expect(container.read(wishlistViewModelProvider), {'a', 'b'});

    wishlist.toggle('a');
    expect(container.read(wishlistViewModelProvider), {'b'});
  });
}
