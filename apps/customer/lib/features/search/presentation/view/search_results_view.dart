import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/presentation/widgets/choice_sheet.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/presentation/widgets/product/product_grid.dart';
import 'package:core/presentation/widgets/product/product_row.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/search/domain/entities/search_results.dart';
import 'package:customer/features/search/presentation/view/widgets/results_parts.dart';
import 'package:customer/features/search/presentation/view/widgets/search_bar.dart';
import 'package:customer/features/search/presentation/view/widgets/search_home_parts.dart';
import 'package:customer/features/search/presentation/view/widgets/suggestion_parts.dart';
import 'package:customer/features/search/presentation/view_model/search_results_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// What the filters screen opens on: the search and its filters in use.
typedef FiltersRequest = ({String query, SearchFilters filters});

/// The products a search finds, with sort, filters and quick filters, and
/// what to try when it finds none.
class SearchResultsView extends ConsumerStatefulWidget {
  const SearchResultsView({required this.query, super.key});

  final String query;

  @override
  ConsumerState<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends ConsumerState<SearchResultsView>
    with ViewReadyMixin<SearchResultsView> {
  static const double _bottom = 34;
  static const Duration _swap = Duration(milliseconds: 250);

  late final TextEditingController _query = TextEditingController(
    text: widget.query,
  );

  SearchResultsViewModelProvider get _results =>
      searchResultsViewModelProvider(widget.query);
  ResultsQueryViewModelProvider get _order =>
      resultsQueryViewModelProvider(widget.query);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(_results.notifier).load());

  void _open(String route, {Object? arguments}) =>
      unawaited(context.pushNamed<void>(route, arguments: arguments));

  void _edit() => unawaited(
    context.pushReplacementNamed<void, void>(
      Routes.search,
      arguments: _query.text,
    ),
  );

  void _search(String words) => unawaited(
    context.pushReplacementNamed<void, void>(
      Routes.searchResults,
      arguments: words,
    ),
  );

  Future<void> _chooseSort(SearchSort current) async {
    final chosen = await ChoiceSheet.show(
      context,
      title: context.l10n.searchSortTitle,
      options: <String>[
        for (final sort in SearchSort.values) searchSortLabel(context, sort),
      ],
      selected: current.index,
    );
    if (chosen != null && mounted) {
      ref.read(_order.notifier).sort(SearchSort.values[chosen]);
    }
  }

  Future<void> _chooseFilters(SearchFilters current) async {
    final request = (query: widget.query, filters: current);
    final chosen = await context.pushNamed<SearchFilters>(
      Routes.searchFilters,
      arguments: request,
    );
    if (chosen != null && mounted) {
      ref.read(_order.notifier).filter(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_results, context);
    final colors = context.colors;
    final order = ref.watch(_order);
    final results = ref.watch(_results);
    final nothing = results.dataOrNull?.count == 0 && order.filters.isEmpty;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: nothing
            ? colors.surfaceContainerLowest
            : colors.surfaceContainer,
        body: Column(
          children: <Widget>[
            ShopSearchBar(
              controller: _query,
              onTap: _edit,
              bottom: nothing
                  ? null
                  : ResultsToolbar(
                      sort: order.sort,
                      filters: order.filters,
                      onSort: () => unawaited(_chooseSort(order.sort)),
                      onFilters: () => unawaited(_chooseFilters(order.filters)),
                      onQuick: ref.read(_order.notifier).toggleQuick,
                    ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ViewStateSwitcher<SearchResults>(
                  state: results,
                  onRetry: _load,
                  onData: _page,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(SearchResults results) {
    final l10n = context.l10n;
    final text = context.textTheme;
    final store = results.store;
    final browse = results.browse;
    final padding = EdgeInsets.symmetric(horizontal: AppSpacing.lg.w);
    void openProduct(String id) => _open(Routes.product, arguments: id);
    if (results.count == 0) {
      return ListView(
        padding: EdgeInsets.only(top: AppSpacing.lg.h, bottom: _bottom.h),
        children: <Widget>[
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NoResults(
                  results: results,
                  onSearch: _search,
                  onBrowse: browse == null
                      ? null
                      : () => _open(Routes.productList, arguments: browse),
                ),
                SizedBox(height: AppSpacing.s20.h),
                Text(l10n.searchPopularSearches, style: text.titleSmall),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: AppSpacing.sm.w,
                  runSpacing: AppSpacing.sm.h,
                  children: <Widget>[
                    for (final popular in results.popular)
                      AppChip(
                        label: popular,
                        selected: false,
                        onTap: () => _search(popular),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (results.recommended.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.s20.h),
            Padding(
              padding: padding,
              child: SearchSectionTitle(title: l10n.searchYouMightLike),
            ),
            SizedBox(height: AppSpacing.md.h),
            ProductRow(products: results.recommended, onProduct: openProduct),
          ],
        ],
      );
    }
    return ListView(
      padding: EdgeInsets.only(top: AppSpacing.md.h, bottom: _bottom.h),
      children: <Widget>[
        Padding(
          padding: padding,
          child: Text(
            l10n.searchResultsCount(results.count, results.query),
            style: text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        if (store != null) ...<Widget>[
          SizedBox(height: AppSpacing.md.h),
          Padding(
            padding: padding,
            child: StoreHitCard(
              store: store,
              onVisit: () => _open(Routes.store, arguments: store.brand),
            ),
          ),
        ],
        SizedBox(height: AppSpacing.md.h),
        AnimatedSwitcher(
          duration: context.motion(_swap),
          child: Padding(
            key: ValueKey<ResultsQuery>(ref.watch(_order)),
            padding: padding,
            child: ProductGrid(
              products: results.products,
              onProduct: openProduct,
            ),
          ),
        ),
      ],
    );
  }
}
