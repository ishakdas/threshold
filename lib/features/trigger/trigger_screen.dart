import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../platform/native_bridge.dart';
import '../setup/setup_health.dart';
import 'arc_range_picker.dart';
import '../../l10n/texts.dart';
import '../../data/plus.dart';
import '../plus/plus_sheet.dart';

/// Eşik ayarı: hangi davranış, hangi saatlerde, yedek saat.
/// Her değişiklik anında kaydedilir; yedek alarm da hemen yeniden kurulur.
class TriggerScreen extends ConsumerStatefulWidget {
  const TriggerScreen({super.key});

  @override
  ConsumerState<TriggerScreen> createState() => _TriggerScreenState();
}

class _TriggerScreenState extends ConsumerState<TriggerScreen> {
  late DayMode _mode = ref.read(dayModeProvider);

  TriggerConfig get _config => ref.read(triggerConfigProvider)[_mode]!;
  void _update(TriggerConfig c) =>
      ref.read(triggerConfigProvider.notifier).update(_mode, c);

  void _openSetup() => context.push(
    '/kurulum?mod=${_mode == DayMode.evening ? 'aksam' : 'sabah'}',
  );

  void _toggleKind(TriggerConfig c, TriggerKind kind, {required bool plus}) {
    if (!plus) {
      // Ücretsiz sürümde tek ve ücretsiz bir tetikleyici: dokunulan seçilir.
      if (kind.plusOnly) {
        showPlusSheet(context);
        return;
      }
      HapticFeedback.selectionClick();
      _update(c.copyWith(kinds: [kind]));
      return;
    }
    final next = c.toggle(kind);
    if (identical(next, c)) {
      // Son tetikleyici kaldırılamaz.
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    _update(next);
  }

  TimeOfDay get _arcStart => _mode == DayMode.evening
      ? const TimeOfDay(hour: 18, minute: 0)
      : const TimeOfDay(hour: 4, minute: 0);
  int get _arcSpan => _mode == DayMode.evening ? 12 * 60 : 8 * 60;

  Future<void> _pickWindow({required bool start}) async {
    final c = _config;
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? c.windowStart : c.windowEnd,
      helpText: start
          ? context.l10n.windowStartHelp
          : context.l10n.windowEndHelp,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final (s, e) = ArcRangePicker.normalize(
      _arcStart,
      _arcSpan,
      start ? picked : c.windowStart,
      start ? c.windowEnd : picked,
    );
    _update(c.copyWith(windowStart: s, windowEnd: e));
  }

  Future<void> _pickBackup() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _config.backupTime,
      helpText: context.l10n.backupTimeHelp,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) _update(_config.copyWith(backupTime: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = _mode == DayMode.evening;
    final plus = ref.watch(plusProvider).active;
    // Asıl seçim saklanır; Plus yoksa geçerli olan gösterilir.
    final c = ref.watch(triggerConfigProvider)[_mode]!;
    final shown = c.effective(plus: plus);
    final issueCount = ref.watch(setupIssuesProvider)?[_mode]?.length ?? 0;
    // "Hiçbiri olmazsa {saat} hatırlat": saat altı çizili, ortasından böl.
    final backupParts = l10n.backupRow('\u0000').split('\u0000');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -260,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
            children: [
              ScreenHeader(
                title: l10n.settingsTitle,
                trailing: InfoChip(
                  label: evening ? l10n.beforeBed : l10n.beforeLeaving,
                  icon: evening ? EsikIcon.moon : EsikIcon.sun,
                ),
              ),
              const SizedBox(height: 12),
              const _PlusCard(),
              const SizedBox(height: 14),
              ModeSegment(
                value: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 26),
              ArcRangePicker(
                key: ValueKey(_mode),
                arcStart: _arcStart,
                spanMinutes: _arcSpan,
                start: c.windowStart,
                end: c.windowEnd,
                enabled: c.windowEnabled,
                startIcon: evening ? EsikIcon.moon : EsikIcon.sun,
                onChanged: (s, e) =>
                    _update(c.copyWith(windowStart: s, windowEnd: e)),
                child: Column(
                  children: [
                    if (c.windowEnabled)
                      // Saatlere dokunarak da seçilebilir.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TimeButton(
                              time: c.windowStart,
                              label: l10n.pickStartTime,
                              onTap: () => _pickWindow(start: true),
                            ),
                            Text(' – ', style: t.headlineMedium),
                            _TimeButton(
                              time: c.windowEnd,
                              label: l10n.pickEndTime,
                              onTap: () => _pickWindow(start: false),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        l10n.anyTime,
                        textAlign: TextAlign.center,
                        style: t.headlineMedium?.copyWith(fontSize: 34),
                      ),
                    const SizedBox(height: 8),
                    Semantics(
                      toggled: c.windowEnabled,
                      button: true,
                      label: l10n.onlyInWindow,
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _update(c.copyWith(windowEnabled: !c.windowEnabled));
                        },
                        child: InfoChip(
                          label: c.windowEnabled
                              ? l10n.onlyInWindow
                              : l10n.windowOff,
                          icon: EsikIcon.clock,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DotLabel(l10n.whatTriggers),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                // Verilmezse GridView güvenli alan boşluğunu kendisi ekler.
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.95,
                children: [
                  for (final kind in TriggerKind.forMode(_mode))
                    _TriggerTile(
                      kind: kind,
                      selected: shown.kinds.contains(kind),
                      locked: !plus && kind.plusOnly,
                      onTap: kind.supported
                          ? () => _toggleKind(c, kind, plus: plus)
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  !plus
                      ? l10n.plusMultiHint
                      : c.kinds.length > 1
                      ? l10n.firstOneWins
                      : l10n.pickSeveral,
                  style: t.labelSmall?.copyWith(
                    fontSize: 12,
                    color: p.textFaint,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DotLabel(
                  plus ? l10n.whichDays : '${l10n.whichDays} · Plus',
                ),
              ),
              const SizedBox(height: 10),
              _DayPicker(
                days: shown.days,
                onToggle: (d) {
                  if (!plus) {
                    showPlusSheet(context);
                    return;
                  }
                  final next = c.toggleDay(d);
                  if (identical(next, c)) {
                    HapticFeedback.heavyImpact();
                  } else {
                    HapticFeedback.selectionClick();
                    _update(next);
                  }
                },
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                child: Row(
                  children: [
                    EsikIconView(EsikIcon.bell, size: 18, color: p.text),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.changeBackupTime,
                        child: GestureDetector(
                          onTap: _pickBackup,
                          child: Text.rich(
                            TextSpan(
                              text: backupParts.first,
                              children: [
                                TextSpan(
                                  text: l10n.at(c.backupTime),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: p.textFaint,
                                  ),
                                ),
                                TextSpan(text: backupParts.last),
                              ],
                            ),
                            style: t.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    EsikSwitch(
                      value: c.backupEnabled,
                      semanticLabel: l10n.backupReminder,
                      onChanged: (v) => _update(c.copyWith(backupEnabled: v)),
                    ),
                  ],
                ),
              ),
              _StatusLine(mode: _mode),
              const SizedBox(height: 10),
              const _SilentAlertCard(),
              const SizedBox(height: 10),
              const _LanguageCard(),
              const SizedBox(height: 16),
              PrimaryPillButton(
                label: switch (issueCount) {
                  0 => l10n.setupCheck,
                  final n => l10n.setupFinishMissing(n),
                },
                warning: issueCount > 0,
                trailingIcon: EsikIcon.arrowRight,
                expand: true,
                onPressed: _openSetup,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.autoSaved,
                  style: t.labelSmall?.copyWith(
                    fontSize: 12,
                    color: p.textFaint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aralığın bir ucundaki saat; dokununca saat seçici açılır.
class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.time,
    required this.label,
    required this.onTap,
  });

  final TimeOfDay time;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: l10n.timeButtonA11y(label, formatTime(time)),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          formatTime(time),
          style: t.headlineMedium?.copyWith(
            fontSize: 34,
            fontFeatures: const [FontFeature.tabularFigures()],
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: p.textFaint,
          ),
        ),
      ),
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({
    required this.kind,
    required this.selected,
    this.locked = false,
    required this.onTap,
  });

  final TriggerKind kind;
  final bool selected;

  /// Plus'a özel ve Plus yok: "Plus" yazar, dokununca Plus sayfası açılır.
  final bool locked;

  /// Henüz desteklenmeyen tetikleyicide null: kart soluk ve "Yakında" yazar.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final soon = !kind.supported;
    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      label: l10n.tileA11y(
        kind.title(l10n),
        soon ? l10n.comingSoonLower : kind.subtitle(l10n),
      ),
      excludeSemantics: true,
      child: Opacity(
        opacity: soon && !selected ? 0.45 : 1,
        child: SurfaceCard(
          radius: 26,
          highlighted: selected,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onTap: onTap,
          child: Row(
            children: [
              IconCircle(icon: kind.icon, size: 40, active: selected),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kind.title(l10n),
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      soon
                          ? l10n.comingSoon
                          : locked
                          ? 'Plus'
                          : selected
                          ? l10n.selected
                          : kind.subtitle(l10n),
                      style: t.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: p.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Haftanın günleri: eşiğin hangi günler çalışacağı. En az bir gün seçili kalır.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.days, required this.onToggle});
  final Set<int> days;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          Semantics(
            button: true,
            toggled: days.contains(d),
            label: l10n.weekdayName(d),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onToggle(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: days.contains(d)
                      ? p.primaryButton
                      : p.chip.withValues(alpha: 0.4),
                  border: Border.all(
                    color: days.contains(d) ? p.primaryButton : p.chipBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.weekdayLetterList[d - 1],
                  style: t.labelLarge?.copyWith(
                    color: days.contains(d) ? p.onPrimaryButton : p.textMuted,
                    fontWeight: days.contains(d)
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Plus durumu: deneme günleri, ücretsiz sürüm ya da satın alındı.
class _PlusCard extends ConsumerWidget {
  const _PlusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final plus = ref.watch(plusProvider);
    final testStart = plus.testStart;
    final status = plus.owned
        ? l10n.plusOwned
        : testStart != null
        // Yalnızca test APK'sı: başlangıç dakikasıyla, kalan süre dakikayla.
        ? 'TEST · başlangıç ${testStart.day}.${testStart.month} '
              '${formatTime(TimeOfDay.fromDateTime(testStart))} · '
              '${plus.inTrial ? '${plus.testMinutesLeft} dk kaldı' : 'deneme bitti'}'
        : plus.inTrial
        ? l10n.plusTrialLeft(plus.trialDaysLeft)
        : l10n.plusFree;
    return SurfaceCard(
      radius: 26,
      highlighted: !plus.owned,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      onTap: () => showPlusSheet(context),
      child: Row(
        children: [
          IconCircle(
            icon: plus.owned ? EsikIcon.check : EsikIcon.door,
            size: 36,
            active: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.plusName, style: t.labelLarge),
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
          if (!plus.owned)
            EsikIconView(EsikIcon.chevronRight, size: 16, color: p.text),
        ],
      ),
    );
  }
}

/// Uygulamanın dili: telefonunki ya da seçilen.
class _LanguageCard extends ConsumerWidget {
  const _LanguageCard();

  /// Diller her zaman kendi adlarıyla yazılır; yalnızca "Sistem" çevrilir.
  static String _name(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => l10n.languageSystem,
        AppLanguage.tr => 'Türkçe',
        AppLanguage.en => 'English',
        AppLanguage.es => 'Español',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.globe, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.language, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<AppLanguage>(
            values: AppLanguage.values,
            value: ref.watch(languageProvider),
            label: (lang) => _name(l10n, lang),
            expand: false,
            onChanged: ref.read(languageProvider.notifier).set,
          ),
        ],
      ),
    );
  }
}

/// Telefon sessizdeyken bildirim titresin ya da çalsın mı? İki mod için ortak.
class _SilentAlertCard extends ConsumerWidget {
  const _SilentAlertCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final value = ref.watch(effectiveSilentAlertProvider);
    final plus = ref.watch(plusProvider).active;
    final muted =
        value == SilentAlert.ring &&
        ref.watch(setupHealthProvider).value?.alarmVolume == 0;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.vibrate, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.whenSilent, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<SilentAlert>(
            values: SilentAlert.values,
            value: value,
            label: (a) => a.label(l10n),
            icon: (a) => a.icon,
            onChanged: (v) => !plus && v != SilentAlert.quiet
                ? showPlusSheet(context)
                : ref.read(silentAlertProvider.notifier).set(v),
          ),
          const SizedBox(height: 10),
          Text(
            switch (value) {
              SilentAlert.quiet => l10n.silentQuietHint,
              SilentAlert.vibrate => l10n.silentVibrateHint,
              SilentAlert.ring when muted => l10n.silentMutedHint,
              SilentAlert.ring => l10n.silentRingHint,
            },
            style: t.labelMedium?.copyWith(
              fontWeight: muted ? FontWeight.w400 : FontWeight.w300,
              color: muted ? p.accent : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Sıradaki yedek: bugün 14:05", son yedeğin ve son tetikleyicinin sonucu.
/// Bildirimin gerçekten kurulduğunu ve son seferde ne olduğunu gösterir.
class _StatusLine extends ConsumerWidget {
  const _StatusLine({required this.mode});
  final DayMode mode;

  /// "Durum: şarj bekleniyor". Tetikleyicinin gerçekten kurulu olduğunu gösterir.
  static String _waiting(
    AppLocalizations l10n,
    TriggerWaiting w,
    DateTime now, {
    required bool many,
  }) {
    final at = w.at;
    // Bekleme henüz başlamadıysa ne zaman başlayacağı.
    String from(String text) =>
        at != null && at.isAfter(now.add(const Duration(minutes: 1)))
        ? l10n.waitFrom(l10n.when(at, now), text)
        : text;
    final text = switch (w.wait) {
      TriggerWait.charging => from(l10n.waitCharging),
      TriggerWait.wifi => from(l10n.waitWifi),
      TriggerWait.leaving => l10n.waitLeaving,
      TriggerWait.alarm => l10n.waitAlarm(l10n.when(at!, now)),
      TriggerWait.alarmSettling => l10n.waitAlarmSettling,
      TriggerWait.noAlarm => l10n.waitNoAlarm,
      TriggerWait.silence => l10n.waitSilence,
      TriggerWait.alreadySilent => l10n.waitAlreadySilent,
      TriggerWait.unsilence => l10n.waitUnsilence,
      TriggerWait.notSilent => l10n.waitNotSilent,
      TriggerWait.none => l10n.waitNone,
    };
    return many
        ? l10n.statusLineKind(w.kind.title(l10n), text)
        : l10n.statusLine(text);
  }

  /// Tetikleyicinin çalışması için bilinmesi gereken tek şey.
  static String _hint(AppLocalizations l10n, TriggerKind kind) =>
      switch (kind) {
        TriggerKind.charging => l10n.hintCharging,
        TriggerKind.alarmStopped => l10n.hintAlarm,
        TriggerKind.leftHomeWifi => l10n.hintWifi,
        TriggerKind.silenced => l10n.hintSilenced,
        TriggerKind.unsilenced => l10n.hintUnsilenced,
        TriggerKind.nfcTag => l10n.hintNfc,
        _ => l10n.hintSoon,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final status = ref.watch(thresholdStatusProvider).value?[mode];
    final kinds = ref.watch(effectiveTriggerConfigProvider)[mode]!.kinds;
    // Android kanalı yoksa (testler) satır gösterilmez.
    if (status == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final lines = [
      status.next == null
          ? l10n.backupOff
          : l10n.backupNext(l10n.when(status.next!, now)),
      if (status.lastAt != null && status.lastOutcome != null)
        l10n.backupLast(
          l10n.when(status.lastAt!, now),
          status.lastOutcome!.description(l10n),
        ),
      if (status.triggerAt != null && status.triggerOutcome != null)
        if (status.triggerKind case final kind?)
          l10n.triggerLastKind(
            l10n.lower(kind.title(l10n)),
            l10n.when(status.triggerAt!, now),
            status.triggerOutcome!.description(l10n),
          )
        else
          l10n.triggerLast(
            l10n.when(status.triggerAt!, now),
            status.triggerOutcome!.description(l10n),
          ),
      for (final w in status.waits)
        _waiting(l10n, w, now, many: kinds.length > 1),
      // Tek tetikleyicide ne yapılacağını söyle; çoğunda satırlar yeter.
      if (kinds.length == 1) _hint(l10n, kinds.single),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Text(
        lines.join('\n'),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w300,
          color: p.textMuted,
          height: 1.5,
        ),
      ),
    );
  }
}
