import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One-choice filter chips in a row that scrolls sideways; the chosen one
/// is filled in the inverse colours and scrolled into view when it changes.
class FilterChips extends StatefulWidget {
  const FilterChips({
    required this.labels,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  static const Duration _duration = Duration(milliseconds: 200);

  final ScrollController _row = ScrollController();
  late List<GlobalKey> _keys = _keysFor(widget.labels.length);

  static List<GlobalKey> _keysFor(int count) =>
      List<GlobalKey>.generate(count, (_) => GlobalKey());

  @override
  void didUpdateWidget(FilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.labels.length != _keys.length) {
      _keys = _keysFor(widget.labels.length);
    }
    if (widget.selected != oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  /// Centres the chosen chip in the row, scrolling only the row.
  void _reveal() {
    final index = widget.selected;
    if (!mounted || !_row.hasClients || index < 0 || index >= _keys.length) {
      return;
    }
    final chip = _keys[index].currentContext?.findRenderObject();
    final row = context.findRenderObject();
    if (chip is! RenderBox || row is! RenderBox) return;
    final left = chip.localToGlobal(Offset.zero, ancestor: row).dx;
    final position = _row.position;
    final target =
        (position.pixels + left + chip.size.width / 2 - row.size.width / 2)
            .clamp(position.minScrollExtent, position.maxScrollExtent);
    _row.animateTo(
      target,
      duration: context.motion(_duration),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _row.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppChip.height.h,
      child: SingleChildScrollView(
        controller: _row,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Row(
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            for (var index = 0; index < widget.labels.length; index++)
              AppChip(
                key: _keys[index],
                label: widget.labels[index],
                selected: index == widget.selected,
                onTap: () => widget.onSelect(index),
              ),
          ],
        ),
      ),
    );
  }
}

/// A chip that is filled in the inverse colours while [selected], and
/// outlined otherwise.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 36;
  static const double _radius = 6;
  static const double _border = 1.5;
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(_radius.r);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: context.motion(_duration),
          height: height.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colors.inverseSurface
                : colors.surfaceContainerLowest,
            borderRadius: radius,
            border: selected
                ? null
                : Border.all(color: colors.outlineVariant, width: _border),
          ),
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: selected ? colors.onInverseSurface : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
