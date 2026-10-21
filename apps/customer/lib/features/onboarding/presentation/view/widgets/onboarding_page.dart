import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_chip_tile.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_slide.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One introduction page: the photo on its circle with two chips, then the
/// kicker, title and body. Design pixels on the 393-wide canvas.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.slide, super.key});

  final OnboardingSlide slide;

  static const double heroHeight = 400;
  static const double _circle = 340;
  static const double _circleTop = 20;
  static const double _imageWidth = 230;
  static const double _imageHeight = 300;
  static const double _imageTop = 40;
  static const double _imageRadius = 24;
  static const double _leadingChipTop = 70;
  static const double _trailingChipTop = 290;
  static const double _kickerTracking = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: heroHeight.h,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Positioned(
                top: _circleTop.h,
                child: Container(
                  width: _circle.r,
                  height: _circle.r,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: _imageTop.h,
                child: Container(
                  width: _imageWidth.w,
                  height: _imageHeight.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_imageRadius.r),
                    boxShadow: AppEffects.raisedImage,
                    image: DecorationImage(
                      image: AssetImage(slide.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: AppSpacing.xl.w,
                top: _leadingChipTop.h,
                child: OnboardingChipTile(
                  icon: slide.leading.icon,
                  label: slide.leading.label(l10n),
                ),
              ),
              PositionedDirectional(
                end: AppSpacing.xl.w,
                top: _trailingChipTop.h,
                child: OnboardingChipTile(
                  icon: slide.trailing.icon,
                  label: slide.trailing.label(l10n),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppSpacing.xl.h,
            AppSpacing.xl.w,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.h,
            children: <Widget>[
              Text(
                slide.kicker(l10n).toUpperCase(),
                style: text.labelMedium?.copyWith(
                  color: colors.primary,
                  letterSpacing: _kickerTracking.sp,
                ),
              ),
              Text(
                slide.title(l10n),
                style: text.headlineMedium?.copyWith(color: colors.onSurface),
              ),
              Text(
                slide.body(l10n),
                style: text.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
