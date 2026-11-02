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
import '../plus/plus_card.dart';
import '../plus/plus_sheet.dart';

/// Eşikler sekmesi: akşam ve sabah eşiklerinin özeti. Her eşik "Düzenle" ile,
/// yenisi "+ … eşiği ekle" ile ayrı ekranda ([ThresholdEditorScreen]) kurulur.
class TriggerScreen extends ConsumerWidget {
  const TriggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final plus = ref.watch(plusProvider).active;
    final all = ref.watch(thresholdsProvider);
    final issues = ref.watch(setupIssuesProvider);
    final issueCount = issues == null
        ? 0
        : {...?issues[DayMode.evening], ...?issues[DayMode.morning]}.length;

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
                trailing: _AppSettingsButton(
                  onTap: () => context.push('/uygulama'),
                ),
              ),
              const SizedBox(height: 14),
              const PlusStrip(),
              for (final mode in DayMode.values) ...[
                _ModeSection(mode: mode, thresholds: all[mode]!, plus: plus),
                const SizedBox(height: 22),
              ],
              SurfaceCard(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                onTap: () => showThresholdTemplates(context),
                child: Row(
                  children: [
                    IconCircle(icon: EsikIcon.sparkle, size: 40, active: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.thresholdTemplates, style: t.bodyLarge),
                          const SizedBox(height: 2),
                          Text(
                            l10n.thresholdTemplatesShort,
                            style: t.labelMedium?.copyWith(color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    EsikIconView(
                      EsikIcon.chevronRight,
                      size: 16,
                      color: p.text,
                    ),
                  ],
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
                onPressed: () => context.push('/kurulum'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Başlıktaki belirgin "Uygulama ayarları" düğmesi.
class _AppSettingsButton extends StatelessWidget {
  const _AppSettingsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: l10n.appSettingsTitle,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: p.primaryButton,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EsikIconView(EsikIcon.gear, size: 18, color: p.onPrimaryButton),
              const SizedBox(width: 6),
              Text(
                l10n.appSettingsShort,
                style: t.labelLarge?.copyWith(color: p.onPrimaryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bir modun (akşam ya da sabah) eşikleri ve "+ … eşiği ekle".
class _ModeSection extends StatelessWidget {
  const _ModeSection({
    required this.mode,
    required this.thresholds,
    required this.plus,
  });

  final DayMode mode;
  final List<TriggerConfig> thresholds;
  final bool plus;

  String get _param => mode == DayMode.evening ? 'aksam' : 'sabah';

  Future<void> _add(BuildContext context) async {
    if (!plus) {
      showPlusSheet(context);
      return;
    }
    final name = await askThresholdName(context, mode);
    if (name == null || !context.mounted) return;
    await context.push(
      '/esik?mod=$_param&yeni=${Uri.encodeQueryComponent(name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = mode == DayMode.evening;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          evening ? l10n.eveningThresholds : l10n.morningThresholds,
          icon: evening ? EsikIcon.moon : EsikIcon.sun,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
          child: Text(
            evening ? l10n.eveningThresholdsHint : l10n.morningThresholdsHint,
            style: t.labelMedium?.copyWith(color: p.textMuted),
          ),
        ),
        for (var i = 0; i < thresholds.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ThresholdCard(
              config: thresholds[i].effective(plus: plus || i > 0),
              locked: !plus && i > 0,
              onEdit: () {
                if (!plus && i > 0) {
                  showPlusSheet(context);
                  return;
                }
                context.push('/esik?mod=$_param&i=$i');
              },
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _add(context),
            icon: EsikIconView(EsikIcon.plus, size: 18, color: p.accent),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  evening ? l10n.addEveningThreshold : l10n.addMorningThreshold,
                  style: t.labelLarge?.copyWith(color: p.accent),
                ),
                if (!plus) ...[
                  const SizedBox(width: 8),
                  PlusBadge(owned: plus, compact: true),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bir eşiğin özeti: adı, günleri, tetikleyicileri, saatleri ve "Düzenle".
class _ThresholdCard extends StatelessWidget {
  const _ThresholdCard({
    required this.config,
    required this.locked,
    required this.onEdit,
  });

  final TriggerConfig config;
  final bool locked;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final c = config;
    Widget line(EsikIcon icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          EsikIconView(icon, size: 14, color: p.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: t.labelMedium?.copyWith(color: p.textMuted),
            ),
          ),
        ],
      ),
    );
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: SurfaceCard(
        radius: 24,
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        onTap: onEdit,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.label(l10n), style: t.titleMedium),
                  if (c.name.isNotEmpty)
                    line(EsikIcon.clock, c.daysLabel(l10n)),
                  line(
                    c.kinds.first.icon,
                    c.kinds.map((k) => k.title(l10n)).join(', '),
                  ),
                  line(
                    EsikIcon.clock,
                    c.windowEnabled
                        ? '${formatTime(c.windowStart)}–${formatTime(c.windowEnd)}'
                        : l10n.anyTime,
                  ),
                  line(
                    EsikIcon.bell,
                    c.backupEnabled
                        ? l10n.backupShort(formatTime(c.backupTime))
                        : l10n.backupOffShort,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: Text(locked ? l10n.plusName : l10n.edit),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yeni eşiğin adı. İptal edilirse null.
Future<String?> askThresholdName(BuildContext context, DayMode mode) {
  final l10n = context.l10n;
  final controller = TextEditingController();
  final suggestions = mode == DayMode.evening
      ? [l10n.daysWeekendNights, l10n.daysWeekdays, l10n.nameHoliday]
      : [l10n.daysWeekend, l10n.daysWeekdays, l10n.nameHoliday];
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void done() {
          final name = controller.text.trim();
          if (name.isNotEmpty) Navigator.pop(context, name);
        }

        return AlertDialog(
          title: Text(
            mode == DayMode.evening
                ? l10n.addEveningThreshold
                : l10n.addMorningThreshold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.thresholdNameHint),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => done(),
                decoration: InputDecoration(hintText: l10n.thresholdNameLabel),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => setState(() => controller.text = s),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty ? null : done,
              child: Text(l10n.thresholdCreate),
            ),
          ],
        );
      },
    ),
  );
}

/// Bir eşiğin bütün ayarları: ad, tetikleyiciler, saat aralığı, günler,
/// gecikme, yedek saat. Değişiklikler "Kaydet"e basınca uygulanır.
/// [index] null ise [newName] adıyla yeni eşik oluşturulur.
class ThresholdEditorScreen extends ConsumerStatefulWidget {
  const ThresholdEditorScreen({
    super.key,
    required this.mode,
    this.index,
    this.newName,
  });

  final DayMode mode;
  final int? index;
  final String? newName;

  @override
  ConsumerState<ThresholdEditorScreen> createState() =>
      _ThresholdEditorScreenState();
}

class _ThresholdEditorScreenState extends ConsumerState<ThresholdEditorScreen> {
  DayMode get _mode => widget.mode;
  late final List<TriggerConfig> _list = ref.read(thresholdsProvider)[_mode]!;
  late final bool _isNew =
      widget.index == null || widget.index! >= _list.length;
  late final int _index = _isNew ? _list.length : widget.index!;
  late TriggerConfig _draft = _initialDraft();
  late final _name = TextEditingController(text: _draft.name);

  /// Yeni eşik: ilk eşiğin ayarlarının kopyası. Hafta sonu başka bir
  /// eşiğin tek günleri değilse oraya, değilse hiçbir eşiğin olmayan
  /// günlere kurulur; günleri kullanıcı seçer.
  TriggerConfig _initialDraft() {
    if (!_isNew) return _list[_index];
    final weekend = _mode == DayMode.evening ? {5, 6} : {6, 7};
    final takeable = weekend.where(
      (d) => _list.every((c) => !c.days.contains(d) || c.days.length > 1),
    );
    return _list.first.copyWith(
      name: widget.newName ?? '',
      days: takeable.isEmpty ? <int>{} : takeable.toSet(),
    );
  }

  /// Başka eşiklere ait günler.
  Set<int> get _others => {
    for (var i = 0; i < _list.length; i++)
      if (i != _index) ..._list[i].days,
  };

  void _update(TriggerConfig c) => setState(() => _draft = c);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toggleDay(int weekday) {
    final days = {..._draft.days};
    if (days.contains(weekday)) {
      // Kendi son günü kapatılamaz (eşik hiç çalışmazdı).
      if (days.length == 1) {
        HapticFeedback.heavyImpact();
        return;
      }
      days.remove(weekday);
    } else {
      // Başka eşiğin tek günü alınamaz.
      final owner = _list.indexWhere((c) => c.days.contains(weekday));
      if (owner >= 0 && owner != _index && _list[owner].days.length == 1) {
        HapticFeedback.heavyImpact();
        return;
      }
      days.add(weekday);
    }
    HapticFeedback.selectionClick();
    _update(_draft.copyWith(days: days));
  }

  void _save() {
    if (_draft.days.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.thresholdNeedsDay)));
      return;
    }
    final config = _draft.copyWith(name: _name.text.trim());
    HapticFeedback.mediumImpact();
    ref
        .read(thresholdsProvider.notifier)
        .set(_mode, _list.withEdited(_index, config));
    context.pop();
  }

  void _delete() {
    HapticFeedback.mediumImpact();
    ref.read(thresholdsProvider.notifier).set(_mode, _list.without(_index));
    context.pop();
  }

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
    final c = _draft;
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
    _update(_draft.copyWith(windowStart: s, windowEnd: e));
  }

  Future<void> _pickBackup() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _draft.backupTime,
      helpText: context.l10n.backupTimeHelp,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) _update(_draft.copyWith(backupTime: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = _mode == DayMode.evening;
    final plus = ref.watch(plusProvider).active;
    final c = _draft;
    // Plus yoksa geçerli olan gösterilir (tek ücretsiz tetikleyici, her gün).
    final shown = c.effective(plus: plus);
    // "Hiçbiri olmazsa {saat} hatırlat": saat altı çizili, ortasından böl.
    final backupParts = l10n.backupRow('\u0000').split('\u0000');

    Widget section(String title, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(
        children: [
          Expanded(child: SectionTitle(title)),
          ?trailing,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -260,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    ScreenHeader(
                      title: _isNew
                          ? (evening
                                ? l10n.addEveningThreshold
                                : l10n.addMorningThreshold)
                          : l10n.editThreshold,
                      onBack: () => context.pop(),
                      trailing: InfoChip(
                        label: evening ? l10n.beforeBed : l10n.beforeLeaving,
                        icon: evening ? EsikIcon.moon : EsikIcon.sun,
                      ),
                    ),
                    section(l10n.thresholdNameLabel),
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      style: t.titleMedium,
                      cursorColor: p.accent,
                      decoration: InputDecoration(
                        hintText: c.daysLabel(l10n),
                        filled: true,
                        fillColor: p.chip.withValues(alpha: 0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    section(
                      l10n.whichDays,
                      trailing: PlusBadge(owned: plus, compact: true),
                    ),
                    WeekdayPicker(
                      days: shown.days,
                      others: plus ? _others : const {},
                      onToggle: (d) {
                        if (!plus) {
                          showPlusSheet(context);
                          return;
                        }
                        _toggleDay(d);
                      },
                    ),
                    if (plus && _others.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.thresholdDaysHint,
                        style: t.labelSmall?.copyWith(
                          fontSize: 12,
                          color: p.textFaint,
                        ),
                      ),
                    ],
                    section(l10n.whatTriggers),
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
                    Row(
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
                    section(l10n.whichHours),
                    ArcRangePicker(
                      key: ValueKey(_mode),
                      arcStart: _arcStart,
                      spanMinutes: _arcSpan,
                      start: c.windowStart,
                      end: c.windowEnd,
                      enabled: c.windowEnabled,
                      startIcon: evening ? EsikIcon.moon : EsikIcon.sun,
                      onChanged: (s, e) => _update(
                        _draft.copyWith(windowStart: s, windowEnd: e),
                      ),
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
                                _update(
                                  c.copyWith(windowEnabled: !c.windowEnabled),
                                );
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
                    section(l10n.delayTitle),
                    _DelayCard(
                      delay: c.delay,
                      onChanged: (d) => _update(c.copyWith(delay: d)),
                    ),
                    section(l10n.backupTitle),
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
                            onChanged: (v) =>
                                _update(c.copyWith(backupEnabled: v)),
                          ),
                        ],
                      ),
                    ),
                    if (!_isNew) _StatusLine(mode: _mode),
                    if (!_isNew && _list.length > 1)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _delete,
                          icon: EsikIconView(
                            EsikIcon.trash,
                            size: 16,
                            color: p.textMuted,
                          ),
                          label: Text(
                            l10n.thresholdRemove(_list[_index].label(l10n)),
                            style: t.labelLarge?.copyWith(color: p.textMuted),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: PrimaryPillButton(
                  label: _isNew ? l10n.thresholdCreate : l10n.saveLabel,
                  expand: true,
                  onPressed: _save,
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
