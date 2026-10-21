import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_promo_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/deal_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Category deals as photo tiles, two to a row.
class DealsGrid extends StatelessWidget {
  const DealsGrid({required this.tiles, required this.onTile, super.key});

  final List<DealTile> tiles;
  final ValueChanged<DealTile> onTile;

  static const int _perRow = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.md.h,
      children: <Widget>[
        for (var start = 0; start < tiles.length; start += _perRow)
          Row(
            spacing: AppSpacing.md.w,
            children: <Widget>[
              for (final tile in tiles.skip(start).take(_perRow))
                Expanded(
                  child: _Tile(tile: tile, onTap: () => onTile(tile)),
                ),
            ],
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile, required this.onTap});

  final DealTile tile;
  final VoidCallback onTap;

  static const double _height = 168;
  static const double _radius = 12;
  static const double _inset = 14;
  static const double _textTop = 116;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Material(
      borderRadius: BorderRadius.circular(_radius.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _height.h,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(tile.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppPromoColors.photoShade,
                    stops: AppPromoColors.photoShadeStops,
                  ),
                ),
              ),
              PositionedDirectional(
                start: _inset.w,
                top: _textTop.h,
                end: _inset.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs.h,
                  children: <Widget>[
                    Text(
                      tile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        color: AppPromoColors.onNight,
                      ),
                    ),
                    Text(
                      tile.deal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium?.copyWith(
                        color: AppPromoColors.onPhotoAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
