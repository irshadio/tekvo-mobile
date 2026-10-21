import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';

/// The agreement to the Terms of Service and Privacy Policy that continuing
/// implies.
class TermsNote extends StatelessWidget {
  const TermsNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final style = context.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final link = style?.emphasized.copyWith(
      color: colors.primary,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary,
    );
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: l10n.signInTermsLead),
          TextSpan(text: l10n.signInTerms, style: link),
          TextSpan(text: l10n.signInTermsJoin),
          TextSpan(text: l10n.signInPrivacy, style: link),
          TextSpan(text: l10n.signInTermsEnd),
        ],
      ),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
