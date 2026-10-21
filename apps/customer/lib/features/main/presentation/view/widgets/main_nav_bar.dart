import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/view_model/cart_count_view_model.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The main screen's bottom navigation: one item per [MainTab], the
/// [selected] one in a tinted pill; the cart shows its item count.
class MainNavBar extends ConsumerWidget {
  const MainNavBar({required this.selected, required this.onSelect, super.key});

  final MainTab selected;
  final ValueChanged<MainTab> onSelect;

  static const double _bottom = 22;
  static const double _side = 12;

  /// The top rule's default width; the items sit below it, as designed.
  static const double _rule = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final cartCount = ref.watch(cartCountViewModelProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(_side.w, _rule, _side.w, _bottom.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final tab in MainTab.values)
              _NavItem(
                tab: tab,
                selected: tab == selected,
                badge: tab == MainTab.cart && cartCount > 0 ? cartCount : null,
                onTap: () => onSelect(tab),
              ),
          ],
        ),
      ),
    );
  }
}

/// [tab]'s label in the current language.
String tabLabel(MainTab tab, AppLocalizations l10n) => switch (tab) {
  MainTab.home => l10n.navHome,
  MainTab.explore => l10n.navExplore,
  MainTab.cart => l10n.navCart,
  MainTab.wishlist => l10n.navWishlist,
  MainTab.profile => l10n.navProfile,
};

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final MainTab tab;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  static const double _width = 72;
  static const double _pillWidth = 48;
  static const double _pillHeight = 32;
  static const double _pillRadius = 6;
  static const Duration _duration = Duration(milliseconds: 200);

  String get _icon => switch (tab) {
    MainTab.home => Assets.iconsHome,
    MainTab.explore => Assets.iconsCategories,
    MainTab.cart => Assets.iconsCart,
    MainTab.wishlist => Assets.iconsHeart,
    MainTab.profile => Assets.iconsUser,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = tabLabel(tab, context.l10n);
    final motion = context.motion(_duration);
    return Semantics(
      button: true,
      selected: selected,
      label: badge == null ? label : context.l10n.navCartCount(label, badge!),
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
        child: SizedBox(
          width: _width.w,
          child: Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: AppSpacing.s6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs.h,
              children: <Widget>[
                AnimatedContainer(
                  duration: motion,
                  width: _pillWidth.w,
                  height: _pillHeight.h,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primaryContainer
                        : colors.primaryContainer.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(_pillRadius.r),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        _icon,
                        width: AppSizes.iconMd.r,
                        height: AppSizes.iconMd.r,
                        colorFilter: ColorFilter.mode(
                          selected
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (badge case final count?)
                        PositionedDirectional(
                          start: 28.w,
                          top: 0,
                          child: _Badge(count: count),
                        ),
                    ],
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: selected
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
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

/// The cart count, ringed in the bar's colour; it pops when it changes.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  static const double _size = 18;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedSwitcher(
      duration: context.motion(const Duration(milliseconds: 200)),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey<int>(count),
        constraints: BoxConstraints(minWidth: _size.r, minHeight: _size.r),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.commerceSale,
          borderRadius: BorderRadius.circular(_size.r / 2),
          border: Border.all(
            color: context.colors.surfaceContainerLowest,
            width: _ring,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Text(
          '$count',
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: colors.commerceOnSale,
          ),
        ),
      ),
    );
  }
}
