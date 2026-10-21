import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A count on an icon, such as the cart's items, ringed in [ring] (the
/// colour behind it); it pops when the count changes.
class CountBadge extends StatelessWidget {
  const CountBadge({required this.count, required this.ring, super.key});

  final int count;
  final Color ring;

  static const double _size = 18;
  static const double _ringWidth = 2;
  static const Duration _pop = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedSwitcher(
      duration: context.motion(_pop),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey<int>(count),
        constraints: BoxConstraints(minWidth: _size.r, minHeight: _size.r),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.commerceSale,
          borderRadius: BorderRadius.circular(_size.r / 2),
          border: Border.all(
            color: ring,
            width: _ringWidth,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Text(
          '$count',
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: colors.commerceOnSale,
          ),
        ),
      ),
    );
  }
}
