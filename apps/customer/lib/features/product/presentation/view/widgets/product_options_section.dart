import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:customer/features/product/domain/entities/product_options.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Every option group, such as colour and storage, with the chosen one
/// marked, and a warning when few are left.
class ProductOptionsSection extends StatelessWidget {
  const ProductOptionsSection({
    required this.groups,
    required this.chosen,
    required this.onChoose,
    this.stockLeft,
    super.key,
  });

  final List<ProductOptionGroup> groups;

  /// The option the user chose in each group they changed, by index.
  final Map<int, int> chosen;
  final void Function(int group, int option) onChoose;
  final int? stockLeft;

  static const double _stockDot = 8;

  @override
  Widget build(BuildContext context) {
    final sale = context.appColors.commerceSale;
    return ProductSection(
      spacing: AppSpacing.md,
      children: <Widget>[
        for (var g = 0; g < groups.length; g++) ...<Widget>[
          _title(context, groups[g], chosen[g] ?? groups[g].chosen),
          _options(groups[g], g, chosen[g] ?? groups[g].chosen),
        ],
        if (stockLeft case final left?)
          Row(
            spacing: AppSpacing.s6.w,
            children: <Widget>[
              Container(
                width: _stockDot.r,
                height: _stockDot.r,
                decoration: BoxDecoration(color: sale, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  context.l10n.productStockLeft(left),
                  style: context.textTheme.labelMedium?.copyWith(color: sale),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _title(BuildContext context, ProductOptionGroup group, int chosen) {
    final text = context.textTheme;
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: context.l10n.productOptionName(group.name),
            style: text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: group.options[chosen].name,
            style: text.titleSmall?.emphasized,
          ),
        ],
      ),
    );
  }

  Widget _options(ProductOptionGroup group, int g, int chosen) {
    final options = group.options;
    if (group.swatches) {
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: <Widget>[
          for (var o = 0; o < options.length; o++)
            _Swatch(
              option: options[o],
              selected: o == chosen,
              onTap: () => onChoose(g, o),
            ),
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          for (var o = 0; o < options.length; o++)
            Expanded(
              child: _OptionBox(
                option: options[o],
                selected: o == chosen,
                onTap: () => onChoose(g, o),
              ),
            ),
        ],
      ),
    );
  }
}

/// A colour to pick, ringed in the brand colour when chosen.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ProductOption option;
  final bool selected;
  final VoidCallback onTap;

  static const double _size = 40;
  static const double _dot = 30;
  static const Duration _ring = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: option.name,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: _size.r / 2 + AppSpacing.xs.r,
        child: AnimatedContainer(
          duration: context.motion(_ring),
          width: _size.r,
          height: _size.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.primary : colors.surfaceContainerLowest,
              width: AppBorders.focus,
            ),
          ),
          child: Container(
            width: _dot.r,
            height: _dot.r,
            decoration: BoxDecoration(
              color: Color(option.swatch ?? 0),
              shape: BoxShape.circle,
              border: Border.all(color: colors.outlineVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// An option such as a storage size, with its price or Sold out.
class _OptionBox extends StatelessWidget {
  const _OptionBox({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ProductOption option;
  final bool selected;
  final VoidCallback onTap;

  static const double _outline = 1.5;
  static const double _soldOutNote = 0.7;
  static const double _vertical = 11;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final ink = selected ? colors.onPrimaryContainer : colors.onSurface;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    final price = option.price;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: context.motion(_swap),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: _vertical.h,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer
                  : colors.surfaceContainerLowest,
              borderRadius: radius,
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? AppBorders.thick : _outline,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(
                  opacity: option.soldOut ? AppOpacity.disabledContent : 1,
                  child: Text(
                    option.name,
                    textAlign: TextAlign.center,
                    style: text.titleSmall?.copyWith(color: ink),
                  ),
                ),
                if (option.soldOut)
                  Opacity(
                    opacity: _soldOutNote,
                    child: Text(
                      context.l10n.productSoldOut,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (price != null)
                  Text(
                    context.money(price),
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: selected ? ink : colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
