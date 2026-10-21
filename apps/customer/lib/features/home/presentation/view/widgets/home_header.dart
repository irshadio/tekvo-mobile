import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/presentation/widgets/count_badge.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/presentation/view/widgets/home_search_bar.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The pinned top of the home tab: where orders go, notifications, the cart
/// with its count, and search.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.deliveryArea,
    required this.deliveryEta,
    required this.cartCount,
    required this.onNotifications,
    required this.onCart,
    required this.onSearch,
    super.key,
  });

  final String deliveryArea;
  final String deliveryEta;
  final int cartCount;
  final VoidCallback onNotifications;
  final VoidCallback onCart;
  final VoidCallback onSearch;

  /// The header's height below the status bar, in design pixels.
  static const double height = 126;

  static const double _rowHeight = 46;
  static const double _cartWidth = 48;
  static const double _badgeStart = 28;
  static const double _truck = 14;
  static const double _chevron = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppEffects.pinnedHeader,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: context.viewPadding.top + AppSpacing.sm.h,
          bottom: AppSpacing.md.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm.h,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: SizedBox(
                height: _rowHeight.h,
                child: Row(
                  spacing: 10.w,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppSpacing.xxs.h,
                        children: <Widget>[
                          Row(
                            spacing: AppSpacing.xs.w,
                            children: <Widget>[
                              SvgPicture.asset(
                                Assets.iconsTruck,
                                width: _truck.r,
                                height: _truck.r,
                                colorFilter: ColorFilter.mode(
                                  colors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  l10n.homeDeliverTo(deliveryEta),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelSmall?.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: AppSpacing.xs.w,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  deliveryArea,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleMedium,
                                ),
                              ),
                              SvgPicture.asset(
                                Assets.iconsChevronDown,
                                width: _chevron.r,
                                height: _chevron.r,
                                colorFilter: ColorFilter.mode(
                                  colors.onSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: Assets.iconsBell,
                      iconSize: AppSizes.iconSm + 2,
                      tooltip: l10n.homeNotifications,
                      onPressed: onNotifications,
                    ),
                    SizedBox(
                      width: _cartWidth.w,
                      height: _rowHeight.h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          PositionedDirectional(
                            start: 0,
                            top: AppSpacing.xxs.h,
                            child: AppIconButton(
                              icon: Assets.iconsCart,
                              iconSize: AppSizes.iconSm + 2,
                              tooltip: l10n.homeCart(cartCount),
                              onPressed: onCart,
                            ),
                          ),
                          if (cartCount > 0)
                            PositionedDirectional(
                              start: _badgeStart.w,
                              top: 0,
                              child: ExcludeSemantics(
                                child: CountBadge(
                                  count: cartCount,
                                  ring: colors.surface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: HomeSearchBar(onTap: onSearch),
            ),
          ],
        ),
      ),
    );
  }
}
