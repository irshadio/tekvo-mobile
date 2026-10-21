import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// How an [AppIconButton] is drawn.
enum AppIconButtonVariant {
  /// A hairline ring on the page.
  outline,

  /// The primary colour with the icon in its on-colour.
  filled,

  /// White over a photo.
  glass,

  /// The icon alone, as in a top bar.
  plain,
}

/// The design system's round icon button, [size] across with a 48 tap area
/// around it.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconButtonVariant.outline,
    this.size = AppSizes.touchTargetMin - 4,
    this.iconSize = AppSizes.iconSm,
    this.iconColor,
    super.key,
  });

  /// An `Assets` icon.
  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;

  /// Overrides the variant's icon colour, such as a filled heart.
  final Color? iconColor;

  static const double _ring = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (variant) {
      AppIconButtonVariant.outline => (null, colors.onSurface),
      AppIconButtonVariant.filled => (colors.primary, colors.onPrimary),
      AppIconButtonVariant.glass => (
        colors.surfaceContainerLowest,
        colors.onSurface,
      ),
      AppIconButtonVariant.plain => (null, colors.onSurface),
    };
    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: background,
        fixedSize: Size.square(size.r),
        minimumSize: Size.square(size.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
        side: variant == AppIconButtonVariant.outline
            ? BorderSide(color: colors.outlineVariant, width: _ring)
            : null,
      ),
      icon: SvgPicture.asset(
        icon,
        width: iconSize.r,
        height: iconSize.r,
        colorFilter: ColorFilter.mode(
          iconColor ?? foreground,
          BlendMode.srcIn,
        ),
      ),
    );
    if (variant != AppIconButtonVariant.glass) return button;
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppEffects.glassButton,
      ),
      child: button,
    );
  }
}
