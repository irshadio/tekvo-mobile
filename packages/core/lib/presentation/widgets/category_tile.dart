import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A category as an icon on a tinted square with its name under it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.width = 72,
    super.key,
  });

  /// An `Assets` icon.
  final String icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  static const double _tile = 60;
  static const double _icon = 26;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: width.w,
          child: Column(
            spacing: AppSpacing.sm.h,
            children: <Widget>[
              Container(
                width: _tile.r,
                height: _tile.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: radius,
                ),
                child: SvgPicture.asset(
                  icon,
                  width: _icon.r,
                  height: _icon.r,
                  colorFilter: ColorFilter.mode(
                    colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
