import 'dart:async';

import 'package:core/error/error_reporter.dart';
import 'package:core/permissions/permission_service.dart';
import 'package:flutter/foundation.dart';

/// Answers prompts with [outcome], or throws when [fails]; [answer] holds the
/// prompt open until completed, when given.
class FakePermissionService implements PermissionService {
  FakePermissionService({
    this.outcome = PermissionOutcome.granted,
    this.fails = false,
    this.answer,
  });

  final PermissionOutcome outcome;
  final bool fails;
  final Completer<void>? answer;
  final List<AppPermission> asked = <AppPermission>[];

  @override
  Future<PermissionOutcome> request(AppPermission permission) async {
    asked.add(permission);
    await answer?.future;
    if (fails) throw StateError('plugin missing');
    return outcome;
  }
}

class FakeErrorReporter implements ErrorReporter {
  final List<String?> contexts = <String?>[];

  @override
  void report(Object error, StackTrace stackTrace, {String? context}) =>
      contexts.add(context);

  @override
  void reportFlutterError(FlutterErrorDetails details) {}
}
