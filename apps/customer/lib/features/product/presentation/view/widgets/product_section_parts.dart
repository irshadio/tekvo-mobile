import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A white band of the product page with its parts stacked [spacing]
/// apart.
class ProductSection extends StatelessWidget {
  const ProductSection({
    required this.spacing,
    required this.children,
    super.key,
  });

  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerLowest,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg.w,
        vertical: AppSpacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.h,
        children: children,
      ),
    ),
  );
}

/// A bundled icon tinted [color]; [flip] mirrors it right to left.
class ProductIcon extends StatelessWidget {
  const ProductIcon(
    this.asset, {
    required this.size,
    required this.color,
    this.flip = false,
    super.key,
  });

  final String asset;
  final double size;
  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: flip && Directionality.of(context) == TextDirection.rtl,
    child: SvgPicture.asset(
      asset,
      width: size.r,
      height: size.r,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}

/// Five stars, the first [filled] in the rating colour.
class ProductStars extends StatelessWidget {
  const ProductStars({required this.filled, this.size = 14, super.key});

  final int filled;
  final double size;

  static const int _count = 5;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxs.w,
      children: <Widget>[
        for (var i = 0; i < _count; i++)
          ProductIcon(
            Assets.iconsStarFilled,
            size: size,
            color: i < filled
                ? context.appColors.commerceRating
                : context.colors.outlineVariant,
          ),
      ],
    ),
  );
}

/// A square tick box that fills with the brand colour when [checked].
class ProductCheckbox extends StatelessWidget {
  const ProductCheckbox({required this.checked, super.key});

  final bool checked;

  static const double _size = 20;
  static const double _tick = 14;
  static const double _border = 1.5;
  static const Duration _fill = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: context.motion(_fill),
      width: _size.r,
      height: _size.r,
      decoration: BoxDecoration(
        color: checked ? colors.primary : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xs.r),
        border: Border.all(
          color: checked ? colors.primary : colors.outline,
          width: _border,
        ),
      ),
      child: AnimatedScale(
        duration: context.motion(_fill),
        scale: checked ? 1 : 0,
        child: Center(
          child: ProductIcon(
            Assets.iconsCheck,
            size: _tick,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// A full-width outlined button, such as Read all reviews.
class ProductOutlineButton extends StatelessWidget {
  const ProductOutlineButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  static const double _outline = 1.5;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: Size.fromHeight(AppSizes.controlMd.h),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: context.colors.onSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius.r),
      ),
      side: BorderSide(color: context.colors.outlineVariant, width: _outline),
    ),
    child: Text(label),
  );
}
