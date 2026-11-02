import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/templates.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';

/// Hazır şablonlar: dokunulan şablonun maddeleri listeye eklenir.
Future<void> showTemplatesSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TemplatesSheet(),
    );

class _TemplatesSheet extends ConsumerWidget {
  const _TemplatesSheet();

  void _add(BuildContext context, WidgetRef ref, ChecklistTemplate template) {
    final l10n = context.l10n;
    final notifier = ref.read(checklistProvider.notifier);
    final before = ref.read(checklistProvider);
    final count = before.values.fold(0, (n, l) => n + l.length);
    for (final e in template.build(l10n).entries) {
      if (e.value.isNotEmpty) notifier.addAll(e.key, e.value);
    }
    final added =
        ref.read(checklistProvider).values.fold(0, (n, l) => n + l.length) -
        count;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          content: Text(
            added == 0 ? l10n.templatesNothingNew : l10n.templatesAdded(added),
          ),
        ),
      );
  }

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
            Text(l10n.templatesTitle, style: t.titleLarge),
            const SizedBox(height: 6),
            Text(
              l10n.templatesHint,
              style: t.labelMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 14),
            for (final template in checklistTemplates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  radius: 24,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  onTap: () => _add(context, ref, template),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconCircle(icon: template.icon, size: 42, active: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(template.title(l10n), style: t.bodyLarge),
                            const SizedBox(height: 4),
                            for (final item in template.items)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Row(
                                  children: [
                                    EsikIconView(
                                      item.mode == DayMode.evening
                                          ? EsikIcon.moon
                                          : EsikIcon.sun,
                                      size: 12,
                                      color: p.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.title(l10n),
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
                      ),
                      EsikIconView(EsikIcon.plus, size: 18, color: p.accent),
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
