import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/country_flag.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:country/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A country picker row: flag, name and dial code, tinted with a check when
/// [selected].
class CountryTile extends StatelessWidget {
  const CountryTile({
    required this.country,
    required this.name,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Country country;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 56;
  static const double _padding = 14;
  static const Duration _duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    final code = '+${country.countryCode}';
    return Semantics(
      button: true,
      selected: selected,
      label: '$name $code',
      onTap: onTap,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: context.motion(_duration),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer
              : colors.primaryContainer.withValues(alpha: 0),
          borderRadius: radius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: SizedBox(
              height: height.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _padding.w),
                child: Row(
                  spacing: _padding.w,
                  children: <Widget>[
                    CountryFlag(country: country, size: AppSizes.iconMd.r),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          color: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      code,
                      textDirection: TextDirection.ltr,
                      style: text.titleSmall?.copyWith(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    if (selected)
                      SvgPicture.asset(
                        Assets.iconsCheck,
                        width: AppSizes.iconSm.r,
                        height: AppSizes.iconSm.r,
                        colorFilter: ColorFilter.mode(
                          colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
