import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../ui/esik_logo.dart';
import '../../l10n/texts.dart';
import '../../data/plus.dart';
import '../plus/plus_sheet.dart';

/// Son 14 günün sade özeti: yay gösterge, hap ızgarası ve ortalama saat.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final logs = ref.watch(historyProvider);
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final outcomes = [
      for (final l in logs) ...[l.evening, l.morning],
    ];
    final total = outcomes.where((o) => o.tracked).length;
    final done = outcomes.where((o) => o.completed).length;
    final anyUntracked = outcomes.contains(CheckOutcome.notTracked);
    final anyOff = outcomes.contains(CheckOutcome.off);
    final from = logs.first.date, to = logs.last.date;
    final eveningTimes = [for (final l in logs) ?l.eveningAt];
    final evening = ref.watch(effectiveTriggerConfigProvider)[DayMode.evening]!;

    if (!ref.watch(plusProvider).active) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Atmosphere(
          glowTop: -380,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
              children: [
                ScreenHeader(title: l10n.historyTitle),
                const SizedBox(height: 18),
                const _PlusTeaser(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -380,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
            children: [
              ScreenHeader(
                title: l10n.historyTitle,
                trailing: InfoChip(
                  label: l10n.historyLast14,
                  icon: EsikIcon.history,
                ),
              ),
              const SizedBox(height: 18),
              _ScoreGauge(done: done, total: total),
              const SizedBox(height: 18),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.chip.withValues(alpha: 0.5),
                          ),
                          child: Center(
                            child: EsikLogo(
                              size: 16,
                              archColor: p.text,
                              lightColor: p.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.historyActivity,
                            style: t.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          l10n.historyRange(
                            from.day,
                            to.day,
                            DateFormat.MMMM(l10n.localeName).format(to),
                          ),
                          style: t.labelSmall?.copyWith(
                            fontSize: 12,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _PillGrid(logs: logs),
                    const SizedBox(height: 12),
                    _Legend(showUntracked: anyUntracked, showOff: anyOff),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (eveningTimes.isNotEmpty)
                SurfaceCard(
                  child: _AverageCard(
                    times: eveningTimes,
                    triggerTitle: evening.shortTitle(l10n),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ücretsiz sürümde geçmişin yerine: ne göreceğini anlatır, Plus'a götürür.
class _PlusTeaser extends StatelessWidget {
  const _PlusTeaser();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconCircle(icon: EsikIcon.history, size: 44, active: true),
          const SizedBox(height: 14),
          Text(l10n.plusHistoryTitle, style: t.headlineSmall),
          const SizedBox(height: 6),
          Text(
            l10n.plusHistoryBody,
            style: t.bodyMedium?.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: 18),
          PrimaryPillButton(
            label: l10n.seePlus,
            trailingIcon: EsikIcon.arrowRight,
            expand: true,
            onPressed: () => showPlusSheet(context),
          ),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final f = total == 0 ? 0.0 : done / total;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final r = (w - 60) / 2;
        return Semantics(
          label: total == 0
              ? l10n.historyEmpty
              : l10n.historyScoreA11y(total, done),
          excludeSemantics: true,
          child: SizedBox(
            height: r + 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: f),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => CustomPaint(
                    size: Size(w, r + 40),
                    painter: _GaugePainter(
                      progress: v,
                      radius: r,
                      track: p.text.withValues(alpha: 0.08),
                      knob: Colors.white,
                      startKnob: p.text,
                      startIcon: p.backgroundGradient.last,
                    ),
                  ),
                ),
                Positioned(
                  top: r * 0.42,
                  child: Column(
                    children: [
                      Text.rich(
                        TextSpan(
                          text: total == 0 ? '–' : '$done',
                          children: [
                            TextSpan(
                              text: total == 0 ? '' : '/$total',
                              style: TextStyle(
                                fontSize: 28,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                        style: t.displayLarge?.copyWith(fontSize: 52),
                      ),
                      const SizedBox(height: 6),
                      InfoChip(
                        label: total == 0
                            ? l10n.historyEmpty
                            : l10n.historyPercent((f * 100).round()),
                        icon: total == 0 ? EsikIcon.clock : EsikIcon.check,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        switch (f) {
                          _ when total == 0 => l10n.historyFirstSoon,
                          >= 0.85 => l10n.historyGreat,
                          >= 0.5 => l10n.historyHalfway,
                          _ => l10n.historyNewDay,
                        },
                        style: t.bodyLarge?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.radius,
    required this.track,
    required this.knob,
    required this.startKnob,
    required this.startIcon,
  });

  final double progress;
  final double radius;
  final Color track;
  final Color knob;
  final Color startKnob;
  final Color startIcon;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, radius + 16);
    final rect = Rect.fromCircle(center: c, radius: radius);
    Paint stroke(double w) => Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, math.pi, math.pi, false, stroke(26)..color = track);
    if (progress <= 0) return;
    final sweep = math.pi * progress;
    canvas.drawArc(
      rect,
      math.pi,
      sweep,
      false,
      stroke(26)
        ..shader = SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi + sweep + 0.001,
          colors: const [
            Color(0xFFFFD9A8),
            Color(0xFFFFA556),
            Color(0xFFE26F28),
          ],
        ).createShader(rect),
    );
    final end =
        c +
        Offset(math.cos(math.pi + sweep), math.sin(math.pi + sweep)) * radius;
    canvas.drawCircle(end, 22, Paint()..color = knob.withValues(alpha: 0.35));
    canvas.drawCircle(end, 15, Paint()..color = knob);
    // Başlangıçtaki koyu tutamaç ve ay işareti.
    final a = math.pi * 1.2;
    final s = c + Offset(math.cos(a), math.sin(a)) * radius;
    canvas.drawCircle(s, 18, Paint()..color = startKnob);
    canvas.drawCircle(
      s + const Offset(-1.5, -1.5),
      6,
      Paint()..color = startIcon,
    );
    canvas.drawCircle(
      s + const Offset(1.5, -3.5),
      5.2,
      Paint()..color = startKnob,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter o) =>
      o.progress != progress || o.knob != knob;
}

class _PillGrid extends StatelessWidget {
  const _PillGrid({required this.logs});
  final List<DayLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final weeks = [logs.sublist(0, 7), logs.sublist(7, 14)];
    Widget row(DayMode mode, List<DayLog> week) => Row(
      children: [
        SizedBox(
          width: 22,
          child: EsikIconView(
            mode == DayMode.evening ? EsikIcon.moon : EsikIcon.sun,
            size: 13,
            strokeWidth: 2,
            color: p.textMuted,
          ),
        ),
        for (final l in week)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _Pill(outcome: l.outcome(mode)),
            ),
          ),
      ],
    );
    return Semantics(
      label: l10n.historyGridA11y,
      child: Column(
        children: [
          for (final mode in DayMode.values)
            for (final w in weeks)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: row(mode, w),
              ),
          Row(
            children: [
              const SizedBox(width: 22),
              for (final l in weeks.last)
                Expanded(
                  child: Text(
                    l10n.weekdayLetterList[l.date.weekday - 1],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: p.textMuted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.outcome});
  final CheckOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return switch (outcome) {
      CheckOutcome.done => Container(
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: LinearGradient(colors: p.accentGradient),
        ),
      ),
      CheckOutcome.viaBackup => CustomPaint(
        painter: _DashedPillPainter(color: p.accent),
        child: Container(
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: p.accent.withValues(alpha: 0.2),
          ),
        ),
      ),
      CheckOutcome.missed => Container(
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: p.text.withValues(alpha: 0.14),
        ),
      ),
      // Eşiğin çalışmadığı gün: çok soluk dolgu, ince çerçeve.
      CheckOutcome.off => Container(
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: p.text.withValues(alpha: 0.05),
          border: Border.all(color: p.text.withValues(alpha: 0.10)),
        ),
      ),
      // Uygulama o gün kurulu değildi: içi boş, ince çerçeve.
      CheckOutcome.notTracked => Container(
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: p.text.withValues(alpha: 0.12)),
        ),
      ),
    };
  }
}

class _DashedPillPainter extends CustomPainter {
  _DashedPillPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    ).deflate(0.75);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 6) {
        canvas.drawPath(m.extractPath(d, d + 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPillPainter o) => o.color != color;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.showUntracked, required this.showOff});
  final bool showUntracked;
  final bool showOff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final style = TextStyle(fontSize: 11, color: p.textMuted);
    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 18, height: 10, child: swatch),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        item(const _Pill(outcome: CheckOutcome.done), l10n.outcomeDone),
        item(
          const _Pill(outcome: CheckOutcome.viaBackup),
          l10n.outcomeViaBackup,
        ),
        item(const _Pill(outcome: CheckOutcome.missed), l10n.outcomeMissed),
        if (showUntracked)
          item(
            const _Pill(outcome: CheckOutcome.notTracked),
            l10n.outcomeNotTracked,
          ),
        if (showOff)
          item(const _Pill(outcome: CheckOutcome.off), l10n.outcomeOff),
      ],
    );
  }
}

class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.times, required this.triggerTitle});
  final List<TimeOfDay> times;
  final String triggerTitle;

  /// Gece yarısını geçen saatleri (00:12) bir önceki akşamın devamı sayar.
  static int _eveningMinutes(TimeOfDay t) {
    final m = t.hour * 60 + t.minute;
    return t.hour < 12 ? m + 1440 : m;
  }

  static TimeOfDay _fromMinutes(int m) =>
      TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final mins = times.map(_eveningMinutes).toList()..sort();
    final avg = mins.reduce((a, b) => a + b) ~/ mins.length;
    final lo = mins.first, hi = mins.last;
    final f = hi == lo ? 0.5 : (avg - lo) / (hi - lo);
    final muted = t.labelSmall?.copyWith(fontSize: 12, color: p.textMuted);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.historyAverageEvening, style: muted),
                  Text(
                    formatTime(_fromMinutes(avg)),
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.historyEveningTrigger, style: muted),
                Text(
                  triggerTitle,
                  style: t.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => SizedBox(
            height: 26,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD9A8),
                        Color(0xFFFFA556),
                        Color(0xFFE26F28),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: (c.maxWidth - 64) * f,
                  child: Container(
                    width: 64,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.accentGradient.last,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: p.accentGradient.last.withValues(alpha: 0.3),
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      formatTime(_fromMinutes(avg)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.historyEarliest(formatTime(_fromMinutes(lo))),
                style: muted,
              ),
            ),
            Flexible(
              child: Text(
                l10n.historyLatest(formatTime(_fromMinutes(hi))),
                style: muted,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
