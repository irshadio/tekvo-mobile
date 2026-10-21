import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/arb/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Placeholder names in [message], e.g. `{page}`.
Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _arb('core_en.arb');
  final ar = _arb('core_ar.arb');
  Iterable<String> messages(Map<String, dynamic> arb) =>
      arb.keys.where((key) => !key.startsWith('@'));

  test('Arabic has exactly the English keys', () {
    expect(messages(ar).toSet(), messages(en).toSet());
  });

  test('Arabic keeps every placeholder', () {
    for (final key in messages(en)) {
      expect(
        _placeholders(ar[key] as String),
        _placeholders(en[key] as String),
        reason: key,
      );
    }
  });

  test('every English message is non-empty', () {
    for (final key in messages(en)) {
      expect((en[key] as String).trim(), isNotEmpty, reason: key);
    }
  });
}
