import 'package:flutter/foundation.dart';

/// A filter the server offers over a product row, such as `5G`, with the
/// products it keeps.
@immutable
final class ProductFacet {
  const ProductFacet({required this.label, required this.productIds});

  final String label;
  final Set<String> productIds;
}
