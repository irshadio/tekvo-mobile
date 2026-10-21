import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The dark "Added to cart" note above the bottom bar, with a way to the
/// cart.
class AddedToast extends StatelessWidget {
  const AddedToast({
    required this.productName,
    required this.onViewCart,
    super.key,
  });

  final String productName;
  final VoidCallback onViewCart;

  static const double _radius = 10;
  static const double _badge = 28;
  static const double _padding = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = context.appColors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _padding.w,
          vertical: AppSpacing.md.h,
        ),
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(_radius.r),
          boxShadow: AppEffects.toast,
        ),
        child: Row(
          spacing: AppSpacing.md.w,
          children: <Widget>[
            Container(
              width: _badge.r,
              height: _badge.r,
              decoration: BoxDecoration(
                color: status.statusSuccess,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                Assets.iconsCheckLarge,
                colorFilter: ColorFilter.mode(
                  status.statusOnSuccess,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 1.h,
                children: <Widget>[
                  Text(
                    l10n.productAddedToCart,
                    style: text.titleSmall?.copyWith(
                      color: colors.onInverseSurface,
                    ),
                  ),
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: colors.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewCart,
              style: TextButton.styleFrom(
                foregroundColor: colors.inversePrimary,
                textStyle: text.labelLarge,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.productViewCart),
            ),
          ],
        ),
      ),
    );
  }
}
