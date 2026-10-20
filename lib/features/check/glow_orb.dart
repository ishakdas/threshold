import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/esik_palette.dart';

/// İlerledikçe parlayan amber küre ve çevresindeki ilerleme halkası.
class GlowOrb extends StatefulWidget {
  const GlowOrb({
    super.key,
    required this.progress,
    this.child,
    this.size = 236,
  });

  /// 0–1 arası tamamlanma oranı.
  final double progress;
  final Widget? child;
  final double size;

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  // Küre yavaşça "nefes alır".
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final orb = widget.size * 0.71;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, f, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(
                progress: f,
                track: p.text.withValues(alpha: 0.16),
                color: p.text,
              ),
            ),
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.04).animate(
                CurvedAnimation(parent: _breath, curve: Curves.easeInOut),
              ),
              child: Opacity(
                opacity: 0.35 + 0.65 * f,
                child: Container(
                  width: orb,
                  height: orb,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.24, -0.36),
                      radius: 0.75,
                      colors: [
                        Color(0xFFFFE9C8),
                        Color(0xFFFFB262),
                        Color(0xFFD9682A),
                      ],
                      stops: [0, 0.42, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA050)
                            .withValues(alpha: 0.35 + 0.35 * f),
                        blurRadius: 60 + 50 * f,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ?widget.child,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });

  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: c, radius: r);
    final dash = Paint()
      ..color = track
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const n = 90;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(rect, 2 * math.pi * i / n, 0.02, false, dash);
    }
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.progress != progress || o.color != color || o.track != track;
}
