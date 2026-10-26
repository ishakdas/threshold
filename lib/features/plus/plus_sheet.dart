import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart' show ProductDetails;

import '../../data/plus.dart';
import '../../l10n/texts.dart';
import '../../platform/billing.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../ui/esik_logo.dart';

/// Eşik Plus'ı tanıtan ve satın aldıran alt sayfa. Ücretsiz sürümde kilitli
/// bir özelliğe dokununca ve Ayarlar'daki Plus kartından açılır.
Future<void> showPlusSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => const _PlusSheet(),
);

class _PlusSheet extends ConsumerStatefulWidget {
  const _PlusSheet();

  @override
  ConsumerState<_PlusSheet> createState() => _PlusSheetState();
}

class _PlusSheetState extends ConsumerState<_PlusSheet> {
  late final Future<ProductDetails?> _product = ref
      .read(plusBillingProvider.notifier)
      .product();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final plus = ref.watch(plusProvider);
    final buy = ref.watch(plusBillingProvider);

    Widget feature(EsikIcon icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          IconCircle(icon: icon, size: 34, active: true),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: t.bodyLarge)),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: p.backgroundGradient.first,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: p.surfaceBorder),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                EsikLogo(size: 30, archColor: p.text),
                const SizedBox(width: 10),
                Text(l10n.plusName, style: t.headlineMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.plusTagline,
              style: t.bodyMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 14),
            feature(EsikIcon.checklist, l10n.plusFeatureMulti),
            feature(EsikIcon.nfc, l10n.plusFeatureWifiNfc),
            feature(EsikIcon.clock, l10n.plusFeatureDays),
            feature(EsikIcon.vibrate, l10n.plusFeatureSilent),
            feature(EsikIcon.history, l10n.plusFeatureHistory),
            const SizedBox(height: 14),
            Text(
              plus.owned
                  ? l10n.plusThanks
                  : plus.inTrial
                  ? '${l10n.plusTrialLeft(plus.trialDaysLeft)} · ${l10n.plusOnce}'
                  : l10n.plusOnce,
              style: t.labelMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 16),
            if (plus.owned)
              PrimaryPillButton(
                label: l10n.close,
                icon: EsikIcon.check,
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              )
            else ...[
              FutureBuilder(
                future: _product,
                builder: (context, snap) => PrimaryPillButton(
                  label: switch (snap.data) {
                    final p? => l10n.plusBuy(p.price),
                    null => l10n.plusBuyNoPrice,
                  },
                  expand: true,
                  onPressed: buy == BuyState.pending
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          ref.read(plusBillingProvider.notifier).buy();
                        },
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: buy == BuyState.pending
                      ? null
                      : () => ref.read(plusBillingProvider.notifier).restore(),
                  child: Text(
                    l10n.plusRestore,
                    style: TextStyle(color: p.textMuted),
                  ),
                ),
              ),
              if (buy != BuyState.idle)
                Center(
                  child: Text(
                    buy == BuyState.pending
                        ? l10n.plusPending
                        : l10n.plusUnavailable,
                    textAlign: TextAlign.center,
                    style: t.labelMedium?.copyWith(
                      color: buy == BuyState.error ? p.warning : p.textMuted,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
