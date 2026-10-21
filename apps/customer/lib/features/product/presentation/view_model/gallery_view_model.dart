import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_view_model.g.dart';

/// The photo on show in a product's gallery.
@riverpod
class GalleryViewModel extends _$GalleryViewModel {
  @override
  int build(String productId) => 0;

  // The index is the whole state; a setter would read as a field.
  // ignore: use_setters_to_change_properties
  void show(int index) => state = index;
}
