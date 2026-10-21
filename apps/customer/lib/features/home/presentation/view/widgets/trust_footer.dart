import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The shop's three promises at the foot of the page.
class TrustFooter extends StatelessWidget {
  const TrustFooter({super.key});

  static const double _radius = 12;
  static const double _badge = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final items = <(String, String, String)>[
      (
        Assets.iconsTruck,
        l10n.homeFooterDelivery,
        l10n.homeFooterDeliveryDetail,
      ),
      (Assets.iconsShield, l10n.homeWarranty, l10n.homeFooterWarrantyDetail),
      (
        Assets.iconsReturns,
        l10n.homeFooterReturns,
        l10n.homeFooterReturnsDetail,
      ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_radius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (icon, title, detail) in items)
            Expanded(
              child: Column(
                spacing: AppSpacing.s6.h,
                children: <Widget>[
                  Container(
                    width: _badge.r,
                    height: _badge.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: AppSizes.iconSm.r,
                      height: AppSizes.iconSm.r,
                      colorFilter: ColorFilter.mode(
                        colors.onPrimaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: text.labelLarge,
                  ),
                  Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
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
