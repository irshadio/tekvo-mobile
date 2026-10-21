import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_brand_colors.dart';
import 'package:customer/features/splash/presentation/view/splash_view.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_frame.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();

const String _onboardingMarker = 'onboarding';

Widget _splash({Brightness brightness = Brightness.light}) => testApp(
  themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  home: const SplashView(),
  onGenerateRoute: (settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Text(
      settings.name == Routes.onboarding ? _onboardingMarker : '',
      textDirection: TextDirection.ltr,
    ),
  ),
);

/// Lets the hold and the hand-off run out, so no timer outlives the test.
Future<void> _finish(WidgetTester tester) =>
    tester.pump(SplashView.hold + SplashView.handOff);

double _opacityOf(WidgetTester tester, String text) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

void _designScreen(WidgetTester tester) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('reveals the wordmark, then the tagline and footer', (
    tester,
  ) async {
    _designScreen(tester);
    await tester.pumpWidget(_splash());

    expect(_opacityOf(tester, _en.brandWordmark), 0);
    expect(_opacityOf(tester, _en.splashTagline), 0);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(_opacityOf(tester, _en.brandWordmark), 1);
    expect(_opacityOf(tester, _en.splashTagline), 0);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(_opacityOf(tester, _en.splashTagline), 1);
    expect(_opacityOf(tester, _en.splashFooter), 0.8);
    await _finish(tester);
  });

  testWidgets('holds the settled frame, then hands over to onboarding', (
    tester,
  ) async {
    _designScreen(tester);
    await tester.pumpWidget(_splash());
    // One more frame: the timeline starts on the frame after mounting.
    await tester.pump(SplashFrame.timeline);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(SplashView.hold - const Duration(milliseconds: 100));
    expect(find.text(_onboardingMarker), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(SplashView.handOff);
    expect(find.text(_onboardingMarker), findsOneWidget);
  });

  testWidgets('under reduced motion it shows the settled frame at once', (
    tester,
  ) async {
    _designScreen(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await tester.pumpWidget(_splash());
    await tester.pump();

    expect(_opacityOf(tester, _en.splashTagline), 1);
    expect(_opacityOf(tester, _en.splashFooter), 0.8);
    await _finish(tester);
  });

  testWidgets('dark mode draws on the brand blue with the inverse mark', (
    tester,
  ) async {
    _designScreen(tester);
    await tester.pumpWidget(_splash(brightness: Brightness.dark));

    final background = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(SplashView),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(background.color, AppBrandColors.dark.background);
    final mark = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (mark.bytesLoader as SvgAssetLoader).assetName,
      Assets.brandLogoMarkDark,
    );
    await tester.pump(SplashFrame.timeline);
    await _finish(tester);
  });
}
