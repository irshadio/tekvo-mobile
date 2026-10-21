import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The outlined round back button of a screen's top bar. Pops the route
/// unless [onPressed] is given; the chevron turns in right-to-left text.
class AppBackButton extends StatelessWidget {
  const AppBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  static const double size = 44;
  static const double _border = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      style: IconButton.styleFrom(
        fixedSize: Size.square(size.r),
        minimumSize: Size.square(size.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
        side: BorderSide(color: colors.outlineVariant, width: _border),
      ),
      icon: Transform.flip(
        flipX: Directionality.of(context) == TextDirection.rtl,
        child: SvgPicture.asset(
          Assets.iconsChevronLeft,
          width: AppSizes.iconMd.r,
          height: AppSizes.iconMd.r,
          colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
        ),
      ),
    );
  }
}
