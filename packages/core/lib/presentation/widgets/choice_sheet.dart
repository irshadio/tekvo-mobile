import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_sheet.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A sheet of [options] with a radio each, such as Sort by: the tapped one
/// shows as chosen, then the sheet closes with its index.
class ChoiceSheet extends StatefulWidget {
  const ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
    super.key,
  });

  final String title;
  final List<String> options;
  final int selected;

  /// Lets the new choice show before the sheet closes.
  static const Duration closeDelay = Duration(milliseconds: 150);

  /// Shows the sheet and completes with the chosen index, or null when it
  /// is dismissed.
  static Future<int?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required int selected,
  }) => showAppSheet<int>(
    context,
    builder: (_) =>
        ChoiceSheet(title: title, options: options, selected: selected),
  );

  @override
  State<ChoiceSheet> createState() => _ChoiceSheetState();
}

class _ChoiceSheetState extends State<ChoiceSheet> {
  static const double _handleWidth = 36;
  static const double _handleHeight = 4;
  static const double _close = 44;
  static const double _closeIcon = 22;
  static const double _radio = 22;
  static const double _dot = 10;
  static const double _rowPadding = 14;
  static const double _bottom = 30;
  static const Duration _mark = Duration(milliseconds: 150);

  late final ValueNotifier<int> _chosen = ValueNotifier<int>(widget.selected);
  bool _closing = false;

  @override
  void dispose() {
    _chosen.dispose();
    super.dispose();
  }

  Future<void> _choose(int index) async {
    if (_closing) return;
    _closing = true;
    _chosen.value = index;
    await Future<void>.delayed(context.motion(ChoiceSheet.closeDelay));
    if (mounted) Navigator.of(context).pop(index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        10.h,
        AppSpacing.lg.w,
        _bottom.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm.h,
        children: <Widget>[
          Center(
            child: Container(
              width: _handleWidth.w,
              height: _handleHeight.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(_handleHeight.h / 2),
              ),
            ),
          ),
          Row(
            spacing: AppSpacing.sm.w,
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(widget.title, style: text.titleLarge),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHigh,
                  fixedSize: Size.square(_close.r),
                  minimumSize: Size.square(_close.r),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: SvgPicture.asset(
                  Assets.iconsClose,
                  width: _closeIcon.r,
                  height: _closeIcon.r,
                  colorFilter: ColorFilter.mode(
                    colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: ValueListenableBuilder<int>(
                valueListenable: _chosen,
                builder: (context, chosen, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (i, option) in widget.options.indexed)
                      _row(context, option, i, on: i == chosen, first: i == 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String option,
    int index, {
    required bool on,
    required bool first,
  }) {
    final colors = context.colors;
    final text = context.textTheme;
    return Semantics(
      selected: on,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: InkWell(
        onTap: () => unawaited(_choose(index)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: _rowPadding.h),
          decoration: BoxDecoration(
            border: first
                ? null
                : Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            spacing: AppSpacing.md.w,
            children: <Widget>[
              Expanded(
                child: Text(
                  option,
                  style: on
                      ? text.titleSmall?.copyWith(color: colors.primary)
                      : text.bodyLarge,
                ),
              ),
              AnimatedContainer(
                duration: context.motion(_mark),
                width: _radio.r,
                height: _radio.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: on ? colors.primary : colors.outline,
                    width: AppBorders.thick,
                  ),
                ),
                child: AnimatedScale(
                  duration: context.motion(_mark),
                  scale: on ? 1 : 0,
                  child: Container(
                    width: _dot.r,
                    height: _dot.r,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
