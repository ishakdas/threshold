import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/esik_palette.dart';

/// Her ekranın zemini: dikey renk geçişi ve tepeden yayılan sıcak ışık.
/// Durum çubuğu ikonlarının rengini de moda göre ayarlar.
class Atmosphere extends StatelessWidget {
  const Atmosphere({super.key, required this.child, this.glowTop = -330});

  final Widget child;

  /// Işık halkasının merkezinin üst kenara göre yeri. Ekrana göre kaydırılır.
  final double glowTop;

  static const double _glowSize = 760;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: p.backgroundGradient,
            stops: const [0, 0.45, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: glowTop,
              left: 0,
              right: 0,
              height: _glowSize,
              child: IgnorePointer(
                // Işık ekran genişliğinden büyüktür; kenarlardan taşar.
                child: OverflowBox(
                  minWidth: _glowSize,
                  maxWidth: _glowSize,
                  minHeight: _glowSize,
                  maxHeight: _glowSize,
                  child: Container(
                    width: _glowSize,
                    height: _glowSize,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: p.glowStops,
                        stops: const [0, 0.32, 0.62, 1],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}
