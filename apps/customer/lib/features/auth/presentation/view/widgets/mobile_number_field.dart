import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/country_flag.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/mobile_number_formatter.dart';
import 'package:core/utils/western_digits_formatter.dart';
import 'package:country/country.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The country code button beside the mobile number input. The input fills
/// and gains an outline once used, and shows a check once [isValid].
class MobileNumberField extends StatelessWidget {
  const MobileNumberField({
    required this.controller,
    required this.focusNode,
    required this.country,
    required this.isValid,
    required this.onCountryTap,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Country country;
  final bool isValid;
  final VoidCallback onCountryTap;

  /// The number's digits, without group spaces.
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  static const double height = 54;

  /// The prototype's smart animate between the empty and entered number.
  static const Duration duration = Duration(milliseconds: 300);

  static const double _border = 1.5;
  static const double _badge = 22;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        _CountryCodeButton(country: country, onTap: onCountryTap),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge(<Listenable>[focusNode, controller]),
            builder: (context, child) => _frame(context, child!),
            child: _input(context),
          ),
        ),
      ],
    );
  }

  Widget _frame(BuildContext context, Widget input) {
    final colors = context.colors;
    final focused = focusNode.hasFocus;
    final used = focused || controller.text.isNotEmpty;
    final Color borderColor;
    final double borderWidth;
    if (focused) {
      borderColor = colors.primary;
      borderWidth = AppBorders.focus;
    } else if (used) {
      borderColor = colors.outlineVariant;
      borderWidth = _border;
    } else {
      borderColor = colors.outlineVariant.withValues(alpha: 0);
      borderWidth = 0;
    }
    final motion = context.motion(duration);
    return AnimatedContainer(
      duration: motion,
      curve: Curves.easeOut,
      height: height.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: used
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          Expanded(child: input),
          AnimatedScale(
            scale: isValid ? 1 : 0,
            duration: motion,
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: isValid ? 1 : 0,
              duration: motion,
              child: Semantics(
                label: isValid ? context.l10n.signInNumberValid : null,
                child: _validBadge(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _validBadge(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: _badge.r,
      height: _badge.r,
      decoration: BoxDecoration(
        color: colors.statusSuccess,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        Assets.iconsCheckBadge,
        colorFilter: ColorFilter.mode(colors.statusOnSuccess, BlendMode.srcIn),
      ),
    );
  }

  Widget _input(BuildContext context) {
    final colors = context.colors;
    final style = context.textTheme.bodyLarge;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const <String>[AutofillHints.telephoneNumberNational],
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: <TextInputFormatter>[
        const WesternDigitsFormatter(),
        MobileNumberFormatter(country),
      ],
      style: style?.copyWith(color: colors.onSurface),
      cursorColor: colors.primary,
      onTapOutside: (_) => focusNode.unfocus(),
      onChanged: (text) => onChanged(MobileNumberFormatter.digitsOf(text)),
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: context.l10n.signInNumberHint,
        hintStyle: style?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: _hintOpacity),
        ),
      ),
    );
  }

  static const double _hintOpacity = 0.7;
}

/// The flag and dial code; opens the country picker.
class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  static const double _flag = 20;
  static const double _caret = 16;
  static const double _paddingStart = 14;
  static const double _paddingEnd = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final code = '+${country.countryCode}';
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Semantics(
      button: true,
      label: context.l10n.signInCountryCode(code),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: MobileNumberField.height.h,
            padding: EdgeInsetsDirectional.only(
              start: _paddingStart.w,
              end: _paddingEnd.w,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s6.w,
              children: <Widget>[
                CountryFlag(country: country, size: _flag.r),
                Text(
                  code,
                  textDirection: TextDirection.ltr,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                SvgPicture.asset(
                  Assets.iconsCaretDown,
                  width: _caret.r,
                  height: _caret.r,
                  colorFilter: ColorFilter.mode(
                    colors.onSurfaceVariant,
                    BlendMode.srcIn,
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
