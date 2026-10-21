import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/permissions/presentation/view/widgets/permission_benefit.dart';
import 'package:customer/features/permissions/presentation/view/widgets/permission_benefits_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The screen that explains a permission before the system asks for it: an
/// illustration, a title and text, the benefits, then the allow button, a
/// way to continue without it and a note.
class PermissionPrompt extends StatelessWidget {
  const PermissionPrompt({
    required this.icon,
    required this.title,
    required this.body,
    required this.benefits,
    required this.allowLabel,
    required this.declineLabel,
    required this.note,
    required this.onAllow,
    required this.onDecline,
    super.key,
  });

  /// The glyph in the illustration's inner circle.
  final String icon;
  final String title;
  final String body;
  final List<PermissionBenefit> benefits;
  final String allowLabel;
  final String declineLabel;
  final String note;

  /// Null while the system prompt is open.
  final VoidCallback? onAllow;
  final VoidCallback? onDecline;

  static const double _contentTop = 48;
  static const double _sectionGap = 20;
  static const double _introGap = 14;
  static const double _illustration = 136;
  static const double _illustrationInner = 92;
  static const double _illustrationIcon = 42;
  static const double _declineHeight = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final background = colors.surfaceContainerLowest;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.over(background),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    _contentTop.h,
                    AppSpacing.xl.w,
                    AppSpacing.lg.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: _sectionGap.h,
                    children: <Widget>[
                      Column(
                        spacing: _introGap.h,
                        children: <Widget>[
                          _illustrationOf(colors),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: text.headlineSmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: text.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      PermissionBenefitsCard(benefits: benefits),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.sm.h,
                  children: <Widget>[
                    FilledButton(onPressed: onAllow, child: Text(allowLabel)),
                    SizedBox(
                      height: _declineHeight.h,
                      child: TextButton(
                        onPressed: onDecline,
                        child: Text(declineLabel),
                      ),
                    ),
                    Text(
                      note,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _illustrationOf(ColorScheme colors) => ExcludeSemantics(
    child: Container(
      width: _illustration.r,
      height: _illustration.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: _illustrationInner.r,
        height: _illustrationInner.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          width: _illustrationIcon.r,
          height: _illustrationIcon.r,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
      ),
    ),
  );
}
