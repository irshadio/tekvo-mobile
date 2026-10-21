import 'package:core/presentation/widgets/design_scale.dart';
import 'package:customer/features/product/presentation/view/questions_view.dart';
import 'package:customer/features/product/product_overrides.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final AppLocalizations _en = AppLocalizationsEn();
const String _id = 'nova-x-pro';

Future<void> _pump(WidgetTester tester, {bool ask = false}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = DesignScale.designSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: productOverrides,
      child: testApp(
        home: Scaffold(
          body: QuestionsView(id: _id, ask: ask),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

final Finder _page = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _page.first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the most helpful first', (tester) async {
    await _pump(tester);

    expect(find.text(_en.productQuestionsSummary('38', '112')), findsOne);
    final battery = tester.getTopLeft(
      find.text('How long does the battery last with heavy use?'),
    );
    final calls = tester.getTopLeft(
      find.text('Does the UAE version support FaceTime and WhatsApp calls?'),
    );
    expect(battery.dy, lessThan(calls.dy));
  });

  testWidgets('a topic keeps only its questions', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(find.text('Can I record 8K video at 30 fps?'), findsOneWidget);
    expect(find.text('Does it support dual eSIM?'), findsNothing);
  });

  testWidgets('search narrows the list after a pause', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'charger');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Is a charger included in the box?'), findsOneWidget);
    expect(find.text('Does it support dual eSIM?'), findsNothing);
  });

  testWidgets('See all answers unfolds the others', (tester) async {
    await _pump(tester);
    const other = 'I use du and Etisalat eSIMs together with no issues.';

    await _reveal(tester, find.text(_en.productSeeAnswers(3)));
    expect(find.text(other), findsNothing);
    await tester.tap(find.text(_en.productSeeAnswers(3)));
    await tester.pumpAndSettle();

    expect(find.text(other), findsOneWidget);
    expect(find.text(_en.productFewerAnswers), findsOneWidget);
  });

  testWidgets('asking posts and says so', (tester) async {
    await _pump(tester);

    await _reveal(tester, find.text(_en.productAskQuestion));
    await tester.tap(find.text(_en.productAskQuestion));
    await tester.pumpAndSettle();
    expect(find.text(_en.productPostQuestion), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'Does it come with a case?',
    );
    await tester.pump();
    expect(find.text(_en.productTextCounter(25, 250)), findsOneWidget);
    await tester.tap(find.text(_en.productPostQuestion));
    await tester.pumpAndSettle();

    expect(find.text(_en.productPostQuestion), findsNothing);
    expect(find.text(_en.productQuestionPosted), findsOneWidget);
  });

  testWidgets('answering names the question', (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_en.productAnswerAction).first);
    await tester.pumpAndSettle();

    expect(find.text(_en.productAnswerTitle), findsOneWidget);
    expect(
      find.text('How long does the battery last with heavy use?'),
      findsWidgets,
    );
  });

  testWidgets('opens with the ask sheet when asked to', (tester) async {
    await _pump(tester, ask: true);

    expect(find.text(_en.productPostQuestion), findsOneWidget);
  });
}
