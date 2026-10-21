import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommended_view_model.g.dart';

/// Whether the recommendations show the further products the feed holds.
@riverpod
class RecommendedViewModel extends _$RecommendedViewModel {
  @override
  bool build() => false;

  void showMore() => state = true;
}
