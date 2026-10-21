import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/back_bar_scaffold.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:core/utils/ltr_isolate.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/otp_input.dart';
import 'package:customer/features/auth/presentation/view/widgets/otp_field.dart';
import 'package:customer/features/auth/presentation/view/widgets/resend_code.dart';
import 'package:customer/features/auth/presentation/view_model/otp_view_model.dart';
import 'package:customer/features/auth/presentation/view_model/resend_code_view_model.dart';
import 'package:customer/features/auth/presentation/view_model/resend_timer_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enter the code texted to [contact]. Pops `true` when the user chooses to
/// change the number; a verified code opens the profile in its place.
class OtpView extends ConsumerStatefulWidget {
  const OtpView({required this.contact, super.key});

  final MobileContact contact;

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> {
  static const double _codeGap = 32;
  static const double _resendGap = 24;
  static const double _buttonGap = 28;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TapGestureRecognizer _edit = TapGestureRecognizer()
    ..onTap = _changeNumber;
  late final TapGestureRecognizer _another = TapGestureRecognizer()
    ..onTap = _changeNumber;

  @override
  void dispose() {
    _edit.dispose();
    _another.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _changeNumber() => Navigator.of(context).pop(true);

  void _verify() {
    if (!OtpInput.isComplete(_controller.text)) return;
    _focusNode.unfocus();
    unawaited(
      ref
          .read(otpViewModelProvider.notifier)
          .verify(contact: widget.contact, code: _controller.text),
    );
  }

  void _resend() => unawaited(
    ref.read(resendCodeViewModelProvider.notifier).resend(widget.contact),
  );

  @override
  Widget build(BuildContext context) {
    ref
      ..listenSubmission(
        otpViewModelProvider,
        context,
        onSuccess: (_) => unawaited(
          context.pushReplacementNamed<void, bool>(Routes.profile),
        ),
      )
      ..listenSubmission(
        resendCodeViewModelProvider,
        context,
        onSuccess: (_) {
          ref.read(resendTimerViewModelProvider.notifier).restart();
          context.showSnackBar(context.l10n.otpResent);
        },
      );
    final verifying = ref.watch(otpViewModelProvider).isInProgress;
    final resending = ref.watch(resendCodeViewModelProvider).isInProgress;
    final text = context.textTheme;
    final l10n = context.l10n;

    return BackBarScaffold(
      children: <Widget>[
        SizedBox(height: AppSpacing.sm.h),
        Semantics(
          header: true,
          child: Text(
            l10n.otpTitle,
            style: text.headlineMedium,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        _sentTo(context),
        SizedBox(height: _codeGap.h),
        OtpField(
          controller: _controller,
          focusNode: _focusNode,
          label: l10n.otpCodeLabel,
          onChanged: (_) => ref.read(otpViewModelProvider.notifier).reset(),
        ),
        SizedBox(height: _resendGap.h),
        ResendCode(onResend: resending ? null : _resend),
        SizedBox(height: _buttonGap.h),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => FilledButton(
            onPressed: OtpInput.isComplete(_controller.text) && !verifying
                ? _verify
                : null,
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(
                AppSizes.controlXl.h,
              ),
              textStyle: text.titleMedium,
            ),
            child: Text(l10n.otpVerify),
          ),
        ),
        SizedBox(height: _buttonGap.h),
        const Spacer(),
        _tryAnother(context),
      ],
    );
  }

  /// Where the code went, and a link back to change it.
  Widget _sentTo(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final style = context.textTheme.bodyLarge?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: l10n.otpSentTo(OtpInput.length)),
          TextSpan(
            text: ltrIsolate(widget.contact.display),
            style: style?.emphasized.copyWith(color: colors.onSurface),
          ),
          const TextSpan(text: '  '),
          TextSpan(
            text: l10n.otpEdit,
            recognizer: _edit,
            style: style?.emphasized.copyWith(
              color: colors.primary,
              decoration: TextDecoration.underline,
              decorationColor: colors.primary,
            ),
          ),
        ],
      ),
      style: style,
    );
  }

  Widget _tryAnother(BuildContext context) {
    final colors = context.colors;
    final style = context.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: context.l10n.otpNoCode),
            TextSpan(
              text: context.l10n.otpTryAnother,
              recognizer: _another,
              style: style?.emphasized.copyWith(color: colors.primary),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
