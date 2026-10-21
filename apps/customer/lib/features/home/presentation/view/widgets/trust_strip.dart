import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/money.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The shop's promises as chips in a row that scrolls sideways.
class TrustStrip extends StatelessWidget {
  const TrustStrip({
    required this.freeDeliveryOver,
    required this.city,
    super.key,
  });

  final Money freeDeliveryOver;
  final String city;

  static const double _height = 32;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(String, String)>[
      (
        Assets.iconsTruck,
        l10n.homeFreeDelivery(context.money(freeDeliveryOver)),
      ),
      (Assets.iconsBolt, l10n.homeSameDay(city)),
      (Assets.iconsShield, l10n.homeWarranty),
      (Assets.iconsReturns, l10n.homeReturns),
    ];
    return SizedBox(
      height: _height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
        itemBuilder: (context, index) =>
            _TrustChip(icon: items[index].$1, label: items[index].$2),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final String icon;
  final String label;

  static const double _icon = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s6.w,
        children: <Widget>[
          SvgPicture.asset(
            icon,
            width: _icon.r,
            height: _icon.r,
            colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
          ),
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}
