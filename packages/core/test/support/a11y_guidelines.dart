import 'package:core/l10n/generated/core_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A control the design keeps below one guideline, found by its semantics
/// [label]. [reason] cites the accepting convention.
class A11yAllowance {
  /// Exempt from the tap-target sizes only.
  const A11yAllowance.size(this.label, this.reason) : contrast = false;

  /// Exempt from the text contrast ratio only.
  const A11yAllowance.contrast(this.label, this.reason) : contrast = true;

  final String label;
  final String reason;
  final bool contrast;
}

/// The English strings, for allowance labels.
final CoreLocalizations en = lookupCoreLocalizations(const Locale('en'));

/// Small design controls keep their design size.
const String smallDesignControl =
    'small design control keeps its design size below the tap target';

/// Checks the tap-target (Android 48, iOS 44), labelled-target and text
/// contrast guidelines on the current screen, skipping [allow]'s controls,
/// and reports every failure at once.
Future<void> expectGuidelines(
  WidgetTester tester, [
  List<A11yAllowance> allow = const <A11yAllowance>[],
]) async {
  final sizes = _Allowed(allow.where((a) => !a.contrast));
  final contrasts = _Allowed(allow.where((a) => a.contrast));
  final failures = <String>[];
  for (final guideline in <AccessibilityGuideline>[
    _AllowedTapTargets(sizes, androidTapTargetGuideline),
    _AllowedTapTargets(sizes, iOSTapTargetGuideline),
    labeledTapTargetGuideline,
    _AllowedContrast(contrasts),
  ]) {
    final result = await guideline.evaluate(tester);
    if (!result.passed) {
      failures.add('${guideline.description}:\n${result.reason}');
    }
  }
  expect(failures, isEmpty);
}

/// Matches a node by its label's first line (merged labels add lines such
/// as a tab's position), exactly or followed by a space (a count).
class _Allowed {
  _Allowed(Iterable<A11yAllowance> allow)
    : _labels = <String>{for (final allowance in allow) allowance.label};

  final Set<String> _labels;

  bool call(String label) {
    final first = label.trim().split('\n').first;
    return _labels.any(
      (allowed) => first == allowed || first.startsWith('$allowed '),
    );
  }
}

class _AllowedTapTargets extends MinimumTapTargetGuideline {
  _AllowedTapTargets(this.allowed, AccessibilityGuideline base)
    : super(
        size: (base as MinimumTapTargetGuideline).size,
        link: base.link,
      );

  final _Allowed allowed;

  @override
  bool shouldSkipNode(SemanticsNode node) =>
      super.shouldSkipNode(node) || allowed(node.getSemanticsData().label);
}

class _AllowedContrast extends MinimumTextContrastGuideline {
  const _AllowedContrast(this.allowed);

  final _Allowed allowed;

  @override
  bool shouldSkipNode(SemanticsData data) =>
      super.shouldSkipNode(data) || allowed(data.label);
}
