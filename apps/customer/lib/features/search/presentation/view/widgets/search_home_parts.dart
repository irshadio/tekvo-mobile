import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/presentation/widgets/category_tile.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A section's title with an optional link at its end.
class SearchSectionTitle extends StatelessWidget {
  const SearchSectionTitle({
    required this.title,
    this.link,
    this.onLink,
    super.key,
  });

  final String title;
  final String? link;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final link = this.link;
    return Row(
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: text.titleMedium),
          ),
        ),
        if (link != null)
          InkWell(
            onTap: onLink,
            borderRadius: BorderRadius.circular(AppRadius.xs.r),
            child: Text(
              link,
              style: text.labelLarge?.copyWith(color: context.colors.primary),
            ),
          ),
      ],
    );
  }
}

/// Past searches as outlined chips with a clock.
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    required this.searches,
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  final List<String> searches;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  static const double _clock = 14;
  static const double _height = 38;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: <Widget>[
        SearchSectionTitle(
          title: context.l10n.searchRecent,
          link: context.l10n.searchClearRecent,
          onLink: onClear,
        ),
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: <Widget>[
            for (final search in searches)
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onSearch(search),
                  borderRadius: radius,
                  child: Container(
                    height: _height.h,
                    padding: EdgeInsetsDirectional.only(
                      start: 10.w,
                      end: AppSpacing.md.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.s6.w,
                      children: <Widget>[
                        SvgPicture.asset(
                          Assets.iconsClock,
                          width: _clock.r,
                          height: _clock.r,
                          colorFilter: ColorFilter.mode(
                            colors.onSurfaceVariant,
                            BlendMode.srcIn,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            search,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Searches people are making more of, ranked.
class TrendingSearches extends StatelessWidget {
  const TrendingSearches({
    required this.trending,
    required this.onSearch,
    super.key,
  });

  final List<TrendingSearch> trending;
  final ValueChanged<String> onSearch;

  static const double _rank = 16;
  static const double _bolt = 16;
  static const int _top = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: <Widget>[
        SearchSectionTitle(title: context.l10n.searchTrending),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (i, trend) in trending.indexed)
              InkWell(
                onTap: () => onSearch(trend.query),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(
                            top: BorderSide(color: colors.outlineVariant),
                          ),
                  ),
                  child: Row(
                    spacing: AppSpacing.md.w,
                    children: <Widget>[
                      SizedBox(
                        width: _rank.w,
                        child: Text(
                          '${i + 1}',
                          style: text.titleMedium?.copyWith(
                            color: i < _top
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 1.h,
                          children: <Widget>[
                            Text(trend.query, style: text.bodyMedium),
                            if (trend.note case final note?)
                              Text(
                                note,
                                style: text.bodySmall?.copyWith(
                                  color: trend.hot
                                      ? context.appColors.commerceSale
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (i < _top)
                        SvgPicture.asset(
                          Assets.iconsBolt,
                          width: _bolt.r,
                          height: _bolt.r,
                          colorFilter: ColorFilter.mode(
                            context.appColors.commerceSale,
                            BlendMode.srcIn,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Every category as a tile, four to a row.
class PopularCategories extends StatelessWidget {
  const PopularCategories({required this.onCategory, super.key});

  final ValueChanged<ShopCategory> onCategory;

  static const int _perRow = 4;
  static const double _tile = 84;

  @override
  Widget build(BuildContext context) {
    const categories = ShopCategory.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: <Widget>[
        SearchSectionTitle(title: context.l10n.searchPopularCategories),
        for (var start = 0; start < categories.length; start += _perRow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (final category in categories.skip(start).take(_perRow))
                CategoryTile(
                  icon: category.icon,
                  label: category.label(context),
                  width: _tile,
                  onTap: () => onCategory(category),
                ),
            ],
          ),
      ],
    );
  }
}

/// Products the user looked at, in a row that scrolls sideways.
class RecentlyViewedRow extends StatelessWidget {
  const RecentlyViewedRow({
    required this.products,
    required this.onProduct,
    required this.onSeeAll,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;
  final VoidCallback onSeeAll;

  static const double _photo = 108;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: <Widget>[
        SearchSectionTitle(
          title: context.l10n.searchRecentlyViewed,
          link: context.coreL10n.seeAll,
          onLink: onSeeAll,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.w,
            children: <Widget>[
              for (final product in products)
                InkWell(
                  onTap: () => onProduct(product.id),
                  borderRadius: BorderRadius.circular(_radius.r),
                  child: SizedBox(
                    width: _photo.r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.s6.h,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(_radius.r),
                          child: ColoredBox(
                            color: context.appColors.commerceProductBg,
                            child: Image.asset(
                              product.image,
                              width: _photo.r,
                              height: _photo.r,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                        Text(
                          context.money(product.price),
                          style: text.titleSmall?.copyWith(
                            color: context.appColors.commercePrice,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
