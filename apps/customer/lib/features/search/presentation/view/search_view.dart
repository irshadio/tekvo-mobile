import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/state/view_state.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/features/search/presentation/view/widgets/search_bar.dart';
import 'package:customer/features/search/presentation/view/widgets/search_home_parts.dart';
import 'package:customer/features/search/presentation/view/widgets/suggestion_parts.dart';
import 'package:customer/features/search/presentation/view_model/search_home_view_model.dart';
import 'package:customer/features/search/presentation/view_model/suggestions_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Search: recent and trending searches, categories and recently viewed
/// before typing; suggestions, the store and products while typing.
class SearchView extends ConsumerStatefulWidget {
  const SearchView({this.query = '', super.key});

  /// The words to start with, such as when editing a search.
  final String query;

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView>
    with ViewReadyMixin<SearchView> {
  static const double _gap = 24;
  static const double _bottom = 34;
  static const Duration _typingPause = Duration(milliseconds: 250);
  static const Duration _swap = Duration(milliseconds: 200);

  late final TextEditingController _query = TextEditingController(
    text: widget.query,
  );
  final FocusNode _focus = FocusNode();
  Timer? _typing;

  @override
  void dispose() {
    _typing?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    unawaited(ref.read(searchHomeViewModelProvider.notifier).load());
    if (widget.query.isNotEmpty) _suggest(widget.query);
    _focus.requestFocus();
  }

  void _typed(String words) {
    _typing?.cancel();
    _typing = Timer(_typingPause, () => _suggest(words));
  }

  void _suggest(String words) {
    if (words.trim().isEmpty) return;
    unawaited(ref.read(suggestionsViewModelProvider.notifier).load(words));
  }

  void _search(String words) {
    final query = words.trim();
    if (query.isEmpty) return;
    final home = ref.read(searchHomeViewModelProvider).dataOrNull;
    ref
        .read(searchHistoryViewModelProvider.notifier)
        .add(query, shown: home?.recent ?? const <String>[]);
    unawaited(context.pushNamed<void>(Routes.searchResults, arguments: query));
  }

  void _open(String route, {Object? arguments}) =>
      unawaited(context.pushNamed<void>(route, arguments: arguments));

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(searchHomeViewModelProvider, context);
    final colors = context.colors;
    final home = ref.watch(searchHomeViewModelProvider);
    final history = ref.watch(searchHistoryViewModelProvider);
    final suggestions = ref.watch(suggestionsViewModelProvider).dataOrNull;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: Column(
          children: <Widget>[
            ShopSearchBar(
              controller: _query,
              focusNode: _focus,
              onChanged: _typed,
              onSubmitted: _search,
              onPhoto: () => _open(Routes.searchByPhoto),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListenableBuilder(
                  listenable: _query,
                  builder: (context, _) => AnimatedSwitcher(
                    duration: context.motion(_swap),
                    child: _query.text.trim().isEmpty
                        ? KeyedSubtree(
                            key: const ValueKey<String>('home'),
                            child: ViewStateSwitcher<SearchHome>(
                              state: home,
                              onRetry: () => unawaited(
                                ref
                                    .read(searchHomeViewModelProvider.notifier)
                                    .load(),
                              ),
                              onData: (data) => _home(data, history),
                            ),
                          )
                        : KeyedSubtree(
                            key: const ValueKey<String>('suggestions'),
                            child: _suggestions(suggestions),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets get _padding => EdgeInsets.fromLTRB(
    AppSpacing.lg.w,
    AppSpacing.lg.h,
    AppSpacing.lg.w,
    _bottom.h,
  );

  Widget _home(SearchHome home, List<String>? history) {
    final recent = history ?? home.recent;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _padding,
      children: <Widget>[
        if (recent.isNotEmpty) ...<Widget>[
          RecentSearches(
            searches: recent,
            onSearch: _search,
            onClear: ref.read(searchHistoryViewModelProvider.notifier).clear,
          ),
          SizedBox(height: _gap.h),
        ],
        TrendingSearches(trending: home.trending, onSearch: _search),
        SizedBox(height: _gap.h),
        PopularCategories(
          onCategory: (category) =>
              _open(Routes.productList, arguments: category),
        ),
        SizedBox(height: _gap.h),
        RecentlyViewedRow(
          products: home.recentlyViewed,
          onProduct: (id) => _open(Routes.product, arguments: id),
          onSeeAll: () => _open(Routes.recentlyViewed),
        ),
      ],
    );
  }

  Widget _suggestions(Suggestions? found) {
    if (found == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final store = found.store;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _padding,
      children: <Widget>[
        for (final suggestion in found.suggestions)
          SuggestionRow(
            suggestion: suggestion,
            typed: _query.text,
            onTap: () => suggestion.category == null
                ? _search(suggestion.query)
                : _open(Routes.productList, arguments: suggestion.category),
          ),
        if (store != null) ...<Widget>[
          SizedBox(height: AppSpacing.lg.h),
          Divider(height: 1, color: context.colors.outlineVariant),
          SizedBox(height: AppSpacing.lg.h),
          StoreHitCard(
            store: store,
            onVisit: () => _open(Routes.store, arguments: store.brand),
          ),
        ],
        if (found.products.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.lg.h),
          SearchSectionTitle(
            title: l10n.searchProducts,
            link: l10n.productSeeAllCount(found.total),
            onLink: () => _search(_query.text),
          ),
          SizedBox(height: AppSpacing.md.h),
          for (final product in found.products) ...<Widget>[
            ProductLine(
              product: product,
              onTap: () => _open(Routes.product, arguments: product.id),
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
        ],
      ],
    );
  }
}
