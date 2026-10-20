import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/esik_icons.dart';
import '../../ui/esik_logo.dart';
import '../../ui/threshold_door.dart';

/// Ana ekran. 1. aşamada başlık, mod anahtarı ve kapı görseliyle iskelet;
/// gün şeridi ve eşik kartları 2. aşamada gelir.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(dayModeProvider);
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final evening = mode == DayMode.evening;

    return Atmosphere(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          children: [
            Row(
              children: [
                EsikLogo(archColor: p.text, lightColor: p.accent),
                const SizedBox(width: 9),
                Text('Eşik', style: t.titleLarge),
                const Spacer(),
                _ModeChip(
                  evening: evening,
                  onTap: ref.read(dayModeProvider.notifier).toggle,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Center(child: ThresholdDoor()),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: p.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  evening ? 'Bu akşamki eşiğin' : 'Bu sabahki eşiğin',
                  style: t.labelMedium?.copyWith(color: p.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              evening ? 'Şarja takınca' : 'Alarmı durdurunca',
              textAlign: TextAlign.center,
              style: t.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              evening
                  ? 'Telefonu şarja taktığında ütü, yapılacaklar ve kapı kontrolün önüne gelir.'
                  : 'Kapıdan çıkmadan önce şarj aleti, notlar ve anahtar–cüzdan kontrolü.',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: () => context.push('/kontrol'),
                style: FilledButton.styleFrom(
                  backgroundColor: p.primaryButton,
                  foregroundColor: p.onPrimaryButton,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: t.labelLarge,
                ),
                icon: EsikIconView(
                  EsikIcon.check,
                  size: 14,
                  color: p.onPrimaryButton,
                  strokeWidth: 2.4,
                ),
                label: const Text('Şimdi kontrol et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.evening, required this.onTap});
  final bool evening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: evening ? 'Akşam modu. Sabaha geç' : 'Sabah modu. Akşama geç',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: p.chip,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.chipBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EsikIconView(
                evening ? EsikIcon.moon : EsikIcon.sun,
                size: 13,
                color: p.text,
                strokeWidth: 2,
              ),
              const SizedBox(width: 6),
              Text(
                evening ? 'Akşam modu' : 'Sabah modu',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
