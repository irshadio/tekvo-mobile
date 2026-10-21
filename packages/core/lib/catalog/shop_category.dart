import 'package:core/assets/assets.gen.dart';

/// The product categories the shop sorts its catalogue into.
enum ShopCategory {
  phones,
  laptops,
  audio,
  watches,
  cameras,
  gaming,
  tvs,
  speakers,
}

extension ShopCategoryIcon on ShopCategory {
  /// The category's icon, an `Assets` key.
  String get icon => switch (this) {
    ShopCategory.phones => Assets.iconsPhone,
    ShopCategory.laptops => Assets.iconsLaptop,
    ShopCategory.audio => Assets.iconsHeadphones,
    ShopCategory.watches => Assets.iconsWatch,
    ShopCategory.cameras => Assets.iconsCamera,
    ShopCategory.gaming => Assets.iconsGamepad,
    ShopCategory.tvs => Assets.iconsTv,
    ShopCategory.speakers => Assets.iconsSpeaker,
  };
}
