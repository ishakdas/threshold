import 'package:flutter/material.dart';

import '../core/day_mode.dart';
import 'esik_palette.dart';

/// Tasarımdaki tipografi: büyük ve ince başlıklar, sakin gövde metni.
TextTheme _textTheme(Color text) => TextTheme(
  displayLarge: TextStyle(
    fontSize: 46,
    height: 50 / 46,
    fontWeight: FontWeight.w300,
    letterSpacing: -1,
    color: text,
  ),
  headlineLarge: TextStyle(
    fontSize: 38,
    height: 44 / 38,
    fontWeight: FontWeight.w300,
    letterSpacing: -1,
    color: text,
  ),
  headlineMedium: TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.6,
    color: text,
  ),
  titleLarge: TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    color: text,
  ),
  titleMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: text,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w300,
    color: text,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w300,
    color: text,
  ),
  labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: text),
  labelMedium: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: text,
  ),
  labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: text),
);

ThemeData esikTheme(DayMode mode) {
  final palette = mode == DayMode.evening
      ? EsikPalette.evening
      : EsikPalette.morning;
  final brightness = mode == DayMode.evening
      ? Brightness.dark
      : Brightness.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: palette.backgroundGradient.last,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      surface: palette.backgroundGradient.last,
      onSurface: palette.text,
    ),
    textTheme: _textTheme(palette.text),
    splashFactory: InkSparkle.splashFactory,
    extensions: [palette],
  );
}
