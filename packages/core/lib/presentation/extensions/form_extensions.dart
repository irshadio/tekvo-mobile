import 'package:core/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Form validation that is never silent off-screen.
extension FormStateX on FormState {
  static const Duration revealDuration = AppMotion.medium;

  /// Like [FormState.validate], and scrolls the topmost invalid field into
  /// view when it is outside the viewport, so a failed Continue always shows
  /// its error. Measures after the next frame, once the errors are laid out.
  bool validateAndReveal() {
    final invalid = validateGranularly();
    if (invalid.isEmpty) return true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reveal(invalid);
    });
    return false;
  }

  void _reveal(Set<FormFieldState<Object?>> invalid) {
    Rect? topRect;
    BuildContext? top;
    for (final field in invalid) {
      if (!field.mounted) continue;
      final rect = _globalRect(field.context);
      if (rect == null) continue;
      if (topRect == null || rect.top < topRect.top) {
        topRect = rect;
        top = field.context;
      }
    }
    if (top == null || topRect == null) return;
    final scrollable = Scrollable.maybeOf(top);
    final viewport = scrollable == null
        ? null
        : _globalRect(scrollable.context);
    if (viewport == null) return;
    final ScrollPositionAlignmentPolicy policy;
    if (topRect.top < viewport.top) {
      policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
    } else if (topRect.bottom > viewport.bottom) {
      policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
    } else {
      return;
    }
    Scrollable.ensureVisible(
      top,
      alignmentPolicy: policy,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : revealDuration,
      curve: Curves.easeOut,
    );
  }

  static Rect? _globalRect(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
