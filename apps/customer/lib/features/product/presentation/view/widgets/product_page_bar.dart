import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The pinned bar of a screen opened from a product: back, a title, any
/// [actions] and an optional row under them, such as jump chips.
class ProductPageBar extends StatelessWidget {
  const ProductPageBar({
    required this.title,
    this.actions = const <Widget>[],
    this.bottom,
    super.key,
  });

  final String title;
  final List<Widget> actions;
  final Widget? bottom;

  /// An action button sized for this bar.
  static Widget action({
    required String icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) => AppIconButton(
    icon: icon,
    tooltip: tooltip,
    onPressed: onPressed,
    variant: AppIconButtonVariant.plain,
    iconSize: _icon,
  );

  static const double _icon = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottom = this.bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm.w,
              context.viewPadding.top + AppSpacing.xs.h,
              AppSpacing.sm.w,
              AppSpacing.xs.h,
            ),
            child: Row(
              spacing: AppSpacing.xs.w,
              children: <Widget>[
                action(
                  icon: Assets.iconsChevronLeft,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          if (bottom != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.xs.h,
                bottom: AppSpacing.md.h,
              ),
              child: bottom,
            ),
          // The border is drawn inside the bar, so leave room for it.
          const SizedBox(height: AppBorders.thin),
        ],
      ),
    );
  }
}
