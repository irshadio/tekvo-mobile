import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:customer/features/auth/presentation/view_model/resend_timer_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// "Resend code in 00:24" counting down, then a Resend code link, on one
/// line so the screen below never shifts.
class ResendCode extends ConsumerWidget {
  const ResendCode({required this.onResend, super.key});

  /// Null while a new code is being sent.
  final VoidCallback? onResend;

  static const double _height = 20;
  static const double _clock = 18;
  static const Duration _switch = Duration(milliseconds: 200);

  static String _clockText(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(resendTimerViewModelProvider);
    final colors = context.colors;
    final style = context.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final l10n = context.l10n;
    return SizedBox(
      height: _height.h,
      child: AnimatedSwitcher(
        duration: context.motion(_switch),
        child: seconds > 0
            ? Row(
                key: const ValueKey<String>('countdown'),
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.sm.w,
                children: <Widget>[
                  SvgPicture.asset(
                    Assets.iconsClock,
                    width: _clock.r,
                    height: _clock.r,
                    colorFilter: ColorFilter.mode(
                      colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(text: l10n.otpResendIn),
                        TextSpan(
                          text: _clockText(seconds),
                          style: style?.emphasized.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    style: style,
                  ),
                ],
              )
            : OverflowBox(
                key: const ValueKey<String>('resend'),
                maxHeight: double.infinity,
                child: TextButton(
                  onPressed: onResend,
                  style: TextButton.styleFrom(
                    textStyle: style?.emphasized,
                    foregroundColor: colors.primary,
                  ),
                  child: Text(l10n.otpResend),
                ),
              ),
      ),
    );
  }
}
