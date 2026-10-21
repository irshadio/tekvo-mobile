import 'package:core/utils/money.dart';
import 'package:flutter/foundation.dart';

/// One way the product comes, such as a colour or a storage size.
@immutable
final class ProductOption {
  const ProductOption({
    required this.name,
    this.swatch,
    this.price,
    this.was,
    this.saving,
    this.title,
    this.soldOut = false,
    this.restock,
    this.alternative,
    this.alternativeNote,
  });

  /// Such as `Titanium Black` or `256 GB`.
  final String name;

  /// The colour to show, as 0xAARRGGBB, for a colour option.
  final int? swatch;

  /// What the product costs with this option.
  final Money? price;

  /// The price before a sale, with this option.
  final Money? was;
  final Money? saving;

  /// The product's full name with this option, when it changes it.
  final String? title;
  final bool soldOut;

  /// When a sold-out option is expected back, such as
  /// `Expected back around 2 Nov.`
  final String? restock;

  /// The option in the same group to offer instead, by index.
  final int? alternative;

  /// How soon [alternative] arrives, such as `arrives today by 9 PM`.
  final String? alternativeNote;
}

/// Options to choose one of, such as every colour.
@immutable
final class ProductOptionGroup {
  const ProductOptionGroup({
    required this.name,
    required this.options,
    this.chosen = 0,
  });

  /// Such as `Colour`.
  final String name;
  final List<ProductOption> options;

  /// The option chosen when the page opens.
  final int chosen;

  /// Colours show as swatches, the rest as boxes.
  bool get swatches => options.every((option) => option.swatch != null);
}
