import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A tab whose screen is not built yet: its name and a short note.
class MainPlaceholderPage extends StatelessWidget {
  const MainPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.sm.h,
            children: <Widget>[
              Text(title, style: text.titleLarge),
              Text(
                context.l10n.mainComingSoon,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
