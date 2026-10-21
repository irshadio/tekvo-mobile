import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A rule either side of a short label.
class OrDivider extends StatelessWidget {
  const OrDivider({required this.label, super.key});

  final String label;

  static const double _height = 20;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height.h,
      child: Row(
        spacing: AppSpacing.md.w,
        children: <Widget>[
          const Expanded(child: Divider()),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
