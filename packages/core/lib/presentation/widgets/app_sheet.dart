import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The app's modal bottom sheet: it rises over a dimmed screen with rounded
/// top corners, stays below the status bar, at most about 0.9 of the screen
/// tall, and is lifted above the keyboard.
///
/// The sheet draws its own handle, and its content adds the bottom safe-area
/// inset where its design needs it.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Keeps the padding in the sheet's MediaQuery, so a keyboard frame
    // rebuilds only the inset below, not the sheet's content.
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: colors.surfaceContainerLowest,
    barrierColor: colors.scrim.withValues(alpha: _scrimOpacity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md.r)),
    ),
    clipBehavior: Clip.antiAlias,
    constraints: BoxConstraints(
      maxWidth: _maxWidth,
      maxHeight: context.screenSize.height * _maxHeightShare,
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: context.motion(sheetRiseDuration),
      curve: Curves.easeOut,
      reverseDuration: context.motion(sheetRiseDuration),
      reverseCurve: Curves.easeIn,
    ),
    builder: (context) => _KeyboardInset(child: builder(context)),
  );
}

/// How long a sheet takes to rise, as in the prototype.
const Duration sheetRiseDuration = Duration(milliseconds: 350);

const double _scrimOpacity = 0.4;

/// Leaves the status bar and a strip of the screen above the tallest sheet.
const double _maxHeightShare = 0.91;

/// Material's default width cap, which [BoxConstraints] replaces.
const double _maxWidth = 640;

class _KeyboardInset extends StatelessWidget {
  const _KeyboardInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: child,
  );
}
