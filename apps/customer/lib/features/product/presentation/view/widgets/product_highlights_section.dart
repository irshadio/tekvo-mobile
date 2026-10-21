import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/product_specs.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The headline facts in tiles, the main specification lines and a link
/// to the full specification.
class ProductHighlightsSection extends StatelessWidget {
  const ProductHighlightsSection({
    required this.highlights,
    required this.specs,
    required this.onAllSpecs,
    required this.onHighlight,
    super.key,
  });

  final List<Highlight> highlights;
  final List<Spec> specs;
  final VoidCallback onAllSpecs;

  /// Opens the specification at the highlight's group.
  final ValueChanged<HighlightKind> onHighlight;

  static const double _icon = 22;
  static const double _radius = 10;
  static const double _label = 120;
  static const double _rowPadding = 9;
  static const double _link = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return ProductSection(
      spacing: AppSpacing.md,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(l10n.productHighlights, style: text.titleLarge),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final tile = (constraints.maxWidth - AppSpacing.sm.w) / 2;
            return Wrap(
              spacing: AppSpacing.sm.w,
              runSpacing: AppSpacing.sm.h,
              children: <Widget>[
                for (final highlight in highlights)
                  _tile(context, highlight, tile),
              ],
            );
          },
        ),
        Column(
          children: <Widget>[
            for (final spec in specs)
              Container(
                padding: EdgeInsets.symmetric(vertical: _rowPadding.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.md.w,
                  children: <Widget>[
                    SizedBox(
                      width: _label.w,
                      child: Text(
                        spec.label,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(spec.value, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
        InkWell(
          onTap: onAllSpecs,
          borderRadius: BorderRadius.circular(AppRadius.xs.r),
          child: Row(
            children: <Widget>[
              SizedBox(height: _link.h),
              Expanded(
                child: Text(l10n.productAllSpecs, style: text.labelLarge),
              ),
              ProductIcon(
                Assets.iconsChevronRight,
                size: AppSizes.iconSm,
                color: colors.onSurfaceVariant,
                flip: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, Highlight highlight, double width) {
    final colors = context.colors;
    final text = context.textTheme;
    final radius = BorderRadius.circular(_radius.r);
    return Material(
      color: colors.surfaceContainer,
      borderRadius: radius,
      child: InkWell(
        onTap: () => onHighlight(highlight.kind),
        borderRadius: radius,
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.md.h,
          ),
          child: Row(
            spacing: 10.w,
            children: <Widget>[
              ProductIcon(
                _iconOf(highlight.kind),
                size: _icon,
                color: colors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 1.h,
                  children: <Widget>[
                    Text(
                      highlight.label,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(highlight.value, style: text.titleSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _iconOf(HighlightKind kind) => switch (kind) {
    HighlightKind.display => Assets.iconsPhone,
    HighlightKind.camera => Assets.iconsCamera,
    HighlightKind.battery => Assets.iconsBolt,
    HighlightKind.connectivity => Assets.iconsGlobe,
  };
}
