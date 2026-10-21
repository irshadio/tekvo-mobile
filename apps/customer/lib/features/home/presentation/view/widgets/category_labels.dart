import 'package:core/catalog/shop_category.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/widgets.dart';

/// [category]'s name in the current language.
String categoryLabel(BuildContext context, ShopCategory category) {
  final l10n = context.l10n;
  return switch (category) {
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
