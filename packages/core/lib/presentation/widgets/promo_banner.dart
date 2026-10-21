import 'dart:ui';

import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/promo.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/countdown_cells.dart';
import 'package:core/theme/app_promo_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A promotion: its words on the left and its photo on the right, fading
/// into the banner's colour. A flash sale counts down [remaining].
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    required this.promo,
    required this.onTap,
    this.remaining = Duration.zero,
    super.key,
  });

  final Promo promo;
  final VoidCallback onTap;
  final Duration remaining;

  static const double _photoWidth = 190;
  static const double _textWidth = 200;
  static const double _launchTextWidth = 190;
  static const double _radius = 10;
  static const double _launchRadius = 16;

  @override
  Widget build(BuildContext context) {
    final deal = context.appColors.commerceDeal;
    final launch = promo.style == PromoStyle.launch;
    final background = promo.style == PromoStyle.newArrival
        ? deal
        : AppPromoColors.night;
    final radius = BorderRadius.circular(
      (launch ? _launchRadius : _radius).r,
    );
    return Semantics(
      button: true,
      label: promo.title,
      child: Material(
        color: background,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final photoStart = constraints.maxWidth - _photoWidth.w;
              return Stack(
                children: <Widget>[
                  if (promo.style != PromoStyle.newArrival)
                    _Glow(launch: launch),
                  PositionedDirectional(
                    end: 0,
                    top: 0,
                    bottom: 0,
                    width: _photoWidth.w,
                    child: Image.asset(promo.image, fit: BoxFit.cover),
                  ),
                  PositionedDirectional(
                    start: photoStart,
                    top: 0,
                    bottom: 0,
                    width: (launch ? 90 : 100).w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                          colors: <Color>[
                            background,
                            background.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: AppSpacing.s20.w,
                    top: (launch ? 22 : 20).h,
                    width: (launch ? _launchTextWidth : _textWidth).w,
                    child: ExcludeSemantics(child: _words(context)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _words(BuildContext context) {
    final text = context.textTheme;
    final colors = context.appColors;
    final onBanner = promo.style == PromoStyle.newArrival
        ? colors.commerceOnDeal
        : AppPromoColors.onNight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s6.h,
      children: <Widget>[
        if (promo.style == PromoStyle.launch)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: 3.h,
            ),
            decoration: BoxDecoration(
              color: colors.commerceDeal,
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
            ),
            child: Text(
              promo.eyebrow,
              style: text.labelSmall?.bold.copyWith(
                color: colors.commerceOnDeal,
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs.w,
            children: <Widget>[
              _icon(
                promo.style == PromoStyle.flashSale
                    ? Assets.iconsBolt
                    : Assets.iconsTag,
                promo.style == PromoStyle.flashSale
                    ? colors.commerceDeal
                    : onBanner,
              ),
              Text(
                promo.eyebrow,
                style: text.labelSmall?.copyWith(
                  color: promo.style == PromoStyle.flashSale
                      ? colors.commerceDeal
                      : onBanner,
                ),
              ),
            ],
          ),
        Text(
          promo.title,
          style:
              (promo.style == PromoStyle.launch
                      ? text.headlineSmall
                      : text.titleLarge)
                  ?.bold
                  .copyWith(color: onBanner),
        ),
        if (promo.subtitle case final subtitle?)
          Text(
            subtitle,
            style: text.bodySmall?.copyWith(
              color: AppPromoColors.onNightMuted,
            ),
          ),
        if (promo.style == PromoStyle.flashSale)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.s6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s6.w,
              children: <Widget>[
                _icon(Assets.iconsClock, onBanner, size: 16),
                CountdownCells(
                  remaining: remaining,
                  cellColor: AppPromoColors.onNightCell,
                  textColor: onBanner,
                ),
              ],
            ),
          )
        else if (promo.action case final action?)
          Padding(
            padding: EdgeInsets.only(
              top: promo.style == PromoStyle.launch ? 0 : AppSpacing.s6.h,
            ),
            child: _ActionChip(
              label: action,
              background: promo.style == PromoStyle.launch
                  ? AppPromoColors.onNight
                  : colors.commerceOnDeal,
              foreground: promo.style == PromoStyle.launch
                  ? AppPromoColors.night
                  : colors.commerceDeal,
              radius: promo.style == PromoStyle.launch
                  ? AppRadius.sm
                  : AppSpacing.s6,
            ),
          ),
      ],
    );
  }

  static Widget _icon(String asset, Color color, {double size = 14}) =>
      SvgPicture.asset(
        asset,
        width: size.r,
        height: size.r,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// The blurred brand-blue light behind a night banner's words.
class _Glow extends StatelessWidget {
  const _Glow({required this.launch});

  final bool launch;

  @override
  Widget build(BuildContext context) {
    final size = (launch ? 260 : 220).r;
    final sigma = launch ? 35.0 : 30.0;
    return PositionedDirectional(
      start: (launch ? -70 : -60).w,
      top: 40.h,
      width: size,
      height: size,
      child: Opacity(
        opacity: launch ? 0.7 : 0.55,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.decal,
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppPromoColors.glow,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// The banner's call to action: a label and a chevron on a solid chip.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.radius,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs.w,
        children: <Widget>[
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(color: foreground),
          ),
          Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: PromoBanner._icon(Assets.iconsChevronRight, foreground),
          ),
        ],
      ),
    );
  }
}
