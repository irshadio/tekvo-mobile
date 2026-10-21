import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A dot per page, the current one stretched into a pill.
class PageDots extends StatelessWidget {
  const PageDots({required this.count, required this.current, super.key});

  final int count;
  final int current;

  static const double _dot = 8;
  static const double _active = 24;
  static const Duration _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s6.w,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: context.motion(_duration),
              curve: Curves.easeOut,
              width: (i == current ? _active : _dot).w,
              height: _dot.h,
              decoration: BoxDecoration(
                color: i == current ? colors.primary : colors.outlineVariant,
                borderRadius: BorderRadius.circular(_dot.h / 2),
              ),
            ),
        ],
      ),
    );
  }
}
