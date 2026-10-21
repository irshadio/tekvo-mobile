import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_view_model.freezed.dart';
part 'cart_view_model.g.dart';

/// What the cart badges, Add buttons and quantity steppers show.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class CartSummary with _$CartSummary {
  const factory CartSummary({
    required int count,
    @Default(<String, int>{}) Map<String, int> quantities,
  }) = _CartSummary;

  const CartSummary._();

  /// The products added on this device.
  Set<String> get added => quantities.keys.toSet();

  int quantityOf(String id) => quantities[id] ?? 0;
}

/// Items in the cart, for every shop screen's badges, Add buttons and
/// steppers. Stand-in until the cart is served: it starts with the
/// design's three items, and the server owns quantities and prices.
@Riverpod(keepAlive: true)
class CartViewModel extends _$CartViewModel {
  static const int sample = 3;

  @override
  CartSummary build() => const CartSummary(count: sample);

  /// Adds one of the product [id] unless it is in the cart already.
  void add(String id) {
    if (state.quantities.containsKey(id)) return;
    increase(id);
  }

  void increase(String id) => state = CartSummary(
    count: state.count + 1,
    quantities: <String, int>{
      ...state.quantities,
      id: state.quantityOf(id) + 1,
    },
  );

  /// Takes one away; the last one leaves the cart.
  void decrease(String id) {
    final quantity = state.quantityOf(id);
    if (quantity == 0) return;
    state = CartSummary(
      count: state.count - 1,
      quantities: <String, int>{...state.quantities, id: quantity - 1}
        ..removeWhere((_, value) => value == 0),
    );
  }
}
