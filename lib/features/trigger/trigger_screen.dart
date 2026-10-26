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

  void _toggleKind(TriggerConfig c, TriggerKind kind) {
    final next = c.toggle(kind);
    if (identical(next, c)) {
      // Son tetikleyici kaldırılamaz.
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    _update(next);
  }

  Future<void> _pickBackup() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _config.backupTime,
      helpText: 'Yedek bildirim saati',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) _update(_config.copyWith(backupTime: picked));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = _mode == DayMode.evening;
    final c = ref.watch(triggerConfigProvider)[_mode]!;
    final issueCount = ref.watch(setupIssuesProvider)?[_mode]?.length ?? 0;

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
                title: 'Eşiklerim',
                trailing: InfoChip(
                  label: evening ? 'Yatmadan önce' : 'Evden çıkmadan önce',
                  icon: evening ? EsikIcon.moon : EsikIcon.sun,
                ),
              ),
              const SizedBox(height: 14),
              ModeSegment(
                value: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 26),
              ArcRangePicker(
                key: ValueKey(_mode),
                arcStart: evening
                    ? const TimeOfDay(hour: 18, minute: 0)
                    : const TimeOfDay(hour: 4, minute: 0),
                spanMinutes: evening ? 12 * 60 : 8 * 60,
                start: c.windowStart,
                end: c.windowEnd,
                enabled: c.windowEnabled,
                startIcon: evening ? EsikIcon.moon : EsikIcon.sun,
                onChanged: (s, e) =>
                    _update(c.copyWith(windowStart: s, windowEnd: e)),
                child: Column(
                  children: [
                    Text(
                      c.windowEnabled
                          ? '${formatTime(c.windowStart)} – ${formatTime(c.windowEnd)}'
                          : 'Her saatte',
                      textAlign: TextAlign.center,
                      style: t.headlineMedium?.copyWith(
                        fontSize: 34,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      toggled: c.windowEnabled,
                      button: true,
                      label: 'Sadece bu aralıkta',
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _update(c.copyWith(windowEnabled: !c.windowEnabled));
                        },
                        child: InfoChip(
                          label: c.windowEnabled
                              ? 'Sadece bu aralıkta'
                              : 'Aralık kapalı',
                          icon: EsikIcon.clock,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: DotLabel('Ne olunca?'),
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
                      selected: c.kinds.contains(kind),
                      onTap: kind.supported ? () => _toggleKind(c, kind) : null,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  c.kinds.length > 1
                      ? 'Hangisi önce olursa o gün o hatırlatır.'
                      : 'Birden fazla seçebilirsin; hangisi önce olursa o hatırlatır.',
                  style: t.labelSmall?.copyWith(
                    fontSize: 12,
                    color: p.textFaint,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: DotLabel('Hangi günler?'),
              ),
              const SizedBox(height: 10),
              _DayPicker(
                days: c.days,
                onToggle: (d) {
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
                        label: 'Yedek saati değiştir',
                        child: GestureDetector(
                          onTap: _pickBackup,
                          child: Text.rich(
                            TextSpan(
                              text: 'Hiçbiri olmazsa ',
                              children: [
                                TextSpan(
                                  text: timeAt(c.backupTime),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: p.textFaint,
                                  ),
                                ),
                                const TextSpan(text: ' hatırlat'),
                              ],
                            ),
                            style: t.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    EsikSwitch(
                      value: c.backupEnabled,
                      semanticLabel: 'Yedek bildirim',
                      onChanged: (v) => _update(c.copyWith(backupEnabled: v)),
                    ),
                  ],
                ),
              ),
              _StatusLine(mode: _mode),
              const SizedBox(height: 10),
              const _SilentAlertCard(),
              const SizedBox(height: 16),
              PrimaryPillButton(
                label: switch (issueCount) {
                  0 => 'Kurulumu kontrol et',
                  final n => 'Kurulumu tamamla · $n eksik',
                },
                warning: issueCount > 0,
                trailingIcon: EsikIcon.arrowRight,
                expand: true,
                onPressed: _openSetup,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Değişiklikler kendiliğinden kaydedilir',
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

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final TriggerKind kind;
  final bool selected;

  /// Henüz desteklenmeyen tetikleyicide null: kart soluk ve "Yakında" yazar.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final soon = !kind.supported;
    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      label: '${kind.title}, ${soon ? 'yakında' : kind.subtitle}',
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
                      kind.title,
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      soon
                          ? 'Yakında'
                          : selected
                          ? 'Seçili'
                          : kind.subtitle,
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
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          Semantics(
            button: true,
            toggled: days.contains(d),
            label: weekdayNames[d - 1],
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
                  weekdayLetters[d - 1],
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

/// Telefon sessizdeyken bildirim titresin ya da çalsın mı? İki mod için ortak.
class _SilentAlertCard extends ConsumerWidget {
  const _SilentAlertCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final value = ref.watch(silentAlertProvider);
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
              Expanded(
                child: Text('Telefon sessizdeyken', style: t.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<SilentAlert>(
            values: SilentAlert.values,
            value: value,
            label: (a) => a.label,
            icon: (a) => a.icon,
            onChanged: ref.read(silentAlertProvider.notifier).set,
          ),
          const SizedBox(height: 10),
          Text(
            switch (value) {
              SilentAlert.quiet => 'Bildirim telefonun ses ayarına uyar.',
              SilentAlert.vibrate =>
                'Sessizde ya da Rahatsız Etmeyin açıkken de titreşir.',
              SilentAlert.ring when muted => 'Alarm sesi kapalı, bu yüzden duyulmaz. Ses tuşlarıyla alarm sesini aç.',
              SilentAlert.ring =>
                'Sessizde de alarm sesi düzeyinde çalar ve titreşir.',
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
  static String _waiting(TriggerWaiting w, DateTime now, {required bool many}) {
    final at = w.at;
    // Bekleme henüz başlamadıysa ne zaman başlayacağı.
    final later = at != null && at.isAfter(now.add(const Duration(minutes: 1)))
        ? '${formatWhen(at, now)} itibarıyla '
        : '';
    final text = switch (w.wait) {
      TriggerWait.charging =>
        '$later'
            'şarja takılması bekleniyor',
      TriggerWait.wifi => '${later}Wi‑Fi bağlantısı bekleniyor',
      TriggerWait.leaving => 'Wi‑Fi’dan çıkış bekleniyor',
      TriggerWait.alarm => 'sıradaki alarm ${formatWhen(at!, now)}',
      TriggerWait.alarmSettling => 'alarm çaldı, kapanması bekleniyor',
      TriggerWait.noAlarm => 'kurulu alarm yok',
      TriggerWait.silence => 'sesin kısılması bekleniyor',
      TriggerWait.alreadySilent =>
        'telefon zaten tamamen sessizde; önce sesi biraz aç',
      TriggerWait.unsilence => 'sesin açılması bekleniyor',
      TriggerWait.notSilent =>
        'zil zaten açık; gece sesi kısarsan sabah çalışır',
      TriggerWait.none => 'kurulu değil',
    };
    return many ? '${w.kind.title}: $text' : 'Durum: $text';
  }

  /// Tetikleyicinin çalışması için bilinmesi gereken tek şey.
  static String? _hint(TriggerKind kind) => switch (kind) {
    TriggerKind.charging => 'Şarja taktıktan sonra birkaç dakika içinde gelir.',
    TriggerKind.alarmStopped =>
      'Saat uygulamasındaki alarm çalıp kapanınca gelir. Ertelersen bekler.',
    TriggerKind.leftHomeWifi =>
      'Wi‑Fi’dan kopup mobil veriye geçince gelir; mobil veri açık olmalı.',
    TriggerKind.silenced => 'Ses bir kademe kısılınca gelir: sesliden titreşime, titreşimden sessize ya da Rahatsız Etmeyin açılınca.',
    TriggerKind.unsilenced => 'Ses bir kademe açılınca gelir: sessizden titreşime, titreşimden sesliye ya da Rahatsız Etmeyin kapanınca.',
    TriggerKind.nfcTag => 'Etikete dokununca kontrol ekranı açılır.',
    _ => 'Bu tetikleyici yakında. O zamana kadar yedek saat hatırlatır.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final status = ref.watch(thresholdStatusProvider).value?[mode];
    final kinds = ref.watch(triggerConfigProvider)[mode]!.kinds;
    // Android kanalı yoksa (testler) satır gösterilmez.
    if (status == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final lines = [
      status.next == null
          ? 'Yedek bildirim kapalı'
          : 'Sıradaki yedek: ${formatWhen(status.next!, now)}',
      if (status.lastAt != null && status.lastOutcome != null)
        'Son yedek: ${formatWhen(status.lastAt!, now)} ${status.lastOutcome!.description}',
      if (status.triggerAt != null && status.triggerOutcome != null)
        'Son tetik${status.triggerKind == null ? '' : ' (${lowerFirst(status.triggerKind!.title)})'}: '
            '${formatWhen(status.triggerAt!, now)} ${status.triggerOutcome!.description}',
      for (final w in status.waits) _waiting(w, now, many: kinds.length > 1),
      // Tek tetikleyicide ne yapılacağını söyle; çoğunda satırlar yeter.
      if (kinds.length == 1) ?_hint(kinds.single),
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
