import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/permissions/presentation/view/widgets/permission_benefit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The benefits of a permission as rows in a tinted card, divided by lines.
class PermissionBenefitsCard extends StatelessWidget {
  const PermissionBenefitsCard({required this.benefits, super.key});

  final List<PermissionBenefit> benefits;

  static const double _icon = 20;
  static const double _sidePadding = 14;
  static const double _gap = 12;
  static const double _lineGap = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (index, benefit) in benefits.indexed)
            DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Padding(
                // A divided row keeps one more pixel above, for its line.
                padding: EdgeInsets.fromLTRB(
                  _sidePadding.w,
                  (index == 0 ? AppSpacing.md : AppSpacing.md + 1).h,
                  _sidePadding.w,
                  AppSpacing.md.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: _gap.w,
                  children: <Widget>[
                    SvgPicture.asset(
                      benefit.icon,
                      width: _icon.r,
                      height: _icon.r,
                      colorFilter: ColorFilter.mode(
                        colors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: _lineGap.h,
                        children: <Widget>[
                          Text(
                            benefit.title,
                            style: text.titleSmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            benefit.detail,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
