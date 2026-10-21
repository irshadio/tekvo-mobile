import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A search field's look; tapping anywhere opens search, where typing
/// happens. [trailing] sits at the end, such as a filter button.
class SearchButton extends StatelessWidget {
  const SearchButton({
    required this.hint,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final String hint;
  final VoidCallback onTap;
  final Widget? trailing;

  static const double _height = 52;
  static const double _icon = 22;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
