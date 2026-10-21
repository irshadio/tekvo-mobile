import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The search field's look; tapping anywhere opens search, where typing
/// happens.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({required this.onTap, super.key});

  final VoidCallback onTap;

  static const double _height = 52;
  static const double _icon = 22;
  static const double _filter = 40;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: _height.h,
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.lg.w,
            end: AppSpacing.s6.w,
          ),
          child: Row(
            spacing: _gap.w,
            children: <Widget>[
              SvgPicture.asset(
                Assets.iconsSearch,
                width: _icon.r,
                height: _icon.r,
                colorFilter: ColorFilter.mode(
                  colors.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              Expanded(
                child: Text(
                  l10n.homeSearchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              AppIconButton(
                icon: Assets.iconsFilter,
                tooltip: l10n.homeFilters,
                variant: AppIconButtonVariant.filled,
                size: _filter,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
