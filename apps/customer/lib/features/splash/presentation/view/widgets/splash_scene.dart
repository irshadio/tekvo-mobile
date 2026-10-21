import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_brand_type.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_frame.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_glow.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_loader.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The splash drawn at one [frame], on the 393 x 852 design canvas.
class SplashScene extends StatelessWidget {
  const SplashScene({required this.frame, super.key});

  final SplashFrame frame;

  /// Design positions that do not move between frames.
  static const double glowPrimaryStart = -14;
  static const double glowPrimaryDiameter = 420;
  static const double glowPrimaryBlur = 140;
  static const double glowAccentDiameter = 180;
  static const double glowAccentBlur = 100;
  static const double loaderTop = 740;
  static const double footerTop = 776;

  @override
  Widget build(BuildContext context) {
    final brand = context.brandColors;
    final text = context.textTheme;
    return ColoredBox(
      color: brand.background,
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            start: glowPrimaryStart.w,
            top: frame.glowPrimaryTop.h,
            child: Opacity(
              opacity: frame.glowPrimaryOpacity,
              child: SplashGlow(
                color: brand.glowPrimary,
                diameter: glowPrimaryDiameter,
                blur: glowPrimaryBlur,
              ),
            ),
          ),
          PositionedDirectional(
            start: frame.glowAccentStart.w,
            top: frame.glowAccentTop.h,
            child: Opacity(
              opacity: frame.glowAccentOpacity,
              child: SplashGlow(
                color: brand.glowAccent,
                diameter: glowAccentDiameter,
                blur: glowAccentBlur,
              ),
            ),
          ),
          _centred(
            top: frame.logoTop,
            child: ExcludeSemantics(
              child: SvgPicture.asset(
                brand.logoMark,
                width: frame.logoSize.r,
                height: frame.logoSize.r,
              ),
            ),
          ),
          _centred(
            top: frame.wordmarkTop,
            opacity: frame.wordmarkOpacity,
            child: Text(
              context.l10n.brandWordmark,
              textAlign: TextAlign.center,
              style: AppBrandType.wordmark
                  .style((v) => v.sp)
                  .copyWith(color: brand.wordmark),
            ),
          ),
          _centred(
            top: frame.taglineTop,
            opacity: frame.taglineOpacity,
            child: Text(
              context.l10n.splashTagline,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: brand.tagline),
            ),
          ),
          _centred(
            top: loaderTop,
            opacity: frame.loaderOpacity,
            child: SplashLoader(
              trackColor: brand.loaderTrack,
              barColor: brand.loaderBar,
            ),
          ),
          _centred(
            top: footerTop,
            opacity: frame.footerOpacity,
            child: Text(
              context.l10n.splashFooter,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: brand.footer),
            ),
          ),
        ],
      ),
    );
  }

  /// [child] centred across the width, [top] design pixels down.
  Widget _centred({
    required double top,
    required Widget child,
    double opacity = 1,
  }) {
    return Positioned(
      top: top.h,
      left: 0,
      right: 0,
      child: Center(
        child: Opacity(opacity: opacity, child: child),
      ),
    );
  }
}
