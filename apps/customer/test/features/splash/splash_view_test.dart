import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_brand_colors.dart';
import 'package:core/theme/app_theme.dart';
import 'package:customer/features/splash/presentation/view/splash_view.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

final AppLocalizations _en = AppLocalizationsEn();

Widget _splash({Brightness brightness = Brightness.light}) => DesignScale(
  builder: (_) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SplashView(),
  ),
);

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
    await tester.pumpAndSettle();

    expect(_opacityOf(tester, _en.splashTagline), 1);
    expect(_opacityOf(tester, _en.splashFooter), 0.8);
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
  });
}
