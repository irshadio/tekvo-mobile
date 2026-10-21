import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_view_model.g.dart';

/// The ids of the products the user saved. Stand-in until the wishlist is
/// served.
@Riverpod(keepAlive: true)
class WishlistViewModel extends _$WishlistViewModel {
  @override
  Set<String> build() => const <String>{};

  void toggle(String id) => state = state.contains(id)
      ? (Set<String>.of(state)..remove(id))
      : <String>{...state, id};
}
