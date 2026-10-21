import 'dart:async';

import 'package:core/network/connectivity.dart';
import 'package:core/network/network_banner.dart';
import 'package:core/presentation/widgets/offline_banner.dart';
import 'package:core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y_guidelines.dart';
import '../../support/design_screen.dart';
import '../../support/reduced_motion.dart';
import '../../support/test_app.dart';

const Key _content = Key('content');

final Finder _message = find.text(en.offlineBanner);
final Finder _online = find.ancestor(
  of: find.text(en.onlineBanner),
  matching: find.byType(AnimatedContainer),
);
final Finder _strip = find.ancestor(
  of: _message,
  matching: find.byType(AnimatedContainer),
);

/// A screen reaching the bottom edge, reporting the inset it is given.
Widget _screen() => Scaffold(
  body: Builder(
    builder: (context) => SizedBox.expand(
      key: _content,
      child: Text('inset ${MediaQuery.paddingOf(context).bottom}'),
    ),
  ),
);

void main() {
  late StreamController<bool> status;

  setUp(() => status = StreamController<bool>());
  tearDown(() => status.close());

  Future<void> pump(WidgetTester tester) async {
    useDesignScreen(tester);
    tester.view
      ..padding = const FakeViewPadding(bottom: 34)
      ..viewPadding = const FakeViewPadding(bottom: 34);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityStatusProvider.overrideWith((ref) => status.stream),
        ],
        child: testApp(
          home: _screen(),
          builder: (_, child) => OfflineBanner(child: child!),
        ),
      ),
    );
  }

  Future<void> go(WidgetTester tester, {required bool online}) async {
    status.add(online);
    await tester.pump();
    await tester.pump(OfflineBanner.duration);
  }

  testWidgets('online, takes no space and leaves the screen its inset', (
    tester,
  ) async {
    await pump(tester);
    await go(tester, online: true);

    expect(_message, findsNothing);
    expect(find.text('inset 34.0'), findsOneWidget);
    expect(tester.getBottomLeft(find.byKey(_content)).dy, 852);
  });

  testWidgets('takes no space while the status is unknown', (tester) async {
    await pump(tester);

    expect(_message, findsNothing);
    expect(tester.getBottomLeft(find.byKey(_content)).dy, 852);
  });

  testWidgets('offline, fills the inset and the screen ends above it', (
    tester,
  ) async {
    await pump(tester);
    await go(tester, online: false);

    expect(_message.hitTestable(), findsOneWidget);
    expect(find.text('inset 0.0'), findsOneWidget);
    final strip = tester.getRect(_strip.first);
    expect(strip.bottom, 852);
    expect(strip.height, 34);
    expect(tester.getBottomLeft(find.byKey(_content)).dy, strip.top);
  });

  testWidgets('the screen keeps its safe edge while the strip animates', (
    tester,
  ) async {
    await pump(tester);
    await go(tester, online: true);

    double safeBottom() {
      final inset = double.parse(
        tester
            .widget<Text>(find.textContaining('inset '))
            .data!
            .substring('inset '.length),
      );
      return tester.getBottomLeft(find.byKey(_content)).dy - inset;
    }

    final before = safeBottom();
    status.add(false);
    await tester.pump();
    for (var step = 0; step < 4; step++) {
      await tester.pump(OfflineBanner.duration ~/ 4);
      expect(safeBottom(), moreOrLessEquals(before, epsilon: 0.5));
    }
  });

  testWidgets('going offline and back keeps the app mounted', (tester) async {
    var mounts = 0;
    useDesignScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityStatusProvider.overrideWith((ref) => status.stream),
        ],
        child: testApp(
          home: _screen(),
          builder: (_, child) => OfflineBanner(
            child: _Mounts(onMount: () => mounts++, child: child!),
          ),
        ),
      ),
    );
    await go(tester, online: true);

    await go(tester, online: false);
    await tester.pumpAndSettle();
    await go(tester, online: true);
    await tester.pumpAndSettle();

    expect(mounts, 1);
  });

  testWidgets('under Android button navigation, sits above the inset', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pump(tester);
    tester.view
      ..padding = const FakeViewPadding(bottom: 48)
      ..viewPadding = const FakeViewPadding(bottom: 48);
    await go(tester, online: false);

    final strip = tester.getRect(_strip.first);
    expect(strip.bottom, 852 - 48);
    expect(tester.getBottomLeft(find.byKey(_content)).dy, strip.top);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('steps aside while the keyboard is up', (tester) async {
    await pump(tester);
    await go(tester, online: false);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(_message, findsNothing);
  });

  testWidgets('back online, says so in green, then leaves', (tester) async {
    await pump(tester);
    await go(tester, online: false);
    final full = 852 - tester.getBottomLeft(find.byKey(_content)).dy;

    await go(tester, online: true);
    await tester.pump(OfflineBanner.switchDuration);
    expect(_message, findsNothing);
    expect(find.text(en.onlineBanner), findsOneWidget);
    await tester.pump(OfflineBanner.switchDuration);
    expect(
      (tester.widget<AnimatedContainer>(_online.first).decoration!
              as BoxDecoration)
          .color,
      AppColors.light.statusSuccess,
    );

    await tester.pump(NetworkBannerStatus.onlineFor);
    await tester.pump(OfflineBanner.duration ~/ 2);
    final half = 852 - tester.getBottomLeft(find.byKey(_content)).dy;
    expect(half, greaterThan(0));
    expect(half, lessThan(full));

    await tester.pump(OfflineBanner.duration);
    expect(find.text(en.onlineBanner), findsNothing);
    expect(tester.getBottomLeft(find.byKey(_content)).dy, 852);
  });

  testWidgets('online from the start, never says so', (tester) async {
    await pump(tester);
    await go(tester, online: true);

    expect(find.text(en.onlineBanner), findsNothing);
  });

  testWidgets('appears at once under reduced motion', (tester) async {
    useReducedMotion(tester);
    await pump(tester);
    status.add(false);
    await tester.pump();
    await tester.pump();

    expect(_message, findsOneWidget);
    final shown = tester.widget<SizeTransition>(
      find.ancestor(of: _message, matching: find.byType(SizeTransition)),
    );
    expect(shown.sizeFactor.value, 1);
  });

  testWidgets('announces itself', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    await go(tester, online: false);

    expect(
      tester.getSemantics(_message),
      isSemantics(isLiveRegion: true, label: en.offlineBanner),
    );
    semantics.dispose();
  });
}

class _Mounts extends StatefulWidget {
  const _Mounts({required this.onMount, required this.child});

  final VoidCallback onMount;
  final Widget child;

  @override
  State<_Mounts> createState() => _MountsState();
}

class _MountsState extends State<_Mounts> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
