import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/esik_palette.dart';

class DayStripEntry {
  const DayStripEntry({
    required this.day,
    required this.weekday,
    required this.progress,
    this.isToday = false,
    this.isFuture = false,
  });

  final int day;
  final String weekday;

  /// 0, 0.5 ya da 1: o günün iki eşiğinden kaçı tamamlandı.
  final double progress;
  final bool isToday;
  final bool isFuture;
}

/// Bugünü ortalayan, kenarlara doğru alçalan ve soluklaşan gün şeridi.
/// Her günün halkası o günün iki eşiğinden kaçının tamamlandığını gösterir.
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.entries})
    : assert(entries.length == 7);

  final List<DayStripEntry> entries;

  static const _drop = [30.0, 14.0, 4.0, 0.0, 4.0, 14.0, 30.0];
  static const _fade = [0.45, 0.8, 0.9, 1.0, 0.75, 0.6, 0.4];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SizedBox(
        height: 110,
        child: OverflowBox(
          minWidth: c.maxWidth + 68,
          maxWidth: c.maxWidth + 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 7; i++)
                Padding(
                  padding: EdgeInsets.only(top: _drop[i]),
                  child: Opacity(opacity: _fade[i], child: _Day(entries[i])),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day(this.e);
  final DayStripEntry e;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final size = e.isToday ? 46.0 : 42.0;
    return Semantics(
      label:
          '${e.day}, ${e.weekday}${e.isFuture ? '' : ', ${(e.progress * 2).round()} eşik tamamlandı'}',
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            width: size + 8,
            height: size + 8,
            child: CustomPaint(
              painter: _RingPainter(
                progress: e.isFuture ? 0 : e.progress,
                today: e.isToday,
                color: e.isToday ? p.text : p.accent,
                track: p.text.withValues(alpha: e.isToday ? 0.3 : 0.18),
              ),
              child: Center(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.chip.withValues(alpha: e.isToday ? 0.7 : 0.35),
                    border: e.isFuture ? Border.all(color: p.chipBorder) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${e.day}',
                    style: TextStyle(
                      fontSize: e.isToday ? 16 : 15,
                      fontWeight: e.isToday ? FontWeight.w500 : FontWeight.w300,
                      color: p.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            e.weekday,
            style: t.labelMedium?.copyWith(
              fontSize: e.isToday ? 15 : 14,
              fontWeight: e.isToday ? FontWeight.w500 : FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.today,
    required this.color,
    required this.track,
  });

  final double progress;
  final bool today;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 1.5;
    final c = size.center(Offset.zero);
    if (today) {
      // Kesikli iz: bugün henüz bitmedi.
      final dash = Paint()
        ..color = track
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      const n = 40;
      for (var i = 0; i < n; i++) {
        final a = 2 * math.pi * i / n;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          a,
          0.05,
          false,
          dash,
        );
      }
    } else if (progress > 0 && progress < 1) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = track
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = today ? 2 : 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.progress != progress ||
      o.color != color ||
      o.track != track ||
      o.today != today;
}

const turkishWeekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const turkishWeekdayInitials = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
