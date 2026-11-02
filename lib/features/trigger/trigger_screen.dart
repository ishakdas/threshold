import 'package:flutter/cupertino.dart';
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
import 'threshold_widgets.dart';
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

  /// Seçili eşik (gün profili); mod değişince ilkine döner.
  int _index = 0;

  List<TriggerConfig> get _list => ref.read(thresholdsProvider)[_mode]!;
  TriggerConfig get _config => _list[_index.clamp(0, _list.length - 1)];
  void _update(TriggerConfig c) => ref
      .read(thresholdsProvider.notifier)
      .update(_mode, _index.clamp(0, _list.length - 1), c);

  /// Seçili eşikte günü aç/kapat; başka eşikteyse buraya taşır.
  void _toggleDay(int weekday) {
    final list = _list;
    final next = list.toggleDay(_index, weekday);
    if (identical(next, list)) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    ref.read(thresholdsProvider.notifier).set(_mode, next);
  }

  /// Yeni eşik: seçilinin kopyası; hafta sonu ayrı değilse hafta sonuna,
  /// değilse en kalabalık eşiğin son gününe kurulur. Günleri sonra seçilir.
  void _addThreshold({required bool plus}) {
    if (!plus) {
      showPlusSheet(context);
      return;
    }
    final list = _list;
    final weekend = _mode == DayMode.evening ? {5, 6} : {6, 7};
    final owner = list.indexWhere((c) => c.days.containsAll(weekend));
    final Set<int> days;
    if (owner >= 0 && list[owner].days.length > weekend.length) {
      days = weekend;
    } else {
      final biggest = list.reduce(
        (a, b) => a.days.length >= b.days.length ? a : b,
      );
      if (biggest.days.length < 2) {
        HapticFeedback.heavyImpact();
        return;
      }
      days = {(biggest.days.toList()..sort()).last};
    }
    final next = list.withThreshold(_config, days);
    HapticFeedback.mediumImpact();
    ref.read(thresholdsProvider.notifier).set(_mode, next);
    setState(() => _index = next.length - 1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          content: Text(context.l10n.thresholdAdded),
        ),
      );
  }

  void _removeThreshold() {
    HapticFeedback.mediumImpact();
    ref.read(thresholdsProvider.notifier).set(_mode, _list.without(_index));
    setState(() => _index = 0);
  }

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
    final list = ref.watch(thresholdsProvider)[_mode]!;
    // Plus yoksa yalnızca ilk eşik geçerli.
    if (!plus || _index >= list.length) _index = 0;
    // Asıl seçim saklanır; Plus yoksa geçerli olan gösterilir.
    final c = list[_index];
    final shown = c.effective(plus: plus);
    final others = {
      for (var i = 0; i < list.length; i++)
        if (i != _index) ...list[i].days,
    };
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
                trailing: IconButton(
                  tooltip: l10n.appSettingsTitle,
                  onPressed: () => context.push('/uygulama'),
                  icon: EsikIconView(EsikIcon.gear, size: 22, color: p.text),
                ),
              ),
              const SizedBox(height: 12),
              ModeSegment(
                value: _mode,
                onChanged: (m) => setState(() {
                  _mode = m;
                  _index = 0;
                }),
              ),
              const SizedBox(height: 12),
              ThresholdTabs(
                thresholds: list,
                selected: _index,
                plus: plus,
                onSelect: (i) {
                  if (!plus && i > 0) {
                    showPlusSheet(context);
                    return;
                  }
                  HapticFeedback.selectionClick();
                  setState(() => _index = i);
                },
                onAdd: () => _addThreshold(plus: plus),
                onTemplates: () => showThresholdTemplates(context),
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
                child: Row(
                  children: [
                    // Birden fazla tetikleyici de Plus özelliği.
                    PlusBadge(owned: plus, compact: true),
                    const SizedBox(width: 8),
                    Expanded(
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
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DelayCard(
                delay: c.delay,
                onChanged: (d) => _update(c.copyWith(delay: d)),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Flexible(child: DotLabel(l10n.whichDays)),
                    const SizedBox(width: 8),
                    PlusBadge(owned: plus),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              WeekdayPicker(
                days: shown.days,
                others: plus ? others : const {},
                onToggle: (d) {
                  if (!plus) {
                    showPlusSheet(context);
                    return;
                  }
                  _toggleDay(d);
                },
              ),
              if (plus && list.length > 1) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    l10n.thresholdDaysHint,
                    style: t.labelSmall?.copyWith(
                      fontSize: 12,
                      color: p.textFaint,
                    ),
                  ),
                ),
              ],
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
              if (plus && list.length > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _removeThreshold,
                    icon: EsikIconView(
                      EsikIcon.trash,
                      size: 16,
                      color: p.textMuted,
                    ),
                    label: Text(
                      l10n.thresholdRemove(c.daysLabel(l10n)),
                      style: t.labelLarge?.copyWith(color: p.textMuted),
                    ),
                  ),
                ),
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
        child: Stack(
          children: [
            Positioned.fill(
              child: SurfaceCard(
                radius: 26,
                highlighted: selected,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: onTap,
                child: Row(
                  children: [
                    // Plus'a özel tetikleyici: rozet ikonun köşesinde, başlığa
                    // binmez; Plus olsun olmasın görünür.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconCircle(icon: kind.icon, size: 40, active: selected),
                        if (kind.plusOnly)
                          Positioned(
                            bottom: -6,
                            right: -6,
                            child: IgnorePointer(
                              child: PlusBadge(owned: !locked, compact: true),
                            ),
                          ),
                      ],
                    ),
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
          ],
        ),
      ),
    );
  }
}

/// Tetikleyiciden ne kadar sonra bildirileceği: hazır seçenekler ya da
/// dakika ve saniyeyle özel bir süre.
class _DelayCard extends StatelessWidget {
  const _DelayCard({required this.delay, required this.onChanged});
  final Duration delay;
  final ValueChanged<Duration> onChanged;

  /// Hazır seçenekler (saniye); -1 özel süreyi açar.
  static const _presets = [0, 30, 60, 300, 900];
  static const _custom = -1;

  Future<void> _pickCustom(BuildContext context) async {
    final picked = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DelaySheet(initial: delay),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final seconds = delay.inSeconds;
    final preset = _presets.contains(seconds);
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.clock, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.delayTitle, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<int>(
            values: const [..._presets, _custom],
            value: preset ? seconds : _custom,
            label: (v) => switch (v) {
              _custom when !preset => l10n.delay(delay),
              _custom => l10n.delayCustom,
              _ => l10n.delay(Duration(seconds: v)),
            },
            expand: false,
            onChanged: (v) => v == _custom
                ? _pickCustom(context)
                : onChanged(Duration(seconds: v)),
          ),
          const SizedBox(height: 10),
          Text(
            seconds == 0
                ? l10n.delayHintNow
                : l10n.delayHintAfter(l10n.delay(delay)),
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dakika ve saniye seçici (en fazla 59:59).
class _DelaySheet extends StatefulWidget {
  const _DelaySheet({required this.initial});
  final Duration initial;

  @override
  State<_DelaySheet> createState() => _DelaySheetState();
}

class _DelaySheetState extends State<_DelaySheet> {
  late Duration _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: p.backgroundGradient.first,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: p.surfaceBorder),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.delayPickerTitle, style: t.titleMedium),
          const SizedBox(height: 8),
          CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Theme.of(context).brightness,
              textTheme: CupertinoTextThemeData(
                pickerTextStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: p.text,
                  fontSize: 21,
                ),
              ),
            ),
            child: SizedBox(
              height: 190,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms,
                initialTimerDuration: _value,
                onTimerDurationChanged: (d) => setState(() => _value = d),
              ),
            ),
          ),
          // iOS yerel bildirimi saniyesinde gelir.
          if (!isIOS)
            Text(
              l10n.delayPickerNote,
              style: t.labelSmall?.copyWith(fontSize: 12, color: p.textFaint),
            ),
          const SizedBox(height: 14),
          PrimaryPillButton(
            label: l10n.delayPickerSave,
            expand: true,
            onPressed: () => Navigator.pop(
              context,
              _value > TriggerConfig.maxDelay ? TriggerConfig.maxDelay : _value,
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
      TriggerWait.pluggedIn => from(l10n.waitPluggedIn),
      TriggerWait.unplug => l10n.waitUnplug,
      TriggerWait.alarm => l10n.waitAlarm(l10n.when(at!, now)),
      TriggerWait.alarmSettling => l10n.waitAlarmSettling,
      TriggerWait.noAlarm => l10n.waitNoAlarm,
      TriggerWait.silence => l10n.waitSilence,
      TriggerWait.alreadySilent => l10n.waitAlreadySilent,
      TriggerWait.unsilence => l10n.waitUnsilence,
      TriggerWait.offline => l10n.waitOffline,
      TriggerWait.alreadyOffline => l10n.waitAlreadyOffline,
      TriggerWait.notSilent => l10n.waitNotSilent,
      TriggerWait.none => l10n.waitNone,
    };
    return many
        ? l10n.statusLineKind(w.kind.title(l10n), text)
        : l10n.statusLine(text);
  }

  /// Tetikleyicinin çalışması için bilinmesi gereken tek şey.
  static String _hint(AppLocalizations l10n, TriggerKind kind) => isIOS
      ? l10n.hintShortcut
      : switch (kind) {
          TriggerKind.charging => l10n.hintCharging,
          TriggerKind.alarmStopped => l10n.hintAlarm,
          TriggerKind.leftHomeWifi => l10n.hintWifi,
          TriggerKind.silenced => l10n.hintSilenced,
          TriggerKind.offline => l10n.hintOffline,
          TriggerKind.unsilenced => l10n.hintUnsilenced,
          TriggerKind.nfcTag => l10n.hintNfc,
          TriggerKind.unplugged => l10n.hintUnplugged,
          _ => l10n.hintSoon,
        };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final status = ref.watch(thresholdStatusProvider).value?[mode];
    final kinds = ref.watch(effectiveThresholdsProvider)[mode]!.allKinds;
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
