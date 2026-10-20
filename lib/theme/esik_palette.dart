import 'package:flutter/material.dart';

/// Eşik'in renk token'ları. Akşam (lacivert + amber) ve sabah (krem + amber)
/// aynı ailenin iki hâlidir; ekranlar renkleri yalnızca buradan okur.
@immutable
class EsikPalette extends ThemeExtension<EsikPalette> {
  const EsikPalette({
    required this.backgroundGradient,
    required this.glowStops,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.surfaceTop,
    required this.surfaceBottom,
    required this.surfaceBorder,
    required this.chip,
    required this.chipBorder,
    required this.accent,
    required this.accentGradient,
    required this.primaryButton,
    required this.onPrimaryButton,
    required this.glassFill,
    required this.glassBorder,
    required this.glassHighlight,
    required this.glassShadow,
    required this.doorLight,
    required this.silhouette,
  });

  final List<Color> backgroundGradient;
  final List<Color> glowStops;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color surfaceTop;
  final Color surfaceBottom;
  final Color surfaceBorder;
  final Color chip;
  final Color chipBorder;
  final Color accent;
  final List<Color> accentGradient;
  final Color primaryButton;
  final Color onPrimaryButton;
  final Color glassFill;
  final Color glassBorder;
  final Color glassHighlight;
  final Color glassShadow;
  final List<Color> doorLight;
  final Color silhouette;

  static const evening = EsikPalette(
    backgroundGradient: [
      Color(0xFF151B3E),
      Color(0xFF0B1029),
      Color(0xFF060A1A),
    ],
    glowStops: [
      Color(0xF2FFB25C),
      Color(0x8CF08030),
      Color(0x38783C46),
      Color(0x000B1029),
    ],
    text: Color(0xFFF5EFE6),
    textMuted: Color(0xB3F5EFE6),
    textFaint: Color(0x99F5EFE6),
    surfaceTop: Color(0x12FFFFFF),
    surfaceBottom: Color(0x06FFFFFF),
    surfaceBorder: Color(0x12FFFFFF),
    chip: Color(0x24FFFFFF),
    chipBorder: Color(0x2EFFFFFF),
    accent: Color(0xFFFFB25C),
    accentGradient: [Color(0xFFFFB86A), Color(0xFFEF8636)],
    primaryButton: Color(0xFFFFFFFF),
    onPrimaryButton: Color(0xFF0B1029),
    glassFill: Color(0x801C2246),
    glassBorder: Color(0x1FFFFFFF),
    glassHighlight: Color(0x29FFFFFF),
    glassShadow: Color(0x73000000),
    doorLight: [Color(0xF2FFE8C4), Color(0xD9FFB868), Color(0x59F2963C)],
    silhouette: Color(0xFF141A3A),
  );

  static const morning = EsikPalette(
    backgroundGradient: [
      Color(0xFFFBE6CE),
      Color(0xFFF7EEE3),
      Color(0xFFF3ECE2),
    ],
    glowStops: [
      Color(0xD9FFAA5A),
      Color(0x73FFBE82),
      Color(0x33FFE1BE),
      Color(0x00F7EEE3),
    ],
    text: Color(0xFF2B1D12),
    textMuted: Color(0xB82B1D12),
    textFaint: Color(0x9E2B1D12),
    surfaceTop: Color(0x33FFFFFF),
    surfaceBottom: Color(0xE6FFFCF7),
    surfaceBorder: Color(0xCCFFFFFF),
    chip: Color(0x8CFFFFFF),
    chipBorder: Color(0xD9FFFFFF),
    accent: Color(0xFFE8822E),
    accentGradient: [Color(0xFFFFB86A), Color(0xFFEF8636)],
    primaryButton: Color(0xFF2B1D12),
    onPrimaryButton: Color(0xFFFBF5EC),
    glassFill: Color(0x80FFFFFF),
    glassBorder: Color(0xE6FFFFFF),
    glassHighlight: Color(0xF2FFFFFF),
    glassShadow: Color(0x24784614),
    doorLight: [Color(0xFFFFFFFF), Color(0xFFFFE6C4), Color(0x99FFBE78)],
    silhouette: Color(0xFF8A5A36),
  );

  @override
  EsikPalette copyWith() => this;

  @override
  EsikPalette lerp(EsikPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> l(List<Color> a, List<Color> b) => [
      for (var i = 0; i < a.length; i++) c(a[i], b[i]),
    ];
    return EsikPalette(
      backgroundGradient: l(backgroundGradient, other.backgroundGradient),
      glowStops: l(glowStops, other.glowStops),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      surfaceTop: c(surfaceTop, other.surfaceTop),
      surfaceBottom: c(surfaceBottom, other.surfaceBottom),
      surfaceBorder: c(surfaceBorder, other.surfaceBorder),
      chip: c(chip, other.chip),
      chipBorder: c(chipBorder, other.chipBorder),
      accent: c(accent, other.accent),
      accentGradient: l(accentGradient, other.accentGradient),
      primaryButton: c(primaryButton, other.primaryButton),
      onPrimaryButton: c(onPrimaryButton, other.onPrimaryButton),
      glassFill: c(glassFill, other.glassFill),
      glassBorder: c(glassBorder, other.glassBorder),
      glassHighlight: c(glassHighlight, other.glassHighlight),
      glassShadow: c(glassShadow, other.glassShadow),
      doorLight: l(doorLight, other.doorLight),
      silhouette: c(silhouette, other.silhouette),
    );
  }
}

extension EsikPaletteContext on BuildContext {
  EsikPalette get palette => Theme.of(this).extension<EsikPalette>()!;
}
