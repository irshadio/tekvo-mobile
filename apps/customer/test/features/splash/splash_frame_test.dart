import 'package:customer/features/splash/presentation/view/widgets/splash_frame.dart';
import 'package:flutter_test/flutter_test.dart';

double _at(Duration d) =>
    d.inMicroseconds / SplashFrame.timeline.inMicroseconds;

void main() {
  test('the timeline follows the prototype: 0.6 + 0.6 + 0.5 + 0.8 s', () {
    expect(SplashFrame.timeline, const Duration(milliseconds: 2500));
  });

  test('holds the intro, then morphs to the reveal', () {
    expect(SplashFrame.at(0).logoSize, SplashFrame.intro.logoSize);
    expect(
      SplashFrame.at(_at(SplashFrame.introHold)).logoTop,
      SplashFrame.intro.logoTop,
    );
    final reveal = SplashFrame.at(
      _at(SplashFrame.introHold + SplashFrame.revealMorph),
    );
    expect(reveal.logoSize, SplashFrame.reveal.logoSize);
    expect(reveal.wordmarkOpacity, 1);
    expect(reveal.taglineOpacity, 0);
  });

  test('the reveal morph eases out', () {
    final half = SplashFrame.at(
      _at(SplashFrame.introHold + SplashFrame.revealMorph * 0.5),
    );
    // More than halfway from 56 to 88 at half the time.
    expect(half.logoSize, greaterThan(72));
  });

  test('holds the reveal, then settles into loading', () {
    final held = SplashFrame.at(
      _at(
        SplashFrame.introHold +
            SplashFrame.revealMorph +
            SplashFrame.revealHold,
      ),
    );
    expect(held.logoSize, SplashFrame.reveal.logoSize);
    final end = SplashFrame.at(1);
    expect(end.logoSize, SplashFrame.loading.logoSize);
    expect(end.taglineOpacity, 1);
    expect(end.loaderOpacity, 1);
    expect(end.footerOpacity, 0.8);
    expect(end.glowPrimaryOpacity, 0.54);
  });
}
