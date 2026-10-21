import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coupon_view_model.g.dart';

/// Whether the product's coupon is applied to the order. Stand-in until
/// the cart is served, which decides the discount.
@riverpod
class CouponViewModel extends _$CouponViewModel {
  @override
  bool build(String productId) => false;

  void apply() => state = true;
}
