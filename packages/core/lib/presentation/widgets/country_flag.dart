import 'package:country/country.dart';
import 'package:flutter/material.dart';

/// [country]'s flag as the system's emoji, in a [size] square whatever the
/// emoji font's width.
class CountryFlag extends StatelessWidget {
  const CountryFlag({required this.country, required this.size, super.key});

  final Country country;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Text(
            country.flagEmoji,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: size,
              height: 1,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
      ),
    );
  }
}
