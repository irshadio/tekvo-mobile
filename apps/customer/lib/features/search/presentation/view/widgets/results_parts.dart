import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/shop_category.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The sort's name in the current language.
String searchSortLabel(BuildContext context, SearchSort sort) {
  final l10n = context.l10n;
  return switch (sort) {
    SearchSort.relevance => l10n.searchSortRelevance,
    SearchSort.bestSelling => l10n.searchSortBestSelling,
    SearchSort.priceLow => l10n.searchSortPriceLow,
    SearchSort.priceHigh => l10n.searchSortPriceHigh,
    SearchSort.rating => l10n.searchSortRating,
    SearchSort.newest => l10n.searchSortNewest,
    SearchSort.discount => l10n.searchSortDiscount,
  };
}

/// Sort, filters with how many are on, and one-tap filters, in a row
/// that scrolls sideways.
class ResultsToolbar extends StatelessWidget {
  const ResultsToolbar({
    required this.sort,
    required this.filters,
    required this.onSort,
    required this.onFilters,
    required this.onQuick,
    super.key,
  });

  final SearchSort sort;
  final SearchFilters filters;
  final VoidCallback onSort;
  final VoidCallback onFilters;
  final ValueChanged<QuickFilter> onQuick;

  static const double _divider = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final count = filters.facetCount;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        0,
        AppSpacing.lg.w,
        AppSpacing.md.h,
      ),
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          _ToolButton(
            label: l10n.searchSort(searchSortLabel(context, sort)),
            trailing: Assets.iconsChevronDown,
            onTap: onSort,
          ),
          _ToolButton(
            label: l10n.searchFilters,
            leading: Assets.iconsFilter,
            badge: count == 0 ? null : count,
            onTap: onFilters,
          ),
          Container(
            width: AppBorders.thin,
            height: _divider.h,
            color: colors.outlineVariant,
          ),
          for (final quick in QuickFilter.values)
            _ToolButton(
              label: switch (quick) {
                QuickFilter.underTwoThousand => l10n.searchQuickUnder,
                QuickFilter.fourStarsUp => l10n.searchQuickRating,
                QuickFilter.freeDelivery => l10n.searchQuickFree,
                QuickFilter.inStock => l10n.searchQuickStock,
              },
              selected: filters.quick.contains(quick),
              onTap: () => onQuick(quick),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.onTap,
    this.leading,
    this.trailing,
    this.badge,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? leading;
  final String? trailing;
  final int? badge;
  final bool selected;

  static const double _height = 38;
  static const double _icon = 16;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = selected ? colors.onInverseSurface : colors.onSurface;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    Widget icon(String asset) => SvgPicture.asset(
      asset,
      width: _icon.r,
      height: _icon.r,
      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: context.motion(_swap),
            height: _height.h,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
            decoration: BoxDecoration(
              color: selected ? colors.inverseSurface : null,
              borderRadius: radius,
              border: Border.all(
                color: selected ? colors.inverseSurface : colors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s6.w,
              children: <Widget>[
                if (leading case final asset?) icon(asset),
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(color: ink),
                ),
                if (badge case final count?) FilterCountBadge(count: count),
                if (trailing case final asset?) icon(asset),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How many filters are on in a group, on a brand-coloured dot.
class FilterCountBadge extends StatelessWidget {
  const FilterCountBadge({required this.count, super.key});

  final int count;

  static const double _size = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(minWidth: _size.r),
      height: _size.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(_size.r / 2),
      ),
      child: Text(
        '$count',
        semanticsLabel: context.l10n.searchSelected(count),
        style: context.textTheme.labelSmall?.copyWith(color: colors.onPrimary),
      ),
    );
  }
}

/// What to try when nothing matches: a spelling, a category, popular
/// searches.
class NoResults extends StatelessWidget {
  const NoResults({
    required this.results,
    required this.onSearch,
    required this.onBrowse,
    super.key,
  });

  final SearchResults results;
  final ValueChanged<String> onSearch;
  final VoidCallback? onBrowse;

  static const double _ring = 136;
  static const double _dot = 92;
  static const double _icon = 42;
  static const double _chevron = 18;
  static const double _hintHorizontal = 14;
  static const double _hintRadius = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final didYouMean = results.didYouMean;
    final browse = results.browse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s20.h,
      children: <Widget>[
        if (didYouMean != null)
          Material(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(_hintRadius.r),
            child: InkWell(
              onTap: () => onSearch(didYouMean),
              borderRadius: BorderRadius.circular(_hintRadius.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _hintHorizontal.w,
                  vertical: AppSpacing.md.h,
                ),
                child: Row(
                  spacing: AppSpacing.xs.w,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.searchDidYouMean(didYouMean),
                        style: text.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      Assets.iconsChevronRight,
                      width: _chevron.r,
                      height: _chevron.r,
                      colorFilter: ColorFilter.mode(
                        colors.onPrimaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Column(
          spacing: 14.h,
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                width: _ring.r,
                height: _ring.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: _dot.r,
                  height: _dot.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    Assets.iconsSearch,
                    width: _icon.r,
                    height: _icon.r,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Semantics(
              header: true,
              child: Text(
                l10n.searchNoResults(results.query),
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
            ),
            Text(
              l10n.searchNoResultsBody,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (browse != null && onBrowse != null)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm.h),
                child: FilledButton(
                  onPressed: onBrowse,
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                  ),
                  child: Text(
                    l10n.searchBrowseAll(browse.label(context).toLowerCase()),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
