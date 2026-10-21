import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_choices_view_model.g.dart';

/// What the user picked on a product page: options, bundle items left
/// out, protection plans and reviews marked helpful.
@immutable
final class ProductChoices {
  const ProductChoices({
    this.options = const <int, int>{},
    this.skipped = const <String>{},
    this.protection = const <String>{},
    this.helpful = const <String>{},
    this.restockAlerts = const <String>{},
  });

  /// The option chosen in each group, by the group's index, for the groups
  /// the user changed.
  final Map<int, int> options;

  /// Bundle items unticked, by id.
  final Set<String> skipped;
  final Set<String> protection;
  final Set<String> helpful;

  /// Sold-out options the user asked to hear about, by name.
  final Set<String> restockAlerts;

  ProductChoices copyWith({
    Map<int, int>? options,
    Set<String>? skipped,
    Set<String>? protection,
    Set<String>? helpful,
    Set<String>? restockAlerts,
  }) => ProductChoices(
    options: options ?? this.options,
    skipped: skipped ?? this.skipped,
    protection: protection ?? this.protection,
    helpful: helpful ?? this.helpful,
    restockAlerts: restockAlerts ?? this.restockAlerts,
  );
}

/// A product page's picks. Stand-in until they are sent with the order.
@riverpod
class ProductChoicesViewModel extends _$ProductChoicesViewModel {
  @override
  ProductChoices build(String productId) => const ProductChoices();

  void choose(int group, int option) => state = state.copyWith(
    options: <int, int>{...state.options, group: option},
  );

  void toggleBundleItem(String id) =>
      state = state.copyWith(skipped: _toggle(state.skipped, id));

  void toggleProtection(String id) =>
      state = state.copyWith(protection: _toggle(state.protection, id));

  void toggleHelpful(String id) =>
      state = state.copyWith(helpful: _toggle(state.helpful, id));

  void alertRestock(String option) => state = state.copyWith(
    restockAlerts: <String>{...state.restockAlerts, option},
  );

  static Set<String> _toggle(Set<String> ids, String id) => ids.contains(id)
      ? (Set<String>.of(ids)..remove(id))
      : <String>{...ids, id};
}
