import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_draft_view_model.g.dart';

/// The review being written for a product.
@riverpod
class ReviewDraftViewModel extends _$ReviewDraftViewModel {
  @override
  ReviewDraft build(String productId) => const ReviewDraft();

  void rate(int stars) => state = state.copyWith(stars: stars);

  void toggleLike(String like) => state = state.copyWith(
    liked: state.liked.contains(like)
        ? (Set<String>.of(state.liked)..remove(like))
        : <String>{...state.liked, like},
  );

  void headline(String text) => state = state.copyWith(headline: text);

  void body(String text) => state = state.copyWith(body: text);

  void addPhotos(List<String> paths) =>
      state = state.copyWith(photos: <String>[...state.photos, ...paths]);

  void removePhoto(String path) => state = state.copyWith(
    photos: <String>[
      for (final photo in state.photos)
        if (photo != path) photo,
    ],
  );

  // The flag is the change; a setter would read as a field.
  // ignore: avoid_positional_boolean_parameters
  void showName(bool show) => state = state.copyWith(showName: show);
}
