import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A section's title, anything that sits beside it, and See all.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onSeeAll;

  /// Drawn before the title, such as the flash deals bolt.
  final Widget? leading;

  /// Drawn after the title, such as the flash deals countdown.
  final Widget? trailing;

  static const double _height = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return SizedBox(
      height: _height.h,
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          ?leading,
          Expanded(
            child: Row(
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                Flexible(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(AppRadius.xs.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xxs.w,
              children: <Widget>[
                Text(
                  context.l10n.homeSeeAll,
                  style: text.labelLarge?.copyWith(color: colors.primary),
                ),
                Transform.flip(
                  flipX: Directionality.of(context) == TextDirection.rtl,
                  child: SvgPicture.asset(
                    Assets.iconsChevronRight,
                    width: AppSizes.iconXs.r,
                    height: AppSizes.iconXs.r,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
