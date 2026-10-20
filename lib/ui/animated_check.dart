import 'package:flutter/material.dart';

import '../theme/esik_palette.dart';

/// Tasarımdaki tik animasyonu (toplam 400 ms):
/// 1) boş halka, 2) basışta büzülme, 3) dolum + %120 taşma + dalga, 4) tik çizilir.
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    super.key,
    required this.checked,
    this.size = 42,
    this.pressed = false,
  });

  final bool checked;
  final double size;

  /// Parmak satırın üzerindeyken halka hafifçe büzülür.
  final bool pressed;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: widget.checked ? 1 : 0,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.2), weight: 55),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.2,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 45,
    ),
  ]).animate(_c);

  late final Animation<double> _wave = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.1, 0.9, curve: Curves.easeOut),
  );

  late final Animation<double> _draw = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.3, 0.95, curve: Curves.easeOut),
  );

  @override
  void didUpdateWidget(AnimatedCheck old) {
    super.didUpdateWidget(old);
    if (widget.checked != old.checked) {
      if (widget.checked) {
        _c.forward(from: 0);
      } else {
        _c.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = widget.size;
    if (!widget.checked) {
      return AnimatedScale(
        scale: widget.pressed ? 0.86 : 1,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.pressed ? p.text : p.text.withValues(alpha: 0.35),
              width: widget.pressed ? 2 : 1.5,
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final waveT = _wave.value;
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Dışa yayılan amber dalga.
              if (waveT > 0 && waveT < 1)
                Container(
                  width: s + 36 * waveT,
                  height: s + 36 * waveT,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.accent.withValues(alpha: 0.45 * (1 - waveT)),
                  ),
                ),
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.primaryButton,
                  ),
                  child: CustomPaint(
                    painter: _CheckPainter(
                      progress: _draw.value,
                      color: p.onPrimaryButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    // 24'lük tuvaldeki "M5 12.5l4.5 4.5L19 7.5" yolunun ortalanmış hâli.
    final u = size.width / 24 * 0.5;
    final o = Offset(size.width / 2 - 12 * u, size.height / 2 - 12 * u);
    final path = Path()
      ..moveTo(o.dx + 5 * u, o.dy + 12.5 * u)
      ..lineTo(o.dx + 9.5 * u, o.dy + 17 * u)
      ..lineTo(o.dx + 19 * u, o.dy + 7.5 * u);
    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      partial,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8 * u
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}
