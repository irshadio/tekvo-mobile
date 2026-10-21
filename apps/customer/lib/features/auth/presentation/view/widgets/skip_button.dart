import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The tinted Skip button at the end of a sign-in top bar.
class SkipButton extends StatelessWidget {
  const SkipButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  static const double _radius = 6;
  static const double _paddingX = 14;
  static const double _paddingY = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: colors.surfaceContainerHigh,
        foregroundColor: colors.onSurface,
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(
          horizontal: _paddingX.w,
          vertical: _paddingY.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius.r),
        ),
      ),
      child: Text(context.l10n.signInSkip),
    );
  }
}
