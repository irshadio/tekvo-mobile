import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/widgets/app_text_field.dart';
import 'package:core/theme/app_color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/design_screen.dart';
import '../../support/test_app.dart';

void main() {
  Future<FocusNode> pump(WidgetTester tester, {bool white = true}) async {
    useDesignScreen(tester);
    final focus = FocusNode();
    final controller = TextEditingController();
    addTearDown(focus.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      testApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            focusNode: focus,
            icon: Assets.iconsMail,
            hint: 'you@example.com',
            whiteWhenFocused: white,
          ),
        ),
      ),
    );
    return focus;
  }

  Color? fill(WidgetTester tester) =>
      (tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration)
          .color;

  testWidgets('turns white with an outline while focused', (tester) async {
    final focus = await pump(tester);

    expect(fill(tester), appLightColorScheme.surfaceContainerHigh);
    expect(tester.getSize(find.byType(AppTextField)).height, 54);

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(fill(tester), appLightColorScheme.surfaceContainerLowest);
  });

  testWidgets('a search keeps its tint while focused', (tester) async {
    final focus = await pump(tester, white: false);

    focus.requestFocus();
    await tester.pumpAndSettle();

    expect(fill(tester), appLightColorScheme.surfaceContainerHigh);
  });
}
