import 'package:flutter/widgets.dart';

/// Shows the cart from anywhere below it, such as an Add button whose
/// product is already in the cart.
class CartShortcut extends InheritedWidget {
  const CartShortcut({
    required this.onOpenCart,
    required super.child,
    super.key,
  });

  final VoidCallback onOpenCart;

  /// The nearest shortcut's action, or null where there is none.
  static VoidCallback? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartShortcut>()?.onOpenCart;

  @override
  bool updateShouldNotify(CartShortcut oldWidget) =>
      oldWidget.onOpenCart != onOpenCart;
}
