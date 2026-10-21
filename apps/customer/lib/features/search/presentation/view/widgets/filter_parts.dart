import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/presentation/view/widgets/results_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The facet's name in the current language.
String facetLabel(BuildContext context, FacetKind kind) {
  final l10n = context.l10n;
  return switch (kind) {
    FacetKind.category => l10n.searchFacetCategory,
    FacetKind.brand => l10n.searchFacetBrand,
    FacetKind.price => l10n.searchFacetPrice,
    FacetKind.rating => l10n.searchFacetRating,
    FacetKind.storage => l10n.searchFacetStorage,
    FacetKind.colour => l10n.searchFacetColour,
    FacetKind.delivery => l10n.searchFacetDelivery,
    FacetKind.availability => l10n.searchFacetAvailability,
    FacetKind.discount => l10n.searchFacetDiscount,
  };
}

/// Every facet down the side, the one on show marked, with how many are
/// chosen in each.
class FacetRail extends StatelessWidget {
  const FacetRail({
    required this.filters,
    required this.shown,
    required this.onShow,
    super.key,
  });

  final SearchFilters filters;
  final FacetKind shown;
  final ValueChanged<FacetKind> onShow;

  static const double _width = 128;
  static const double _marker = 3;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Container(
      width: _width.w,
      color: colors.surfaceContainer,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final kind in FacetKind.values)
            Semantics(
              selected: kind == shown,
              button: true,
              child: InkWell(
                onTap: () => onShow(kind),
                child: AnimatedContainer(
                  duration: context.motion(_swap),
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg.w - (kind == shown ? _marker : 0),
                    AppSpacing.lg.h,
                    10.w,
                    AppSpacing.lg.h,
                  ),
                  decoration: BoxDecoration(
                    color: kind == shown ? colors.surfaceContainerLowest : null,
                    border: kind == shown
                        ? BorderDirectional(
                            start: BorderSide(
                              color: colors.primary,
                              width: _marker,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    spacing: AppSpacing.s6.w,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          facetLabel(context, kind),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kind == shown
                              ? text.titleSmall?.copyWith(color: colors.primary)
                              : text.labelLarge,
                        ),
                      ),
                      if (filters.countOf(kind) case final count when count > 0)
                        FilterCountBadge(count: count),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A value to tick, with how many results have it.
class FacetCheckRow extends StatelessWidget {
  const FacetCheckRow({
    required this.option,
    required this.checked,
    required this.onTap,
    super.key,
  });

  final FacetOption option;
  final bool checked;
  final VoidCallback onTap;

  static const double _box = 22;
  static const double _tick = 16;
  static const double _radius = 5;
  static const double _outline = 1.5;
  static const Duration _fill = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              spacing: 10.w,
              children: <Widget>[
                AnimatedContainer(
                  duration: context.motion(_fill),
                  width: _box.r,
                  height: _box.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: checked ? colors.primary : null,
                    borderRadius: BorderRadius.circular(_radius.r),
                    border: checked
                        ? null
                        : Border.all(color: colors.outline, width: _outline),
                  ),
                  child: AnimatedScale(
                    duration: context.motion(_fill),
                    scale: checked ? 1 : 0,
                    child: SvgPicture.asset(
                      Assets.iconsCheck,
                      width: _tick.r,
                      height: _tick.r,
                      colorFilter: ColorFilter.mode(
                        colors.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Expanded(child: Text(option.label, style: text.bodyMedium)),
                Text(
                  '${option.count}',
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The price filter: how prices spread, a range to drag, and the range as
/// numbers.
class PriceRange extends StatelessWidget {
  const PriceRange({
    required this.spread,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final PriceSpread spread;

  /// The chosen range in whole dirhams; null ends are open.
  final int? min;
  final int? max;
  final void Function(int? min, int? max) onChanged;

  static const double _bars = 56;
  static const double _bar = 3;
  static const double _boxHeight = 54;
  static const double _boxHorizontal = 10;
  static const Duration _grow = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final low = (min ?? spread.min).clamp(spread.min, spread.max);
    final high = (max ?? spread.max).clamp(low, spread.max);
    final tallest = spread.histogram.fold(1, (a, b) => a > b ? a : b);
    final slice = (spread.max - spread.min) / spread.histogram.length;
    String aed(int units) => context.coreL10n.moneyAmount(
      'AED',
      decimal.format(units),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg.h,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(l10n.searchPriceRange, style: text.titleMedium),
        ),
        Text(
          l10n.searchPriceBetween(aed(low), aed(high)),
          style: text.titleSmall?.copyWith(color: colors.primary),
        ),
        ExcludeSemantics(
          child: SizedBox(
            height: _bars.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: _bar.w,
              children: <Widget>[
                for (final (i, count) in spread.histogram.indexed)
                  Expanded(
                    child: AnimatedContainer(
                      duration: context.motion(_grow),
                      height: (_bars * (count == 0 ? 0.08 : count / tallest)).h,
                      decoration: BoxDecoration(
                        color:
                            spread.min + slice * (i + 1) > low &&
                                spread.min + slice * i < high
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.xxs.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.surfaceContainerHighest,
            thumbColor: colors.surfaceContainerLowest,
            overlayColor: colors.primary.withValues(
              alpha: AppOpacity.focus,
            ),
            trackHeight: AppSpacing.xs,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
            ),
          ),
          child: RangeSlider(
            min: spread.min.toDouble(),
            max: spread.max.toDouble(),
            values: RangeValues(low.toDouble(), high.toDouble()),
            labels: RangeLabels(aed(low), aed(high)),
            onChanged: (values) => onChanged(
              values.start.round() <= spread.min ? null : values.start.round(),
              values.end.round() >= spread.max ? null : values.end.round(),
            ),
          ),
        ),
        Row(
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            Expanded(
              child: _numberBox(context, l10n.searchMin, decimal.format(low)),
            ),
            Text(
              '–',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            Expanded(
              child: _numberBox(context, l10n.searchMax, decimal.format(high)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numberBox(BuildContext context, String label, String value) {
    final colors = context.colors;
    final text = context.textTheme;
    return Container(
      constraints: BoxConstraints(minHeight: _boxHeight.h),
      padding: EdgeInsets.symmetric(
        horizontal: _boxHorizontal.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          Text(value, style: text.titleSmall),
        ],
      ),
    );
  }
}
