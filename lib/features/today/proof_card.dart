import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/photos.dart';
import '../../data/weather.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';

/// "Kilitledim mi?": bugün fotoğrafla kontrol edilen maddeler, saatleri ve
/// fotoğrafları. Evden çıktıktan sonra gelen şüpheye cevap.
class ProofCard extends ConsumerWidget {
  const ProofCard({super.key});

  /// Gösterilecek bir şey var mı (fotoğraflı madde ya da çekilmiş fotoğraf).
  static bool visible(WidgetRef ref) {
    final items = ref.watch(todayItemsProvider);
    return items.values.any((l) => l.any((i) => i.photo));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final items = ref.watch(todayItemsProvider);
    final progress = ref.watch(todayProgressProvider);
    final dir = ref.watch(photosDirProvider).value;
    final rows = <(CheckItem, CheckSession)>[
      // Önce sabah: evden çıktıktan sonra en çok aranan.
      for (final mode in [DayMode.morning, DayMode.evening])
        for (final item in items[mode]!)
          if (item.photo) (item, progress[mode]!),
    ];
    return SurfaceCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.camera, size: 18, color: p.text),
              const SizedBox(width: 10),
              Text(l10n.proofTitle, style: t.titleMedium),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.proofSubtitle,
            style: t.labelMedium?.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: 8),
          for (final (item, session) in rows)
            _ProofRow(
              item: item,
              at:
                  session.checkedAt[item.id] ??
                  (session.checked.contains(item.id)
                      ? session.completedAt
                      : null),
              photo: switch ((dir, session.photos[item.id])) {
                (final Directory d, final String name) => File(
                  '${d.path}/$name',
                ),
                _ => null,
              },
            ),
        ],
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({required this.item, required this.at, required this.photo});
  final CheckItem item;
  final DateTime? at;
  final File? photo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final file = photo != null && photo!.existsSync() ? photo : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: file == null ? null : () => _open(context, file),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 54,
                height: 54,
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover, cacheWidth: 162)
                    : ColoredBox(
                        color: p.chip.withValues(alpha: 0.4),
                        child: Center(
                          child: EsikIconView(
                            item.icon,
                            size: 22,
                            color: p.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: t.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  at == null
                      ? l10n.proofNotYet
                      : l10n.proofAt(l10n.at(TimeOfDay.fromDateTime(at!))),
                  style: t.labelMedium?.copyWith(
                    color: at == null ? p.accent : p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (at != null)
            EsikIconView(EsikIcon.check, size: 18, color: p.accent),
        ],
      ),
    );
  }

  void _open(BuildContext context, File file) => showDialog<void>(
    context: context,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: InteractiveViewer(child: Image.file(file)),
    ),
  );
}
