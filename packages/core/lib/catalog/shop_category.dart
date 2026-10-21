import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:flutter/widgets.dart';

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

extension ShopCategoryLabel on ShopCategory {
  /// The category's name in the current language.
  String label(BuildContext context) {
    final l10n = context.coreL10n;
    return switch (this) {
      ShopCategory.phones => l10n.categoryPhones,
      ShopCategory.laptops => l10n.categoryLaptops,
      ShopCategory.audio => l10n.categoryAudio,
      ShopCategory.watches => l10n.categoryWatches,
      ShopCategory.cameras => l10n.categoryCameras,
      ShopCategory.gaming => l10n.categoryGaming,
      ShopCategory.tvs => l10n.categoryTvs,
      ShopCategory.speakers => l10n.categorySpeakers,
    };
  }
}
