import 'package:core/presentation/extensions/form_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _fieldHeight = 100.0;
const _viewportHeight = 300.0;

void main() {
  late GlobalKey<FormState> form;
  late ScrollController scroll;

  /// Ten 100-tall fields in a 300-tall scroll view; [invalid] fail.
  Future<void> pump(WidgetTester tester, Set<int> invalid) async {
    form = GlobalKey<FormState>();
    scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: _viewportHeight,
            child: SingleChildScrollView(
              controller: scroll,
              child: Form(
                key: form,
                child: Column(
                  children: <Widget>[
                    for (var i = 0; i < 10; i++)
                      FormField<String>(
                        key: ValueKey<int>(i),
                        validator: (_) => invalid.contains(i) ? 'Bad' : null,
                        builder: (_) => const SizedBox(height: _fieldHeight),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect field(WidgetTester tester, int i) =>
      tester.getRect(find.byKey(ValueKey<int>(i)));

  testWidgets('a valid form passes and does not scroll', (tester) async {
    await pump(tester, <int>{});

    expect(form.currentState!.validateAndReveal(), isTrue);
    await tester.pumpAndSettle();

    expect(scroll.offset, 0);
  });

  testWidgets('scrolls up to the topmost invalid field below the fold', (
    tester,
  ) async {
    await pump(tester, <int>{8, 6});

    expect(form.currentState!.validateAndReveal(), isFalse);
    await tester.pumpAndSettle();

    // Field 6 ends at the viewport's bottom.
    expect(field(tester, 6).bottom, _viewportHeight);
  });

  testWidgets('scrolls back to an invalid field above the viewport', (
    tester,
  ) async {
    await pump(tester, <int>{1});
    scroll.jumpTo(500);
    await tester.pump();

    expect(form.currentState!.validateAndReveal(), isFalse);
    await tester.pumpAndSettle();

    expect(field(tester, 1).top, 0);
  });

  testWidgets('leaves a visible invalid field where it is', (tester) async {
    await pump(tester, <int>{1, 7});

    expect(form.currentState!.validateAndReveal(), isFalse);
    await tester.pumpAndSettle();

    expect(scroll.offset, 0);
  });
}
