import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/esik_palette.dart';
import 'esik_icons.dart';

class GlassTab {
  const GlassTab({required this.icon, required this.label});
  final EsikIcon icon;
  final String label;
}

/// Yüzen cam sekme çubuğu. Ortadaki amber hap, uygulamanın ana eylemi
/// "Kontrol et"tir. Cam efekti yalnızca burada ve ana butonda kullanılır.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onPrimary,
  }) : assert(tabs.length == 4);

  final List<GlassTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget tab(int i) {
      final selected = i == currentIndex;
      return Semantics(
        selected: selected,
        button: true,
        label: tabs[i].label,
        child: InkResponse(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(i);
          },
          radius: 28,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: EsikIconView(
                tabs[i].icon,
                color: selected ? p.text : p.textMuted,
                strokeWidth: selected ? 2.2 : 1.6,
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(33),
        boxShadow: [
          BoxShadow(
            color: p.glassShadow,
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(33),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: p.glassFill,
              borderRadius: BorderRadius.circular(33),
              border: Border.all(color: p.glassBorder),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [p.glassHighlight.withValues(alpha: 0.12), p.glassFill],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tab(0),
                tab(1),
                _PrimaryPill(onTap: onPrimary),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Kontrol et',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: 78,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: p.accentGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: p.accentGradient.last.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: const Border(top: BorderSide(color: Color(0x73FFFFFF))),
          ),
          child: const Center(
            child: EsikIconView(
              EsikIcon.check,
              color: Colors.white,
              strokeWidth: 2.4,
            ),
          ),
        ),
      ),
    );
  }
}
