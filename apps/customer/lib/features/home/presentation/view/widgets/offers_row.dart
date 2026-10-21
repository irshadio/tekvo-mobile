import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Two shop-wide offers side by side, each with a tilted photo.
class OffersRow extends StatelessWidget {
  const OffersRow({required this.offers, super.key});

  final List<Offer> offers;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.md.w,
      children: <Widget>[
        for (final offer in offers)
          Expanded(
            child: _OfferCard(offer: offer),
          ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final Offer offer;

  static const double _height = 140;
  static const double _radius = 12;
  static const double _padding = 14;
  static const double _chip = 28;
  static const double _chipIcon = 16;
  static const double _titleWidth = 120;
  static const double _detailWidth = 84;
  static const double _photo = 60;
  static const double _photoEnd = 14;
  static const double _photoTop = 74;
  static const double _photoTilt = 0.1396;
  static const double _detailOpacity = 0.85;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final colors = context.appColors;
    final text = context.textTheme;
    final (background, foreground, icon) = switch (offer.style) {
      OfferStyle.tradeIn => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Assets.iconsReturns,
      ),
      OfferStyle.instalments => (
        colors.commerceDeal,
        colors.commerceOnDeal,
        Assets.iconsTag,
      ),
    };
    return Container(
      height: _height.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_radius.r),
      ),
      child: Stack(
        children: <Widget>[
          // The words may run past the card's foot, as designed.
          OverflowBox(
            alignment: AlignmentDirectional.topStart,
            maxHeight: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(_padding.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs.h,
                children: <Widget>[
                  Container(
                    width: _chip.r,
                    height: _chip.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: foreground,
                      borderRadius: BorderRadius.circular(AppSpacing.s6.r),
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: _chipIcon.r,
                      height: _chipIcon.r,
                      colorFilter: ColorFilter.mode(
                        background,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  SizedBox(
                    width: _titleWidth.w,
                    child: Text(
                      offer.title,
                      style: text.titleSmall?.copyWith(color: foreground),
                    ),
                  ),
                  SizedBox(
                    width: _detailWidth.w,
                    child: Text(
                      offer.detail,
                      style: text.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: _detailOpacity),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: _photoEnd.w,
            top: _photoTop.h,
            child: Transform.rotate(
              angle: _photoTilt,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius.r - 2),
                child: Image.asset(
                  offer.image,
                  width: _photo.r,
                  height: _photo.r,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
