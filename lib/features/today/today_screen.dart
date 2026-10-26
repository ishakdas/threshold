import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../setup/setup_health.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../ui/esik_logo.dart';
import '../../ui/threshold_door.dart';
import 'day_strip.dart';
import '../../l10n/texts.dart';

/// Tek ana ekran: üstte gün şeridi, ortada şu anki eşiğin büyük kartı,
/// altta diğer eşiğin özeti.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(dayModeProvider);
    final other = mode == DayMode.evening ? DayMode.morning : DayMode.evening;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    return Atmosphere(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  EsikLogo(archColor: p.text, lightColor: p.accent),
                  const SizedBox(width: 9),
                  Text(l10n.appName, style: t.titleLarge),
                  const Spacer(),
                  _ModeChip(
                    evening: mode == DayMode.evening,
                    onTap: ref.read(dayModeProvider.notifier).toggle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DayStrip(entries: _stripEntries(ref, l10n)),
            const SizedBox(height: 10),
            // Eksik bir izin ya da ayar varsa eşik haber veremeyebilir.
            if (_SetupCard.issueMode(ref, mode) case final issueMode?) ...[
              _SetupCard(mode: issueMode),
              const SizedBox(height: 10),
            ],
            _ThresholdCard(mode: mode),
            const SizedBox(height: 10),
            _SummaryCard(mode: other),
          ],
        ),
      ),
    );
  }

  List<DayStripEntry> _stripEntries(WidgetRef ref, AppLocalizations l10n) {
    final today = ref.watch(todayProvider);
    final history = ref.watch(historyProvider);
    final progress = ref.watch(todayProgressProvider);
    double past(DateTime d) {
      final log = history.where((l) => l.date == d).firstOrNull;
      if (log == null) return 0;
      return [log.evening, log.morning].where((o) => o.completed).length / 2;
    }

    return [
      for (var offset = -3; offset <= 3; offset++)
        () {
          final d = DateTime(today.year, today.month, today.day + offset);
          return DayStripEntry(
            day: d.day,
            weekday: DateFormat.E(l10n.localeName).format(d),
            isToday: offset == 0,
            isFuture: offset > 0,
            progress: offset == 0
                ? progress.values.where((s) => s.isComplete).length / 2
                : past(d),
          );
        }(),
    ];
  }
}

class _ThresholdCard extends ConsumerWidget {
  const _ThresholdCard({required this.mode});
  final DayMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final config = ref.watch(triggerConfigProvider)[mode]!;
    final items = ref.watch(checklistProvider)[mode]!;
    final session = ref.watch(todayProgressProvider)[mode]!;
    final evening = mode == DayMode.evening;
    final done = session.checked.length.clamp(0, items.length);
    final remaining = items.length - done;
    final offToday = !config.activeOn(ref.watch(todayProvider));

    final String buttonLabel;
    if (session.isComplete) {
      final at = TimeOfDay.fromDateTime(session.completedAt!);
      buttonLabel = l10n.todayDoneAt(formatTime(at));
    } else if (done > 0) {
      buttonLabel = l10n.todayContinue(remaining);
    } else {
      buttonLabel = l10n.todayCheckNow;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.surfaceBorder),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.backgroundGradient.last.withValues(alpha: 0.25),
            p.backgroundGradient.last.withValues(alpha: 0.85),
            p.backgroundGradient.last.withValues(alpha: 0.95),
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          children: [
            const ThresholdDoor(),
            const SizedBox(height: 22),
            DotLabel(
              evening ? l10n.todayThresholdEvening : l10n.todayThresholdMorning,
              center: true,
            ),
            const SizedBox(height: 4),
            Text(
              config.title(l10n),
              textAlign: TextAlign.center,
              style: t.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              offToday
                  ? l10n.todayOffDay
                  : l10n.todayCardBody(config.when(l10n), items.length),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _Meta(
                  icon: EsikIcon.list,
                  text: l10n.todayItemsProgress(items.length, done),
                ),
                if (config.windowEnabled)
                  _Meta(
                    icon: EsikIcon.clock,
                    text:
                        '${formatTime(config.windowStart)}–${formatTime(config.windowEnd)}',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryPillButton(
              label: buttonLabel,
              icon: EsikIcon.check,
              height: 44,
              onPressed: () => context.push('/kontrol'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final EsikIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EsikIconView(icon, size: 14, color: p.textMuted, strokeWidth: 1.8),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: p.textMuted),
        ),
      ],
    );
  }
}

/// Diğer eşiğin özeti: büyük ince sayı ve son 7 günün çubukları.
class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.mode});
  final DayMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = mode == DayMode.evening;
    final config = ref.watch(triggerConfigProvider)[mode]!;
    final items = ref.watch(checklistProvider)[mode]!;
    final session = ref.watch(todayProgressProvider)[mode]!;
    final history = ref.watch(historyProvider);
    final last7 = history.sublist(history.length - 7);

    // Akşam ekranında sabah kartı bugünün sabahını, sabah ekranında akşam kartı
    // dünün akşamını özetler (bu akşamki kontrol henüz gelmedi).
    final n = items.length;
    final String count;
    final String status;
    if (session.isComplete) {
      count = '$n/$n';
      final at = l10n.at(TimeOfDay.fromDateTime(session.completedAt!));
      status = evening
          ? l10n.summaryEveningDoneAt(at)
          : l10n.summaryMorningDoneAt(at);
    } else if (!evening) {
      final done = session.checked.length.clamp(0, n);
      count = done == 0 ? '–' : '$done/$n';
      status = done == 0
          ? l10n.summaryMorningNotDone
          : l10n.summaryMorningPartial;
    } else {
      final y = history.last;
      (count, status) = switch (y.evening) {
        CheckOutcome.done || CheckOutcome.viaBackup => (
          '$n/$n',
          l10n.summaryLastNightDoneAt(l10n.at(y.eveningAt!)),
        ),
        CheckOutcome.missed => ('0/$n', l10n.summaryLastNightMissed),
        CheckOutcome.notTracked => ('–', l10n.summaryLastNightNoRecord),
        CheckOutcome.off => ('–', l10n.summaryLastNightOff),
      };
    }

    return Semantics(
      button: true,
      label: evening ? l10n.summaryGoToEvening : l10n.summaryGoToMorning,
      child: SurfaceCard(
        onTap: () => ref.read(dayModeProvider.notifier).set(mode),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconCircle(
                  icon: evening ? EsikIcon.moon : EsikIcon.sun,
                  size: 32,
                  strokeWidth: 1.8,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    evening
                        ? l10n.summaryEveningLine(
                            l10n.lower(config.shortTitle(l10n)),
                          )
                        : l10n.summaryMorningLine(
                            l10n.lower(config.shortTitle(l10n)),
                          ),
                    style: t.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: p.text.withValues(alpha: 0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                EsikIconView(
                  EsikIcon.chevronRight,
                  size: 16,
                  color: p.text,
                  strokeWidth: 1.8,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(count, style: t.displayLarge),
                      Text(
                        status,
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniBars(logs: last7, mode: mode),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.logs, required this.mode});
  final List<DayLog> logs;
  final DayMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final done = logs.where((l) => l.outcome(mode).completed).length;
    return Semantics(
      label: l10n.summaryLast7A11y(done),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < logs.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: _barHeight(logs[i]),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: logs[i].outcome(mode).completed
                        ? null
                        : p.text.withValues(
                            alpha: logs[i].outcome(mode).tracked ? 0.16 : 0.07,
                          ),
                    gradient: !logs[i].outcome(mode).completed
                        ? null
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFFFC27A),
                              p.accentGradient.last,
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.weekdayLetterList[logs[i].date.weekday - 1],
                  style: TextStyle(fontSize: 11, color: p.textFaint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Tetikleyiciyle tamamlanan gün tam boy, yedek bildirimle tamamlanan gün
  /// yarım boy, atlanan gün kısa ve soluk; kayıt olmayan gün en kısa.
  double _barHeight(DayLog log) => switch (log.outcome(mode)) {
    CheckOutcome.done => 34,
    CheckOutcome.viaBackup => 18,
    CheckOutcome.missed => 8,
    CheckOutcome.notTracked || CheckOutcome.off => 4,
  };
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.evening, required this.onTap});
  final bool evening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: evening ? l10n.modeEveningSwitch : l10n.modeMorningSwitch,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: InfoChip(
          label: evening ? l10n.modeEvening : l10n.modeMorning,
          icon: evening ? EsikIcon.moon : EsikIcon.sun,
        ),
      ),
    );
  }
}

/// Kurulumda eksik varsa: ilk eksik ve kaç tane olduğu.
class _SetupCard extends ConsumerWidget {
  const _SetupCard({required this.mode});

  /// Eksiği olan mod; önce şu anki mod. Eksik yoksa null.
  static DayMode? issueMode(WidgetRef ref, DayMode current) {
    final issues = ref.watch(setupIssuesProvider);
    if (issues == null) return null;
    for (final m in [current, ...DayMode.values]) {
      if (issues[m]!.isNotEmpty) return m;
    }
    return null;
  }

  final DayMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final all = ref.watch(setupIssuesProvider)!;
    final issues = all[mode]!;
    // Ortak eksikler iki modda da sayılır; bir kez göster.
    final total = {...all[DayMode.evening]!, ...all[DayMode.morning]!}.length;
    final detail = total > 1
        ? l10n.setupCardMore(issues.first.label(l10n), total)
        : issues.first.label(l10n);
    final icon = switch (issues.first) {
      SetupIssue.notifications => EsikIcon.bell,
      SetupIssue.battery => EsikIcon.battery,
      SetupIssue.nfcOff || SetupIssue.nfcTag => EsikIcon.nfc,
      SetupIssue.noAlarm => EsikIcon.alarm,
    };
    return Semantics(
      button: true,
      label: l10n.setupCardA11y(detail),
      excludeSemantics: true,
      child: SurfaceCard(
        highlighted: true,
        tint: p.warning,
        radius: 24,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        onTap: () => context.push(
          '/kurulum?mod=${mode == DayMode.evening ? 'aksam' : 'sabah'}',
        ),
        child: Row(
          children: [
            IconCircle(
              icon: icon,
              size: 40,
              active: true,
              gradient: p.warningGradient,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.setupFinish, style: t.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: t.labelMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            EsikIconView(EsikIcon.chevronRight, size: 16, color: p.text),
          ],
        ),
      ),
    );
  }
}
