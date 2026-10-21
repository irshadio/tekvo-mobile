import 'dart:math';

import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Products the user looked at, as small cards in a row that scrolls
/// sideways.
class RecentlyViewed extends StatelessWidget {
  const RecentlyViewed({
    required this.products,
    required this.onProduct,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;

  static const double _height = 70;
  static const double _photo = 56;
  static const double _radius = 10;
  static const double _gap = 10;
  static const double _padding = 7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    // The design's height, or the two text lines and the padding once the
    // text is larger.
    final height = max(
      _height.h,
      _padding.h * 2 +
          context.textBox(20, size: 14) +
          AppSpacing.xxs.h +
          context.textBox(16, size: 12),
    );
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        itemCount: products.length,
        separatorBuilder: (_, _) => SizedBox(width: _gap.w),
        itemBuilder: (context, index) {
          final product = products[index];
          final radius = BorderRadius.circular(_radius.r);
          return Material(
            color: colors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onProduct(product.id),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  _padding.w,
                  _padding.h,
                  15.w,
                  _padding.h,
                ),
                child: Row(
                  spacing: _gap.w,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm.r),
                      child: Image.asset(
                        product.image,
                        width: _photo.r,
                        height: _photo.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xxs.h,
                      children: <Widget>[
                        Text(product.name, style: text.labelLarge),
                        Text(
                          context.money(product.price),
                          style: text.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
