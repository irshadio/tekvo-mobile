import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_dots.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The controls under the pages: dots and Next, or on the last page centred
/// dots over Get started and Continue as guest.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    required this.count,
    required this.position,
    required this.onNext,
    required this.onFinish,
    super.key,
  });

  final int count;
  final double position;
  final VoidCallback onNext;

  /// Get started and Continue as guest, or null while finishing is saved.
  final VoidCallback? onFinish;

  static const double _nextWidth = 140;
  static const double _guestHeight = 40;

  /// The last page's footer frame; its guest button overhangs it, as in the
  /// design.
  static const double _lastHeight = 100;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dots = OnboardingDots(count: count, position: position);
    final isLast = position.round() == count - 1;
    final child = isLast
        ? SizedBox(
            key: const ValueKey<bool>(true),
            height: _lastHeight.h,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: Column(
                spacing: 10.h,
                children: <Widget>[
                  dots,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onFinish,
                      child: Text(l10n.onboardingGetStarted),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: _guestHeight.h,
                    child: TextButton(
                      onPressed: onFinish,
                      child: Text(l10n.onboardingContinueAsGuest),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Row(
            key: const ValueKey<bool>(false),
            children: <Widget>[
              dots,
              const Spacer(),
              SizedBox(
                width: _nextWidth.w,
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(l10n.onboardingNext),
                ),
              ),
            ],
          );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[...previous, ?current],
        ),
        child: child,
      ),
    );
  }
}
