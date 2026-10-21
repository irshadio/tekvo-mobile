import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// One state of the splash in design pixels (393 x 852): the Figma frames
/// "Intro", "Reveal" and "Loading", and every frame the smart-animate
/// transitions pass through between them.
@immutable
class SplashFrame {
  const SplashFrame({
    required this.logoSize,
    required this.logoTop,
    required this.wordmarkTop,
    required this.wordmarkOpacity,
    required this.taglineTop,
    required this.taglineOpacity,
    required this.loaderOpacity,
    required this.footerOpacity,
    required this.glowPrimaryTop,
    required this.glowPrimaryOpacity,
    required this.glowAccentStart,
    required this.glowAccentTop,
    required this.glowAccentOpacity,
  });

  /// The frame at [t], a fraction of [timeline]: intro, an ease-out morph to
  /// the reveal, a hold, then an ease-in-out morph to loading.
  factory SplashFrame.at(double t) {
    final total = timeline.inMicroseconds;
    double point(Duration d) => d.inMicroseconds / total;
    final revealStart = point(introHold);
    final revealEnd = point(introHold + revealMorph);
    final loadingStart = point(introHold + revealMorph + revealHold);
    if (t >= loadingStart) {
      final p = Interval(loadingStart, 1, curve: Curves.easeInOut).transform(t);
      return SplashFrame.lerp(reveal, loading, p);
    }
    final p = Interval(
      revealStart,
      revealEnd,
      curve: Curves.easeOut,
    ).transform(t.clamp(0, 1));
    return SplashFrame.lerp(intro, reveal, p);
  }

  /// The frame [t] of the way from [a] to [b].
  factory SplashFrame.lerp(SplashFrame a, SplashFrame b, double t) {
    double l(double x, double y) => lerpDouble(x, y, t)!;
    return SplashFrame(
      logoSize: l(a.logoSize, b.logoSize),
      logoTop: l(a.logoTop, b.logoTop),
      wordmarkTop: l(a.wordmarkTop, b.wordmarkTop),
      wordmarkOpacity: l(a.wordmarkOpacity, b.wordmarkOpacity),
      taglineTop: l(a.taglineTop, b.taglineTop),
      taglineOpacity: l(a.taglineOpacity, b.taglineOpacity),
      loaderOpacity: l(a.loaderOpacity, b.loaderOpacity),
      footerOpacity: l(a.footerOpacity, b.footerOpacity),
      glowPrimaryTop: l(a.glowPrimaryTop, b.glowPrimaryTop),
      glowPrimaryOpacity: l(a.glowPrimaryOpacity, b.glowPrimaryOpacity),
      glowAccentStart: l(a.glowAccentStart, b.glowAccentStart),
      glowAccentTop: l(a.glowAccentTop, b.glowAccentTop),
      glowAccentOpacity: l(a.glowAccentOpacity, b.glowAccentOpacity),
    );
  }

  final double logoSize;
  final double logoTop;
  final double wordmarkTop;
  final double wordmarkOpacity;
  final double taglineTop;
  final double taglineOpacity;
  final double loaderOpacity;
  final double footerOpacity;
  final double glowPrimaryTop;
  final double glowPrimaryOpacity;
  final double glowAccentStart;
  final double glowAccentTop;
  final double glowAccentOpacity;

  /// The mark alone, small and centred.
  static const SplashFrame intro = SplashFrame(
    logoSize: 56,
    logoTop: 398,
    wordmarkTop: 470,
    wordmarkOpacity: 0,
    taglineTop: 500,
    taglineOpacity: 0,
    loaderOpacity: 0,
    footerOpacity: 0,
    glowPrimaryTop: 300,
    glowPrimaryOpacity: 0,
    glowAccentStart: 250,
    glowAccentTop: 520,
    glowAccentOpacity: 0,
  );

  /// The mark grows and rises, the wordmark slides in, the glows light up.
  static const SplashFrame reveal = SplashFrame(
    logoSize: 88,
    logoTop: 300,
    wordmarkTop: 420,
    wordmarkOpacity: 1,
    taglineTop: 480,
    taglineOpacity: 0,
    loaderOpacity: 0,
    footerOpacity: 0,
    glowPrimaryTop: 180,
    glowPrimaryOpacity: 0.63,
    glowAccentStart: 230,
    glowAccentTop: 470,
    glowAccentOpacity: 0.45,
  );

  /// The settled lockup with the tagline, loader and footer.
  static const SplashFrame loading = SplashFrame(
    logoSize: 72,
    logoTop: 312,
    wordmarkTop: 412,
    wordmarkOpacity: 1,
    taglineTop: 472,
    taglineOpacity: 1,
    loaderOpacity: 1,
    footerOpacity: 0.8,
    glowPrimaryTop: 160,
    glowPrimaryOpacity: 0.54,
    glowAccentStart: 210,
    glowAccentTop: 450,
    glowAccentOpacity: 0.4,
  );

  /// How long the intro holds, then how long it morphs into the reveal.
  static const Duration introHold = Duration(milliseconds: 600);
  static const Duration revealMorph = Duration(milliseconds: 600);

  /// How long the reveal holds, then how long it morphs into loading.
  static const Duration revealHold = Duration(milliseconds: 500);
  static const Duration loadingMorph = Duration(milliseconds: 800);

  /// The whole timeline, from the intro to the settled loading frame.
  static Duration get timeline =>
      introHold + revealMorph + revealHold + loadingMorph;
}
