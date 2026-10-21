import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A white chip with a tinted icon tile and a label, floating over a photo.
class OnboardingChipTile extends StatelessWidget {
  const OnboardingChipTile({
    required this.icon,
    required this.label,
    super.key,
  });

  final String icon;
  final String label;

  static const double _radius = 10;
  static const double _tile = 24;
  static const double _tileRadius = 6;
  static const double _glyph = 14;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_radius.r),
        boxShadow: AppEffects.floatingChip,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 12.w, 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap.w,
          children: <Widget>[
            Container(
              width: _tile.r,
              height: _tile.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(_tileRadius.r),
              ),
              child: SvgPicture.asset(
                icon,
                width: _glyph.r,
                height: _glyph.r,
                colorFilter: ColorFilter.mode(
                  colors.onPrimaryContainer,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
