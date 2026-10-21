import 'package:core/error/error_reporter.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/storage/onboarding_store.dart';
import 'package:customer/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_slide.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

class _Store implements OnboardingStore {
  _Store({this.fails = false});

  final bool fails;
  bool completed = false;

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> markOnboardingCompleted() async {
    if (fails) throw StateError('disk full');
    completed = true;
  }
}

class _Reporter implements ErrorReporter {
  @override
  void report(Object error, StackTrace stackTrace, {String? context}) {}

  @override
  void reportFlutterError(FlutterErrorDetails details) {}
}

const String _permissionMarker = 'location permission';

Future<void> _pump(WidgetTester tester, _Store store) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        onboardingStoreProvider.overrideWithValue(store),
        errorReporterProvider.overrideWithValue(_Reporter()),
      ],
      child: testApp(
        home: const OnboardingView(),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            body: Text(
              settings.name == Routes.locationPermission
                  ? _permissionMarker
                  : '',
            ),
          ),
        ),
      ),
    ),
  );
}

/// The slide whose title is on screen and not covered.
OnboardingSlide _onScreen(WidgetTester tester) =>
    OnboardingSlide.values.singleWhere(
      (slide) => tester.any(find.text(slide.title(_en)).hitTestable()),
    );

void main() {
  testWidgets('Next walks through the pages; Skip leaves on the last', (
    tester,
  ) async {
    await _pump(tester, _Store());
    expect(_onScreen(tester), OnboardingSlide.genuine);
    expect(find.text(_en.onboardingSkip).hitTestable(), findsOneWidget);

    await tester.tap(find.text(_en.onboardingNext));
    await tester.pumpAndSettle();
    expect(_onScreen(tester), OnboardingSlide.fast);

    await tester.tap(find.text(_en.onboardingNext));
    await tester.pumpAndSettle();
    expect(_onScreen(tester), OnboardingSlide.pay);
    expect(find.text(_en.onboardingSkip).hitTestable(), findsNothing);
    expect(find.text(_en.onboardingGetStarted), findsOneWidget);
    expect(find.text(_en.onboardingContinueAsGuest), findsOneWidget);
  });

  testWidgets('swiping moves between pages and back returns a page', (
    tester,
  ) async {
    await _pump(tester, _Store());

    await tester.fling(
      find.byType(PageView),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(_onScreen(tester), OnboardingSlide.fast);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(_onScreen(tester), OnboardingSlide.genuine);
  });

  for (final label in ['skip', 'get started', 'guest']) {
    testWidgets('$label records onboarding and opens the location step', (
      tester,
    ) async {
      final store = _Store();
      await _pump(tester, store);
      if (label != 'skip') {
        for (var i = 0; i < 2; i++) {
          await tester.tap(find.text(_en.onboardingNext));
          await tester.pumpAndSettle();
        }
      }

      await tester.tap(
        find.text(switch (label) {
          'skip' => _en.onboardingSkip,
          'get started' => _en.onboardingGetStarted,
          _ => _en.onboardingContinueAsGuest,
        }),
      );
      await tester.pumpAndSettle();

      expect(store.completed, isTrue);
      expect(find.text(_permissionMarker), findsOneWidget);
    });
  }

  testWidgets('a failed save stays on the page and says so', (tester) async {
    await _pump(tester, _Store(fails: true));

    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();

    expect(find.text(_en.onboardingSaveFailed), findsOneWidget);
    expect(find.byType(OnboardingView), findsOneWidget);
  });

  testWidgets('under reduced motion Next jumps to the page', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    await _pump(tester, _Store());

    await tester.tap(find.text(_en.onboardingNext));
    await tester.pump();

    expect(_onScreen(tester), OnboardingSlide.fast);
  });

  testWidgets('Skip keeps its label in place and its ripple off the edge', (
    tester,
  ) async {
    await _pump(tester, _Store());
    final label = tester.getRect(find.text(_en.onboardingSkip));
    final button = tester.getRect(
      find.ancestor(
        of: find.text(_en.onboardingSkip),
        matching: find.byType(TextButton),
      ),
    );

    expect(label.right, moreOrLessEquals(393 - 20, epsilon: 0.5));
    expect(button.right, lessThanOrEqualTo(393 - 8));
    expect(button.height, greaterThanOrEqualTo(48));
  });
}
