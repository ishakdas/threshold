import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../l10n/texts.dart';
import 'item_sheet.dart';
import 'templates_sheet.dart';
import '../plus/plus_card.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen>
    with SingleTickerProviderStateMixin {
  late DayMode _mode = ref.read(dayModeProvider);
  final _controller = TextEditingController();
  final _focus = FocusNode();
  EsikIcon _icon = EsikIcon.flame;

  /// Silmenin sola kaydırarak yapıldığını gösteren ipucu: ilk madde kısa
  /// bir an sola kayar, arkasındaki "Sil" görünür, geri döner. İlk
  /// [_peekTimes] açılışta gösterilir; bir kez kaydırarak silinince bir daha
  /// gösterilmez.
  static const _peekKey = 'swipe_hint';
  static const _peekTimes = 3;
  AnimationController? _peekController;
  Animation<double>? _peek;

  @override
  void initState() {
    super.initState();
    final store = ref.read(storeProvider);
    final shown = int.tryParse(store.readString(_peekKey) ?? '') ?? 0;
    if (shown >= _peekTimes) return;
    unawaited(store.writeString(_peekKey, '${shown + 1}'));
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _peekController = controller;
    // Bekle, sola kay, kısa dur, geri dön.
    _peek = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween(1), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 28,
      ),
    ]).animate(controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Hareketleri azalt açıksa gösterme.
      if (MediaQuery.of(context).disableAnimations) return;
      controller.forward().whenComplete(() {
        if (mounted) setState(() => _peek = null);
      });
    });
  }

  @override
  void dispose() {
    _peekController?.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    ref.read(checklistProvider.notifier).add(_mode, _controller.text, _icon);
    _controller.clear();
  }

  void _delete(int index, CheckItem item) {
    HapticFeedback.mediumImpact();
    // Kaydırarak silmeyi öğrendi; ipucu bir daha gösterilmez.
    unawaited(ref.read(storeProvider).writeString(_peekKey, '$_peekTimes'));
    final notifier = ref.read(checklistProvider.notifier)
      ..remove(_mode, item.id);
    final mode = _mode;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          content: Text(context.l10n.itemDeleted(item.title)),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () => notifier.insert(mode, index, item),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final lists = ref.watch(checklistProvider);
    final items = lists[_mode]!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -470,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
            children: [
              ScreenHeader(title: l10n.checklistTitle),
              const SizedBox(height: 14),
              const PlusStrip(),
              ModeSegment(
                value: _mode,
                counts: {for (final e in lists.entries) e.key: e.value.length},
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.checklistEmpty,
                    textAlign: TextAlign.center,
                    style: t.bodyMedium?.copyWith(color: p.textMuted),
                  ),
                ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderStart: (_) => HapticFeedback.mediumImpact(),
                onReorderItem: (o, n) =>
                    ref.read(checklistProvider.notifier).reorder(_mode, o, n),
                proxyDecorator: (child, _, animation) => AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final v = Curves.easeOut.transform(animation.value);
                    return Transform.rotate(
                      angle: -0.014 * v,
                      child: Transform.scale(
                        scale: 1 + 0.03 * v,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45 * v),
                                blurRadius: 40,
                                offset: const Offset(0, 22),
                              ),
                              BoxShadow(
                                color: p.accent.withValues(alpha: 0.15 * v),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: child,
                ),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey('d-${item.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _delete(i, item),
                      background: const _DeleteBackground(),
                      child: GestureDetector(
                        onTap: () => showItemSheet(context, _mode, item),
                        child: i == 0 && _peek != null
                            ? _SwipePeek(
                                animation: _peek!,
                                child: _ItemRow(item: item, index: i),
                              )
                            : _ItemRow(item: item, index: i),
                      ),
                    ),
                  );
                },
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
                  child: Text(
                    '${l10n.checklistHint} ${l10n.checklistEditHint}',
                    style: t.labelMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: p.textFaint,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => showTemplatesSheet(context),
                  icon: EsikIconView(
                    EsikIcon.sparkle,
                    size: 18,
                    color: p.accent,
                  ),
                  label: Text(l10n.templatesButton),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DotLabel(l10n.newItem),
              ),
              const SizedBox(height: 10),
              _NewItemField(
                controller: _controller,
                focusNode: _focus,
                icon: _icon,
                onSubmit: _add,
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  l10n.pickIcon,
                  style: t.labelMedium?.copyWith(color: p.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              _IconPicker(
                selected: _icon,
                onSelected: (icon) => setState(() => _icon = icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.index});
  final CheckItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(13, 0, 6, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.surfaceBorder),
        color: p.backgroundGradient.last,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(p.surfaceTop, p.backgroundGradient[1]),
            Color.alphaBlend(p.surfaceBottom, p.backgroundGradient[1]),
          ],
        ),
      ),
      child: Row(
        children: [
          IconCircle(icon: item.icon, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.days.length < 7 ||
                    item.weather != WeatherNeed.always ||
                    item.photo)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        if (item.photo) ...[
                          EsikIconView(
                            EsikIcon.camera,
                            size: 13,
                            color: p.textMuted,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            [
                              if (item.days.length < 7)
                                l10n.weekdayLetterList.indexed
                                    .where((e) => item.days.contains(e.$1 + 1))
                                    .map((e) => e.$2)
                                    .join(' '),
                              if (item.weather != WeatherNeed.always)
                                item.weather.label(l10n),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontSize: 12, color: p.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Semantics(
              label: l10n.dragToReorder,
              // Yukarı-aşağı oklar: tutup sürükleyerek sıralanabildiği belli olsun.
              child: SizedBox(
                width: 44,
                height: 60,
                child: Center(
                  child: EsikIconView(
                    EsikIcon.upDown,
                    size: 22,
                    color: p.textMuted,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewItemField extends StatelessWidget {
  const _NewItemField({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final EsikIcon icon;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(9, 0, 8, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: p.chip.withValues(alpha: 0.5),
        border: Border.all(color: p.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          IconCircle(icon: icon, size: 46, active: true),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSubmit(),
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: p.accent,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.newItemHint,
                hintStyle: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: p.textFaint),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final enabled = controller.text.trim().isNotEmpty;
              return IconButton.filled(
                tooltip: l10n.add,
                onPressed: enabled ? onSubmit : null,
                style: IconButton.styleFrom(
                  fixedSize: const Size(48, 48),
                  backgroundColor: p.primaryButton,
                  disabledBackgroundColor: p.primaryButton.withValues(
                    alpha: 0.35,
                  ),
                ),
                icon: EsikIconView(
                  EsikIcon.plus,
                  size: 20,
                  strokeWidth: 2,
                  color: p.onPrimaryButton,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({required this.selected, required this.onSelected});
  final EsikIcon selected;
  final ValueChanged<EsikIcon> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: checkItemIcons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final icon = checkItemIcons[i];
          final label = icon.label(l10n)!;
          final isSelected = icon == selected;
          return Semantics(
            selected: isSelected,
            button: true,
            label: label,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(icon);
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? p.text : Colors.transparent,
                        width: 1.8,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? p.accent.withValues(alpha: 0.22)
                            : p.chip.withValues(alpha: 0.35),
                        border: isSelected
                            ? null
                            : Border.all(color: p.chipBorder),
                      ),
                      child: Center(
                        child: EsikIconView(
                          icon,
                          size: 22,
                          strokeWidth: 1.5,
                          color: isSelected ? p.accent : p.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w300,
                      color: isSelected ? p.text : p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kaydırınca maddenin arkasında görünen kırmızı "Sil" alanı.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE5484D),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const EsikIconView(
            EsikIcon.trash,
            size: 20,
            color: Colors.white,
            strokeWidth: 1.8,
          ),
          const SizedBox(height: 3),
          Text(
            context.l10n.delete,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// İpucu animasyonu: [child] sola kayar, arkasında "Sil" görünür.
class _SwipePeek extends StatelessWidget {
  const _SwipePeek({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  /// Kayma miktarı: "Sil" yazısı tam görünecek kadar.
  static const _distance = 96.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Stack(
        children: [
          if (animation.value > 0)
            const Positioned.fill(child: _DeleteBackground()),
          Transform.translate(
            offset: Offset(-_distance * animation.value, 0),
            child: child,
          ),
        ],
      ),
    );
  }
}
