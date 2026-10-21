import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An outlined "Continue with …" button with the provider's logo.
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.logo,
    required this.label,
    required this.onPressed,
    this.tintLogo = false,
    super.key,
  });

  final String logo;
  final String label;
  final VoidCallback onPressed;

  /// Draws a one-colour logo in the text colour, so it shows in dark mode.
  final bool tintLogo;

  static const double _height = 52;
  static const double _border = 1.5;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(_height.h),
        backgroundColor: colors.surfaceContainerLowest,
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outlineVariant, width: _border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _gap.w,
        children: <Widget>[
          SvgPicture.asset(
            logo,
            width: AppSizes.iconSm.r,
            height: AppSizes.iconSm.r,
            colorFilter: tintLogo
                ? ColorFilter.mode(colors.onSurface, BlendMode.srcIn)
                : null,
          ),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
