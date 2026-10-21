import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_logo_mark.dart';
import 'package:core/theme/app_brand_type.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/auth/presentation/view/widgets/skip_button.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The logo and wordmark, with Skip at the end.
class SignInTopBar extends StatelessWidget {
  const SignInTopBar({required this.onSkip, super.key});

  final VoidCallback onSkip;

  static const double _height = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: _height.h,
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Row(
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                AppLogoMark(size: AppSizes.iconLg.r),
                Text(
                  context.l10n.brandWordmark,
                  style: AppBrandType.wordmarkCompact
                      .style((v) => v.sp)
                      .copyWith(color: colors.onSurface),
                ),
              ],
            ),
          ),
          const Spacer(),
          SkipButton(onPressed: onSkip),
        ],
      ),
    );
  }
}
