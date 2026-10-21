import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_picker.g.dart';

/// Lets the user choose photos from their library.
// ignore: one_member_abstracts
abstract interface class PhotoPicker {
  /// Up to [limit] photos as file paths; empty when the user cancels.
  Future<List<String>> pick({required int limit});
}

/// [PhotoPicker] over the `image_picker` plugin, scaled down for upload.
class PhotoPickerImpl implements PhotoPicker {
  const PhotoPickerImpl();

  static const double _maxSide = 2048;
  static const int _quality = 85;

  @override
  Future<List<String>> pick({required int limit}) async {
    if (limit <= 0) return const <String>[];
    final picker = ImagePicker();
    final files = limit == 1
        ? <XFile?>[
            await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: _maxSide,
              maxHeight: _maxSide,
              imageQuality: _quality,
            ),
          ].nonNulls.toList()
        : await picker.pickMultiImage(
            limit: limit,
            maxWidth: _maxSide,
            maxHeight: _maxSide,
            imageQuality: _quality,
          );
    return <String>[for (final file in files.take(limit)) file.path];
  }
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
PhotoPicker photoPicker(Ref ref) => throw UnimplementedError(
  'photoPickerProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
