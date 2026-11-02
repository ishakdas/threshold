import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/plus.dart';
import '../../data/threshold_templates.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../plus/plus_sheet.dart';

/// Hazır düzenler: iki modun eşiklerini birlikte kurar.
Future<void> showThresholdTemplates(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ThresholdTemplatesSheet(),
    );

/// Eşik şablonunu uygular; Plus gerekiyorsa ve yoksa Plus sayfasını açar.
bool applyThresholdTemplate(
  BuildContext context,
  WidgetRef ref,
  ThresholdTemplate template,
) {
  if (template.plusOnly && !ref.read(plusProvider).active) {
    showPlusSheet(context);
    return false;
  }
  ref.read(thresholdsProvider.notifier).replaceAll({
    for (final mode in DayMode.values) mode: template.thresholds[mode]!,
  });
  return true;
}

class _ThresholdTemplatesSheet extends ConsumerWidget {
  const _ThresholdTemplatesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: p.backgroundGradient.first,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: p.surfaceBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l10n.thresholdTemplates, style: t.titleLarge),
            const SizedBox(height: 6),
            Text(
              l10n.thresholdTemplatesHint,
              style: t.labelMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 14),
            for (final template in thresholdTemplates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ThresholdTemplateCard(
                  template: template,
                  onTap: () {
                    if (!applyThresholdTemplate(context, ref, template)) return;
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                          content: Text(
                            l10n.thresholdTemplateApplied(template.title(l10n)),
                          ),
                        ),
                      );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bir hazır düzenin kartı: adı, açıklaması ve her eşiğin günleriyle saati.
class ThresholdTemplateCard extends ConsumerWidget {
  const ThresholdTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.selected = false,
  });

  final ThresholdTemplate template;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final plus = ref.watch(plusProvider).active;
    return SurfaceCard(
      radius: 24,
      highlighted: selected,
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(template.title(l10n), style: t.bodyLarge)),
              if (template.plusOnly) PlusBadge(owned: plus, compact: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            template.subtitle(l10n),
            style: t.labelMedium?.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: 6),
          for (final mode in DayMode.values)
            for (final c in template.thresholds[mode]!)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    EsikIconView(
                      mode == DayMode.evening ? EsikIcon.moon : EsikIcon.sun,
                      size: 12,
                      color: p.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          c.daysLabel(l10n),
                          c.kinds.first.title(l10n),
                          if (c.windowEnabled)
                            '${formatTime(c.windowStart)}–${formatTime(c.windowEnd)}',
                        ].join(' · '),
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
