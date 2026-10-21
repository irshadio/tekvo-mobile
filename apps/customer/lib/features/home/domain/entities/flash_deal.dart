import 'package:customer/features/home/domain/entities/product.dart';
import 'package:flutter/foundation.dart';

/// A product in the flash sale and how much of its stock has sold.
@immutable
final class FlashDeal {
  const FlashDeal({
    required this.product,
    required this.soldPercent,
    this.almostGone = false,
  });

  final Product product;
  final int soldPercent;

  /// The server's flag for stock about to run out.
  final bool almostGone;
}
