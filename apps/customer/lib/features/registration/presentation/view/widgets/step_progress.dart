import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A bar per sign-up step, filled up to [done].
class StepProgress extends StatelessWidget {
  const StepProgress({required this.steps, required this.done, super.key});

  final int steps;
  final int done;

  static const double _height = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      value: '$done/$steps',
      child: Row(
        spacing: AppSpacing.s6.w,
        children: <Widget>[
          for (var i = 0; i < steps; i++)
            Expanded(
              child: Container(
                height: _height.h,
                decoration: BoxDecoration(
                  color: i < done
                      ? colors.primary
                      : colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(_height.h / 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
