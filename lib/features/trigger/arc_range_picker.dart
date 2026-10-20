import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/esik_icons.dart';

/// Yarım daire üzerinde iki tutamaçlı saat aralığı seçici.
/// Yayın solu [arcStart], sağı [arcStart] + [spanMinutes]'tır.
class ArcRangePicker extends StatefulWidget {
  const ArcRangePicker({
    super.key,
    required this.arcStart,
    required this.spanMinutes,
    required this.start,
    required this.end,
    required this.onChanged,
    required this.startIcon,
    this.enabled = true,
    this.child,
  });

  final TimeOfDay arcStart;
  final int spanMinutes;
  final TimeOfDay start;
  final TimeOfDay end;
  final void Function(TimeOfDay start, TimeOfDay end) onChanged;
  final EsikIcon startIcon;
  final bool enabled;

  /// Yayın içinde, ortada gösterilen içerik.
  final Widget? child;

  static const snapMinutes = 15;
  static const minGapMinutes = 30;

  @override
  State<ArcRangePicker> createState() => _ArcRangePickerState();
}

class _ArcRangePickerState extends State<ArcRangePicker> {
  bool? _draggingStart;

  int get _base => widget.arcStart.hour * 60 + widget.arcStart.minute;

  int _offset(TimeOfDay t) {
    final m = (t.hour * 60 + t.minute - _base) % 1440;
    // Yayın dışındaki saatler en yakın uca yapışır.
    if (m > widget.spanMinutes) {
      return (1440 - m) < (m - widget.spanMinutes) ? 0 : widget.spanMinutes;
    }
    return m;
  }

  TimeOfDay _time(int offset) {
    final m = (_base + offset) % 1440;
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  _Geometry _geometry(Size size) {
    final r = (size.width - 40) / 2;
    return _Geometry(Offset(size.width / 2, r + 22), r);
  }

  Offset _point(_Geometry g, double f) {
    final a = math.pi * (1 - f);
    return g.center + Offset(math.cos(a), -math.sin(a)) * g.radius;
  }

  double _fractionAt(_Geometry g, Offset local) {
    final v = local - g.center;
    var a = math.atan2(-v.dy, v.dx); // 0 sağ, π sol, üst yarı pozitif
    if (a < 0) a = v.dx < 0 ? math.pi : 0; // alt yarıda en yakın uca
    return 1 - a / math.pi;
  }

  void _drag(Size size, Offset local) {
    final g = _geometry(size);
    final raw = _fractionAt(g, local) * widget.spanMinutes;
    var snapped =
        (raw / ArcRangePicker.snapMinutes).round() * ArcRangePicker.snapMinutes;
    var s = _offset(widget.start);
    var e = _offset(widget.end);
    if (_draggingStart!) {
      snapped = snapped.clamp(0, e - ArcRangePicker.minGapMinutes);
      if (snapped == s) return;
      s = snapped;
    } else {
      snapped = snapped.clamp(
        s + ArcRangePicker.minGapMinutes,
        widget.spanMinutes,
      );
      if (snapped == e) return;
      e = snapped;
    }
    HapticFeedback.selectionClick();
    widget.onChanged(_time(s), _time(e));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, (c.maxWidth - 40) / 2 + 60);
        final g = _geometry(size);
        final fs = _offset(widget.start) / widget.spanMinutes;
        final fe = _offset(widget.end) / widget.spanMinutes;
        final startPos = _point(g, fs);
        final endPos = _point(g, fe);

        return Semantics(
          label:
              'Saat aralığı ${formatTime(widget.start)} ile ${formatTime(widget.end)} arası',
          child: GestureDetector(
            onPanStart: widget.enabled
                ? (d) => _draggingStart =
                      (d.localPosition - startPos).distance <
                      (d.localPosition - endPos).distance
                : null,
            onPanUpdate: widget.enabled
                ? (d) => _drag(size, d.localPosition)
                : null,
            onPanEnd: (_) => _draggingStart = null,
            child: SizedBox.fromSize(
              size: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: size,
                    painter: _ArcPainter(
                      geometry: g,
                      from: fs,
                      to: fe,
                      track: p.text.withValues(alpha: 0.08),
                      active: widget.enabled
                          ? const [
                              Color(0xFFFFD39A),
                              Color(0xFFFFA556),
                              Color(0xFFE9772E),
                            ]
                          : [p.textFaint, p.textFaint, p.textFaint],
                    ),
                  ),
                  _label(g, 0, formatTime(widget.arcStart), p, below: true),
                  _label(
                    g,
                    1,
                    formatTime(_time(widget.spanMinutes)),
                    p,
                    below: true,
                  ),
                  _label(g, 0.5, formatTime(_time(widget.spanMinutes ~/ 2)), p),
                  if (widget.child != null)
                    Positioned(
                      left: 40,
                      right: 40,
                      top: g.center.dy - g.radius * 0.62,
                      child: widget.child!,
                    ),
                  _knob(startPos, dark: true, p: p),
                  _knob(endPos, dark: false, p: p),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(
    _Geometry g,
    double f,
    String text,
    EsikPalette p, {
    bool below = false,
  }) {
    final pt = _point(g, f);
    return Positioned(
      left: pt.dx - 30,
      top: below ? pt.dy + 22 : pt.dy - 40,
      width: 60,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: p.textMuted,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _knob(Offset c, {required bool dark, required EsikPalette p}) {
    final size = dark ? 42.0 : 36.0;
    return Positioned(
      left: c.dx - size / 2,
      top: c.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dark ? const Color(0xFF0B1029) : Colors.white,
            border: dark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.55),
                blurRadius: dark ? 8 : 18,
              ),
            ],
          ),
          child: dark
              ? Center(
                  child: EsikIconView(
                    widget.startIcon,
                    size: 16,
                    color: Colors.white,
                    strokeWidth: 1.8,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _Geometry {
  const _Geometry(this.center, this.radius);
  final Offset center;
  final double radius;
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.geometry,
    required this.from,
    required this.to,
    required this.track,
    required this.active,
  });

  final _Geometry geometry;
  final double from;
  final double to;
  final Color track;
  final List<Color> active;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: geometry.center,
      radius: geometry.radius,
    );
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = track
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    final startAngle = math.pi + math.pi * from;
    final sweep = math.pi * (to - from);
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweep + 0.001,
          colors: active,
        ).createShader(rect)
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) =>
      o.from != from || o.to != to || o.track != track || o.active != active;
}
