import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_count_view_model.g.dart';

/// Items in the cart, for the badges every shop screen shows. Stand-in
/// until the cart is served: it starts with the design's three items.
@Riverpod(keepAlive: true)
class CartCountViewModel extends _$CartCountViewModel {
  static const int sample = 3;

  @override
  int build() => sample;

  void add() => state = state + 1;
}
