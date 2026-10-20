import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/esik_palette.dart';

/// Uygulamanın imza görseli: aralık bir kapıdan sızan ışık ve eşikte
/// duran bulanık bir siluet.
class ThresholdDoor extends StatelessWidget {
  const ThresholdDoor({super.key, this.doorWidth = 66, this.doorHeight = 112});

  final double doorWidth;
  final double doorHeight;

  static const _figure =
      'M50 38c-14 0-24 6-27 20l-9 50c-1 5 6 7 8 2l9-38 2 40-4 86h14l7-70 7 70h14l-4-86 2-40 9 38c2 5 9 3 8-2l-9-50c-3-14-13-20-27-20z';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final glowSize = doorWidth * 3.6;
    final figureHeight = doorHeight * 0.8;
    final hex =
        '#${(p.silhouette.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final figureSvg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 200">'
        '<circle cx="50" cy="22" r="13" fill="$hex"/><path d="$_figure" fill="$hex"/></svg>';

    return ExcludeSemantics(
      child: SizedBox(
        width: glowSize,
        height: doorHeight + doorWidth * 0.5,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: -doorHeight * 0.25,
              child: Container(
                width: glowSize,
                height: glowSize * 0.75,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      p.accent.withValues(alpha: 0.55),
                      p.accent.withValues(alpha: 0.15),
                      p.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: doorWidth,
              height: doorHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(doorWidth / 2),
                  bottom: const Radius.circular(3),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: p.doorLight,
                  stops: const [0, 0.55, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.55),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: SvgPicture.string(figureSvg, height: figureHeight),
            ),
            Positioned(
              bottom: -14,
              child: Container(
                width: glowSize * 0.9,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: RadialGradient(
                    colors: [
                      p.accent.withValues(alpha: 0.45),
                      p.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
