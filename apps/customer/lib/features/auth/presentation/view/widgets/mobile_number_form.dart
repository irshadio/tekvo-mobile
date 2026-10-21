import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/country_picker_sheet.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/mobile_number.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/presentation/view/widgets/mobile_number_field.dart';
import 'package:customer/features/auth/presentation/view_model/mobile_number_view_model.dart';
import 'package:customer/features/auth/presentation/view_model/send_code_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The mobile number label, field and send button of [step]. Sending texts
/// a code and opens its entry, carrying [account] on to the profile; when
/// the user comes back to change the number, the field takes focus again.
class MobileNumberForm extends ConsumerStatefulWidget {
  const MobileNumberForm({
    required this.step,
    required this.submitLabel,
    this.account,
    super.key,
  });

  final NumberStep step;
  final String submitLabel;
  final SocialAccount? account;

  @override
  ConsumerState<MobileNumberForm> createState() => _MobileNumberFormState();
}

class _MobileNumberFormState extends ConsumerState<MobileNumberForm> {
  static const double _buttonGap = 20;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  MobileNumberViewModelProvider get _form =>
      mobileNumberViewModelProvider(widget.step);
  SendCodeViewModelProvider get _send => sendCodeViewModelProvider(widget.step);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    // A second tap while the code screen slides in would push it twice.
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
    final form = ref.read(_form);
    if (!form.isValid) return;
    _focusNode.unfocus();
    unawaited(ref.read(_send.notifier).send(form.contact));
  }

  Future<void> _openCodeEntry() async {
    final request = (
      contact: ref.read(_form).contact,
      account: widget.account,
    );
    final change = await context.pushNamed<bool>(
      Routes.otp,
      arguments: request,
    );
    if (mounted && (change ?? false)) _focusNode.requestFocus();
  }

  void _pickCountry() => unawaited(
    CountryPickerSheet.show(
      context,
      selected: ref.read(_form).country,
      onSelected: (country) {
        ref.read(_form.notifier).selectCountry(country);
        final text = MobileNumber.group(ref.read(_form).number);
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listenSubmission(
      _send,
      context,
      onSuccess: (_) => unawaited(_openCodeEntry()),
    );
    final form = ref.watch(_form);
    final sending = ref.watch(_send).isInProgress;
    final text = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(context.l10n.signInNumberLabel, style: text.labelLarge),
        SizedBox(height: AppSpacing.sm.h),
        MobileNumberField(
          controller: _controller,
          focusNode: _focusNode,
          country: form.country,
          isValid: form.isValid,
          onCountryTap: _pickCountry,
          onChanged: ref.read(_form.notifier).numberChanged,
          onSubmitted: _submit,
        ),
        SizedBox(height: _buttonGap.h),
        FilledButton(
          onPressed: form.isValid && !sending ? _submit : null,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(AppSizes.controlXl.h),
            textStyle: text.titleMedium,
            animationDuration: MobileNumberField.duration,
          ),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
