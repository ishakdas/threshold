import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart' show formatTime;
import '../../data/plus.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import 'plus_sheet.dart';

/// Plus alınmadıysa ana ekranların üstünde: deneme günleri ya da ücretsiz
/// sürüm. Dokununca Plus sayfası açılır.
class PlusStrip extends ConsumerWidget {
  const PlusStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(plusProvider).owned) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: PlusCard(),
    );
  }
}

/// Plus durumu: deneme günleri, ücretsiz sürüm ya da satın alındı.
class PlusCard extends ConsumerWidget {
  const PlusCard({super.key});

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
            icon: EsikIcon.sparkle,
            gradient: PlusBadge.gold,
            iconColor: const Color(0xFF3A2306),
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
