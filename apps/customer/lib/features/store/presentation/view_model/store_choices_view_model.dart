import 'dart:async';

import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/features/store/domain/repositories/store_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_choices_view_model.g.dart';

/// What the user did on a store page: following it, coupons collected and
/// the product order.
@immutable
final class StoreChoices {
  const StoreChoices({
    this.following = false,
    this.collected = const <String>{},
    this.sort = StoreSort.popular,
  });

  final bool following;

  /// Coupons collected here, by id.
  final Set<String> collected;
  final StoreSort sort;

  StoreChoices copyWith({
    bool? following,
    Set<String>? collected,
    StoreSort? sort,
  }) => StoreChoices(
    following: following ?? this.following,
    collected: collected ?? this.collected,
    sort: sort ?? this.sort,
  );
}

/// A store page's choices; following and collecting are sent as they
/// happen.
@riverpod
class StoreChoicesViewModel extends _$StoreChoicesViewModel {
  @override
  StoreChoices build(String brand) => const StoreChoices();

  void toggleFollow(String storeId) {
    state = state.copyWith(following: !state.following);
    unawaited(
      ref.read(storeRepositoryProvider).follow(storeId, on: state.following),
    );
  }

  void collect(String storeId, String couponId) {
    state = state.copyWith(collected: <String>{...state.collected, couponId});
    unawaited(
      ref.read(storeRepositoryProvider).collectCoupon(storeId, couponId),
    );
  }

  void sort(StoreSort sort) => state = state.copyWith(sort: sort);
}
