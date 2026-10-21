import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Tekvo logo mark in the current theme's colours: a rounded tile in the
/// primary colour, the bolt in its on-colour and the deal-green spark.
/// [size] is in logical pixels; the geometry follows the 40 px Figma
/// component.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({required this.size, super.key});

  final double size;

  static const double _design = 40;
  static const double _radius = 12;
  static const double _sparkCenterX = 31;
  static const double _sparkCenterY = 9;
  static const double _sparkRadius = 4;

  @override
  Widget build(BuildContext context) {
    final scale = size / _design;
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(_radius * scale),
            ),
            child: SvgPicture.asset(
              Assets.brandLogoBolt,
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
            ),
          ),
          PositionedDirectional(
            start: (_sparkCenterX - _sparkRadius) * scale,
            top: (_sparkCenterY - _sparkRadius) * scale,
            child: Container(
              width: _sparkRadius * 2 * scale,
              height: _sparkRadius * 2 * scale,
              decoration: BoxDecoration(
                color: context.appColors.commerceDeal,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
