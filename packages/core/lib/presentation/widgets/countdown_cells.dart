import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Hours, minutes and seconds of [remaining], each in its own cell.
class CountdownCells extends StatelessWidget {
  const CountdownCells({
    required this.remaining,
    required this.cellColor,
    required this.textColor,
    this.separatorColor,
    super.key,
  });

  final Duration remaining;
  final Color cellColor;
  final Color textColor;

  /// Draws `:` between the cells in this colour, when given.
  final Color? separatorColor;

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelMedium;
    final parts = <String>[
      _two(remaining.inHours),
      _two(remaining.inMinutes % 60),
      _two(remaining.inSeconds % 60),
    ];
    final separator = separatorColor;
    return Semantics(
      label: parts.join(':'),
      excludeSemantics: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: separator == null ? AppSpacing.s6.w : AppSpacing.xs.w,
          children: <Widget>[
            for (var i = 0; i < parts.length; i++) ...<Widget>[
              if (i > 0 && separator != null)
                Text(':', style: style?.copyWith(color: separator)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s6.w,
                  vertical: AppSpacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(AppRadius.xs.r),
                ),
                child: Text(parts[i], style: style?.copyWith(color: textColor)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
