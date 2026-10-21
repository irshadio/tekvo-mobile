import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/presentation/view/widgets/filter_parts.dart';
import 'package:customer/features/search/presentation/view_model/filter_draft_view_model.dart';
import 'package:customer/features/search/presentation/view_model/search_results_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Every filter for a search: the groups down the side, the chosen group's
/// values beside them, and how many results they keep. Closes with the
/// filters to apply.
class SearchFiltersView extends ConsumerStatefulWidget {
  const SearchFiltersView({
    required this.query,
    required this.filters,
    super.key,
  });

  final String query;

  /// The filters in use when it opens.
  final SearchFilters filters;

  @override
  ConsumerState<SearchFiltersView> createState() => _SearchFiltersViewState();
}

class _SearchFiltersViewState extends ConsumerState<SearchFiltersView>
    with ViewReadyMixin<SearchFiltersView> {
  static const double _icon = 22;
  static const double _reset = 110;
  static const double _barTop = 13;
  static const double _barBottom = 30;
  static const double _paneTop = 20;
  static const Duration _swap = Duration(milliseconds: 200);

  FilterDraftViewModelProvider get _draft =>
      filterDraftViewModelProvider(widget.query);

  @override
  void onReady() => ref.read(_draft.notifier).start(widget.filters);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final draft = ref.watch(_draft);
    final edit = ref.read(_draft.notifier);
    final results = ref
        .watch(searchResultsViewModelProvider(widget.query))
        .dataOrNull;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.sm.w,
                context.viewPadding.top + AppSpacing.xs.h,
                AppSpacing.lg.w,
                AppSpacing.xs.h,
              ),
              child: Row(
                spacing: AppSpacing.xs.w,
                children: <Widget>[
                  AppIconButton(
                    icon: Assets.iconsClose,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    variant: AppIconButtonVariant.plain,
                    iconSize: _icon,
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(l10n.searchFilters, style: text.titleLarge),
                    ),
                  ),
                  InkWell(
                    onTap: draft.filters.isEmpty ? null : edit.clear,
                    borderRadius: BorderRadius.circular(AppRadius.xs.r),
                    child: Text(
                      l10n.searchClearAll,
                      style: text.labelLarge?.copyWith(
                        color: draft.filters.isEmpty
                            ? colors.onSurfaceVariant
                            : colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FacetRail(
                      filters: draft.filters,
                      shown: draft.facet,
                      onShow: edit.show,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: context.motion(_swap),
                        child: KeyedSubtree(
                          key: ValueKey<FacetKind>(draft.facet),
                          child: results == null
                              ? const SizedBox.shrink()
                              : _pane(draft, results),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
                boxShadow: AppEffects.bottomBar,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  _barTop.h,
                  AppSpacing.lg.w,
                  context.viewPadding.bottom > 0 ? _barBottom.h : _barTop.h,
                ),
                child: Row(
                  spacing: 10.w,
                  children: <Widget>[
                    SizedBox(
                      width: _reset.w,
                      child: OutlinedButton(
                        onPressed: edit.clear,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                          foregroundColor: colors.onSurface,
                          side: BorderSide(
                            color: colors.outlineVariant,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.md.r,
                            ),
                          ),
                        ),
                        child: Text(l10n.searchReset),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: draft.matching == 0
                            ? null
                            : () => Navigator.of(context).pop(draft.filters),
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.md.r,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.searchShowResults(
                            draft.matching ?? results?.count ?? 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pane(FilterDraft draft, SearchResults results) {
    final edit = ref.read(_draft.notifier);
    final facet = results.facets.firstWhere(
      (facet) => facet.kind == draft.facet,
      orElse: () => Facet(kind: draft.facet, options: const <FacetOption>[]),
    );
    final chosen = draft.filters.chosen[draft.facet] ?? const <String>{};
    final text = context.textTheme;
    final rows = <Widget>[
      for (final option in facet.options)
        FacetCheckRow(
          option: option,
          checked: chosen.contains(option.id),
          onTap: () => edit.toggle(draft.facet, option.id),
        ),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        _paneTop.h,
        AppSpacing.lg.w,
        AppSpacing.lg.h,
      ),
      children: <Widget>[
        if (draft.facet == FacetKind.price) ...<Widget>[
          PriceRange(
            spread: results.prices,
            min: draft.filters.minPrice,
            max: draft.filters.maxPrice,
            onChanged: edit.price,
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(context.l10n.searchPopularRanges, style: text.labelLarge),
          SizedBox(height: AppSpacing.lg.h),
        ] else ...<Widget>[
          Semantics(
            header: true,
            child: Text(
              facetLabel(context, draft.facet),
              style: text.titleMedium,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
        ],
        ...rows,
      ],
    );
  }
}
