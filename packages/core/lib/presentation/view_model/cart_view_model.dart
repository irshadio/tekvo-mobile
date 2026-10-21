import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_view_model.freezed.dart';
part 'cart_view_model.g.dart';

/// What the cart badges and Add buttons show.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class CartSummary with _$CartSummary {
  const factory CartSummary({
    required int count,
    @Default(<String>{}) Set<String> added,
  }) = _CartSummary;
}

/// Items in the cart, for every shop screen's badges and Add buttons.
/// Stand-in until the cart is served: it starts with the design's three
/// items, and the server owns quantities and prices.
@Riverpod(keepAlive: true)
class CartViewModel extends _$CartViewModel {
  static const int sample = 3;

  @override
  CartSummary build() => const CartSummary(count: sample);

  /// Adds the product [id] once; it then shows as added.
  void add(String id) {
    if (state.added.contains(id)) return;
    state = CartSummary(count: state.count + 1, added: {...state.added, id});
  }
}
