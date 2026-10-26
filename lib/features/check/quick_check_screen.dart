import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/animated_check.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import 'glow_orb.dart';

/// Bildirime dokununca açılan hızlı kontrol. Büyük, tiklenebilir maddeler.
class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key, this.mode, this.fromBackup = false});

  /// Boşsa günün o anki modu kullanılır.
  final DayMode? mode;

  /// Yedek saatteki bildirimden açıldıysa; geçmişte "yedek bildirimle" görünür.
  final bool fromBackup;

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  Timer? _autoComplete;

  DayMode get _mode => widget.mode ?? ref.read(dayModeProvider);

  @override
  void dispose() {
    _autoComplete?.cancel();
    super.dispose();
  }

  void _toggle(CheckItem item, bool wasChecked) {
    final progress = ref.read(todayProgressProvider.notifier);
    progress.toggle(_mode, item.id);
    if (!wasChecked) {
      // Dolum bitince ikinci, daha belirgin titreşim.
      Future.delayed(
        const Duration(milliseconds: 240),
        HapticFeedback.mediumImpact,
      );
    }
    // Bütün maddeler tek tek tiklendiyse kısa bir an bekleyip tamamla.
    _autoComplete?.cancel();
    final items = ref.read(checklistProvider)[_mode]!;
    final checked = ref.read(todayProgressProvider)[_mode]!.checked;
    if (items.every((i) => checked.contains(i.id))) {
      _autoComplete = Timer(const Duration(milliseconds: 650), _completeAll);
    }
  }

  void _completeAll() {
    HapticFeedback.heavyImpact();
    ref
        .read(todayProgressProvider.notifier)
        .completeAll(
          _mode,
          source: widget.fromBackup
              ? CheckSession.sourceBackup
              : CheckSession.sourceApp,
        );
  }

  void _close() => context.canPop() ? context.pop() : context.go('/bugun');

  @override
  Widget build(BuildContext context) {
    final DayMode mode = widget.mode ?? ref.watch(dayModeProvider);
    final items = ref.watch(checklistProvider)[mode]!;
    final session = ref.watch(todayProgressProvider)[mode]!;
    final config = ref.watch(triggerConfigProvider)[mode]!;
    final evening = mode == DayMode.evening;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -120,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOut,
              child: session.isComplete
                  ? _DoneView(
                      key: const ValueKey('done'),
                      mode: mode,
                      items: items,
                      completedAt: session.completedAt!,
                      onUndo: () =>
                          ref.read(todayProgressProvider.notifier).reset(mode),
                      onClose: _close,
                    )
                  : Column(
                      key: const ValueKey('list'),
                      children: [
                        ScreenHeader(
                          title: evening ? 'Akşam kontrolü' : 'Sabah kontrolü',
                          onBack: _close,
                          trailing: InfoChip(
                            label: config.shortTitle,
                            icon: config.kinds.first.icon,
                            iconColor: context.palette.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlowOrb(
                          progress: items.isEmpty
                              ? 0
                              : session.checked.length / items.length,
                          child: Semantics(
                            label:
                                '${session.checked.length} / ${items.length} tamamlandı',
                            excludeSemantics: true,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${session.checked.length}/${items.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: 52,
                                        color: Colors.white,
                                      ),
                                ),
                                Text(
                                  'tamamlandı',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: items.length + 1,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              if (i == items.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Maddeye dokun, tik at',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w300,
                                          color: context.palette.textFaint,
                                        ),
                                  ),
                                );
                              }
                              final item = items[i];
                              final checked = session.checked.contains(item.id);
                              return CheckRow(
                                item: item,
                                checked: checked,
                                onTap: () => _toggle(item, checked),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: SecondaryPillButton(
                                label: '10 dk sonra',
                                icon: EsikIcon.clock,
                                height: 56,
                                onPressed: _close,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 14,
                              child: PrimaryPillButton(
                                label: 'Hepsi tamam',
                                icon: EsikIcon.check,
                                height: 56,
                                expand: true,
                                onPressed: items.isEmpty ? null : _completeAll,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Büyük, tamamı dokunulabilir madde satırı.
class CheckRow extends StatefulWidget {
  const CheckRow({
    super.key,
    required this.item,
    required this.checked,
    required this.onTap,
  });

  final CheckItem item;
  final bool checked;
  final VoidCallback onTap;

  @override
  State<CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<CheckRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      checked: widget.checked,
      label: widget.item.title,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        },
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 80,
            padding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: widget.checked
                    ? p.accent.withValues(alpha: 0.5)
                    : p.surfaceBorder,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.checked
                    ? [
                        p.accent.withValues(alpha: 0.26),
                        p.accent.withValues(alpha: 0.10),
                      ]
                    : [p.surfaceTop, p.surfaceBottom],
              ),
            ),
            child: Row(
              children: [
                IconCircle(
                  icon: widget.item.icon,
                  size: 56,
                  active: widget.checked,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedCheck(checked: widget.checked, pressed: _pressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({
    super.key,
    required this.mode,
    required this.items,
    required this.completedAt,
    required this.onUndo,
    required this.onClose,
  });

  final DayMode mode;
  final List<CheckItem> items;
  final DateTime completedAt;
  final VoidCallback onUndo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = mode == DayMode.evening;
    final at = formatTime(TimeOfDay.fromDateTime(completedAt));
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GlowOrb(
                    progress: 1,
                    size: 250,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: const EsikIconView(
                        EsikIcon.check,
                        size: 68,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  DotLabel(
                    '${evening ? 'Akşam' : 'Sabah'} kontrolü · $at',
                    center: true,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hepsi tamam',
                    style: t.headlineLarge?.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    evening
                        ? 'İçin rahat. İyi geceler.'
                        : 'Hazırsın. İyi günler.',
                    style: t.bodyLarge?.copyWith(color: p.textMuted),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final i in items)
                        InfoChip(label: _shortLabel(i), icon: i.icon),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 10,
              child: SecondaryPillButton(
                label: 'Geri al',
                onPressed: onUndo,
                height: 56,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 14,
              child: PrimaryPillButton(
                label: 'Kapat',
                onPressed: onClose,
                height: 56,
                expand: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Etikette maddenin ikonunun kısa adı kullanılır ("Ütü", "Kilit").
  static String _shortLabel(CheckItem item) {
    for (final (icon, label) in checkItemIcons) {
      if (icon == item.icon) return label;
    }
    return item.title.split(' ').first;
  }
}
