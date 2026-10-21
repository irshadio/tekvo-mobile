import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One-choice filter chips in a row that scrolls sideways; the chosen one
/// is filled in the inverse colours.
class FilterChips extends StatelessWidget {
  const FilterChips({
    required this.labels,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  static const double _height = 36;
  static const double _radius = 6;
  static const double _border = 1.5;
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: _height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
        itemBuilder: (context, index) {
          final on = index == selected;
          final radius = BorderRadius.circular(_radius.r);
          return Semantics(
            selected: on,
            button: true,
            child: InkWell(
              onTap: () => onSelect(index),
              borderRadius: radius,
              child: AnimatedContainer(
                duration: context.motion(_duration),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on
                      ? colors.inverseSurface
                      : colors.surfaceContainerLowest,
                  borderRadius: radius,
                  border: Border.all(
                    color: on ? colors.inverseSurface : colors.outlineVariant,
                    width: _border,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: context.textTheme.labelLarge?.copyWith(
                    color: on ? colors.onInverseSurface : colors.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
