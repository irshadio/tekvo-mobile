import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_model/cart_view_model.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/presentation/widgets/filter_chips.dart';
import 'package:core/sharing/share_service.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/presentation/view/widgets/product_bottom_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/product_page_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/specification_sections.dart';
import 'package:customer/features/product/presentation/view_model/spec_section_view_model.dart';
import 'package:customer/features/product/presentation/view_model/specifications_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// What [SpecificationsView] opens on: the product, and the group to show
/// first, or the top.
typedef SpecificationsRequest = ({String id, SpecGroupKind? start});

/// A product's full specification, grouped, with chips that jump to each
/// group and follow the scroll, and Add to cart pinned at the foot.
class SpecificationsView extends ConsumerStatefulWidget {
  const SpecificationsView({required this.id, this.start, super.key});

  final String id;
  final SpecGroupKind? start;

  @override
  ConsumerState<SpecificationsView> createState() => _SpecificationsViewState();
}

class _SpecificationsViewState extends ConsumerState<SpecificationsView>
    with ViewReadyMixin<SpecificationsView> {
  static const double _band = 8;
  static const double _noteBottom = 8;

  /// How far under the top a group may start and still count as in view.
  static const double _spyMargin = 24;
  static const Duration _jump = Duration(milliseconds: 350);

  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewport = GlobalKey();
  final GlobalKey _overview = GlobalKey();
  final Map<SpecGroupKind, GlobalKey> _groups = <SpecGroupKind, GlobalKey>{
    for (final kind in SpecGroupKind.values) kind: GlobalKey(),
  };

  /// The sections the chips jump to, the overview first.
  List<GlobalKey> _targets = const <GlobalKey>[];

  /// True while a chip's jump animates, so the passing groups do not move
  /// the chosen chip.
  bool _jumping = false;
  bool _started = false;

  SpecificationsViewModelProvider get _specs =>
      specificationsViewModelProvider(widget.id);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_followScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(_specs.notifier).load());

  Future<void> _jumpTo(GlobalKey target, {bool animate = true}) async {
    final section = target.currentContext;
    if (section == null) return;
    _jumping = true;
    await Scrollable.ensureVisible(
      section,
      duration: animate ? context.motion(_jump) : Duration.zero,
      curve: Curves.easeInOutCubic,
    );
    _jumping = false;
  }

  void _choose(int index) {
    ref.read(specSectionViewModelProvider(widget.id).notifier).show(index);
    unawaited(_jumpTo(_targets[index]));
  }

  /// Marks the chip of the last section whose top has reached the top of
  /// the list, or the last chip once the list is at its end.
  void _followScroll() {
    if (_jumping || !_scroll.hasClients || _targets.isEmpty) return;
    final viewport = _viewport.currentContext?.findRenderObject();
    if (viewport is! RenderBox) return;
    final position = _scroll.position;
    var active = 0;
    if (position.pixels >= position.maxScrollExtent - 1) {
      active = _targets.length - 1;
    } else {
      for (final (i, target) in _targets.indexed) {
        final box = target.currentContext?.findRenderObject();
        if (box is! RenderBox) continue;
        final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
        if (top <= _spyMargin.h) active = i;
      }
    }
    final section = ref.read(specSectionViewModelProvider(widget.id).notifier);
    if (ref.read(specSectionViewModelProvider(widget.id)) != active) {
      section.show(active);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenRefreshFailures(_specs, context);
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: ViewStateSwitcher<ProductSpecifications>(
          state: ref.watch(_specs),
          onRetry: _load,
          onData: _page,
        ),
      ),
    );
  }

  Widget _page(ProductSpecifications specs) {
    final l10n = context.l10n;
    final cart = ref.watch(cartViewModelProvider);
    final jumps = <SpecGroup>[
      for (final group in specs.groups)
        if (group.chip != null) group,
    ];
    _targets = <GlobalKey>[
      _overview,
      for (final group in jumps) _groups[group.kind]!,
    ];
    final start = widget.start;
    if (!_started && start != null) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_jumpTo(_groups[start]!, animate: false)),
      );
    }
    final band = SizedBox(height: _band.h);
    final cartActions = ref.read(cartViewModelProvider.notifier);
    return Column(
      children: <Widget>[
        ProductPageBar(
          title: l10n.productSpecsTitle,
          actions: <Widget>[
            ProductPageBar.action(
              icon: Assets.iconsShare,
              tooltip: l10n.productShare,
              onPressed: () => unawaited(
                ref.read(shareServiceProvider).shareText(specs.name),
              ),
            ),
          ],
          bottom: FilterChips(
            labels: <String>[
              l10n.productOverview,
              for (final group in jumps) group.chip!,
            ],
            selected: ref.watch(specSectionViewModelProvider(widget.id)),
            onSelect: _choose,
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SingleChildScrollView(
              key: _viewport,
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SpecificationSummary(specs: specs),
                  band,
                  KeyedSubtree(
                    key: _overview,
                    child: SpecificationOverview(specs: specs),
                  ),
                  for (final group in specs.groups) ...<Widget>[
                    band,
                    KeyedSubtree(
                      key: _groups[group.kind],
                      child: SpecificationGroup(group: group),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg.w,
                      AppSpacing.md.h,
                      AppSpacing.lg.w,
                      _noteBottom.h + AppSpacing.lg.h,
                    ),
                    child: Text(
                      l10n.productSpecsNote,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ProductBottomBar(
          price: specs.price,
          freeDelivery: specs.freeDelivery,
          quantity: cart.quantityOf(specs.id),
          onAdd: () => cartActions.add(specs.id),
          onIncrease: () => cartActions.increase(specs.id),
          onDecrease: () => cartActions.decrease(specs.id),
        ),
      ],
    );
  }
}
