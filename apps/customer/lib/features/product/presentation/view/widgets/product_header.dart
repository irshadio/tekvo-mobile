import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/presentation/widgets/count_badge.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The product page's pinned bar: back, search, share and the cart with
/// its count.
class ProductHeader extends StatelessWidget {
  const ProductHeader({
    required this.cartCount,
    required this.onSearch,
    required this.onShare,
    required this.onCart,
    super.key,
  });

  final int cartCount;
  final VoidCallback onSearch;
  final VoidCallback onShare;
  final VoidCallback onCart;

  static const double _icon = 22;
  static const double _badgeEnd = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    Widget button(String icon, String tooltip, VoidCallback onPressed) =>
        AppIconButton(
          icon: icon,
          tooltip: tooltip,
          onPressed: onPressed,
          variant: AppIconButtonVariant.plain,
          iconSize: _icon,
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm.w,
          context.viewPadding.top + AppSpacing.xs.h,
          AppSpacing.sm.w,
          AppSpacing.xs.h + 1,
        ),
        child: Row(
          spacing: AppSpacing.xs.w,
          children: <Widget>[
            AppIconButton(
              icon: Assets.iconsChevronLeft,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              variant: AppIconButtonVariant.plain,
              iconSize: AppSizes.iconMd,
            ),
            const Spacer(),
            button(Assets.iconsSearch, l10n.productSearch, onSearch),
            button(Assets.iconsShare, l10n.productShare, onShare),
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                button(Assets.iconsCart, l10n.homeCart(cartCount), onCart),
                if (cartCount > 0)
                  PositionedDirectional(
                    end: _badgeEnd.w,
                    top: AppSpacing.xs.h,
                    child: ExcludeSemantics(
                      child: CountBadge(
                        count: cartCount,
                        ring: colors.surfaceContainerLowest,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
