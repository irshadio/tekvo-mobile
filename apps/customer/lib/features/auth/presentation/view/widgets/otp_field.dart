import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/otp_input.dart';
import 'package:core/utils/western_digits_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One box per code digit over a hidden text field, so typing, paste and
/// SMS autofill work as in any field. The box taking the next digit is
/// outlined while the field has focus.
class OtpField extends StatefulWidget {
  const OtpField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// The field's name for screen readers.
  final String label;
  final ValueChanged<String> onChanged;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  static const double _boxWidth = 52;
  static const double _boxHeight = 60;
  static const double _border = 1.5;
  static const double _caretWidth = 1.5;
  static const double _caretHeight = 24;
  static const Duration _duration = Duration(milliseconds: 150);

  TextEditingController get controller => widget.controller;
  FocusNode get focusNode => widget.focusNode;

  @override
  void initState() {
    super.initState();
    controller.addListener(_keepCaretAtEnd);
  }

  @override
  void didUpdateWidget(OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_keepCaretAtEnd);
      controller.addListener(_keepCaretAtEnd);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_keepCaretAtEnd);
    super.dispose();
  }

  /// Digits always go on the end, as the boxes show, however the caret or
  /// selection was moved.
  void _keepCaretAtEnd() {
    final end = TextSelection.collapsed(offset: controller.text.length);
    if (controller.selection != end) controller.selection = end;
  }

  @override
  Widget build(BuildContext context) {
    // Codes read left to right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: <Widget>[
          ExcludeSemantics(
            child: ListenableBuilder(
              listenable: Listenable.merge(<Listenable>[focusNode, controller]),
              builder: (context, _) => _boxes(context),
            ),
          ),
          Positioned.fill(child: _input()),
        ],
      ),
    );
  }

  Widget _boxes(BuildContext context) {
    final colors = context.colors;
    final code = controller.text;
    final focused = focusNode.hasFocus;
    final motion = context.motion(_duration);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (var i = 0; i < OtpInput.length; i++)
          AnimatedContainer(
            duration: motion,
            width: _boxWidth.w,
            height: _boxHeight.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
              border: focused && i == code.length
                  ? Border.all(color: colors.primary, width: AppBorders.focus)
                  : Border.all(color: colors.outlineVariant, width: _border),
            ),
            child: AnimatedSwitcher(
              duration: motion,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: i < code.length
                  ? Text(
                      code[i],
                      key: ValueKey<String>('$i${code[i]}'),
                      style: context.textTheme.headlineSmall,
                    )
                  : focused && i == code.length
                  ? Container(
                      key: const ValueKey<String>('caret'),
                      width: _caretWidth,
                      height: _caretHeight.h,
                      color: colors.primary,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Widget _input() {
    final hidden = context.colors.surface.withValues(alpha: 0);
    return Semantics(
      label: widget.label,
      child: TextSelectionTheme(
        data: TextSelectionThemeData(selectionColor: hidden),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.oneTimeCode],
          autocorrect: false,
          enableSuggestions: false,
          showCursor: false,
          magnifierConfiguration: TextMagnifierConfiguration.disabled,
          inputFormatters: <TextInputFormatter>[
            const WesternDigitsFormatter(),
            FilteringTextInputFormatter.digitsOnly,
            const _CodeLengthFormatter(),
          ],
          style: context.textTheme.bodyLarge?.copyWith(color: hidden),
          decoration: const InputDecoration(
            isCollapsed: true,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onTapOutside: (_) => focusNode.unfocus(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

/// Keeps at most a code's length of digits. A pasted or autofilled whole
/// code replaces what was typed instead of being cut off after it.
class _CodeLengthFormatter extends TextInputFormatter {
  const _CodeLengthFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= OtpInput.length) return newValue;
    final inserted = text.startsWith(oldValue.text)
        ? text.substring(oldValue.text.length)
        : text;
    if (inserted.length < OtpInput.length) return oldValue;
    return TextEditingValue(
      text: inserted.substring(0, OtpInput.length),
      selection: const TextSelection.collapsed(offset: OtpInput.length),
    );
  }
}
