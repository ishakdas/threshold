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
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.95,
                children: [
                  for (final kind in TriggerKind.forMode(_mode))
                    _TriggerTile(
                      kind: kind,
                      selected: kind == c.kind,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _update(c.copyWith(kind: kind));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
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
              _BackupStatusLine(mode: _mode),
              const SizedBox(height: 16),
              PrimaryPillButton(
                label: 'Kurulumu kontrol et',
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      button: true,
      label: '${kind.title}, ${kind.subtitle}',
      excludeSemantics: true,
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
                    style: t.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected ? 'Seçili' : kind.subtitle,
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
    );
  }
}

/// "Sıradaki yedek: bugün 14:05 · Son: 08:15 gönderildi". Yedek bildirimin
/// gerçekten kurulduğunu ve son seferde ne olduğunu gösterir.
class _BackupStatusLine extends ConsumerWidget {
  const _BackupStatusLine({required this.mode});
  final DayMode mode;

  static String _when(DateTime at, DateTime now) {
    final t = TimeOfDay.fromDateTime(at);
    final d = DateTime(at.year, at.month, at.day);
    final today = DateTime(now.year, now.month, now.day);
    final day = switch (d.difference(today).inDays) {
      0 => 'bugün',
      1 => 'yarın',
      -1 => 'dün',
      _ => '${at.day}.${at.month}',
    };
    return '$day ${formatTime(t)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final status = ref.watch(backupStatusProvider).value?[mode];
    // Android kanalı yoksa (testler) satır gösterilmez.
    if (status == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final lines = [
      status.next == null
          ? 'Yedek bildirim kapalı'
          : 'Sıradaki yedek: ${_when(status.next!, now)}',
      if (status.lastAt != null && status.lastOutcome != null)
        'Son: ${_when(status.lastAt!, now)} ${status.lastOutcome!.description}',
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
