import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_state.dart';
import '../../l10n/texts.dart';
import '../../platform/native_bridge.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';

/// Android'in "widget ekle" penceresini açar; açamazsa elle nasıl ekleneceğini
/// söyler.
Future<void> addEsikWidget(BuildContext context, WidgetRef ref) async {
  final opened = await ref.read(nativeBridgeProvider).pinWidget();
  if (opened || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
        content: Text(context.l10n.widgetTipManual),
      ),
    );
}

/// Bugün ekranında bir kez: widget'ın varlığını haber verir. Kapatılınca
/// bir daha görünmez (Ayarlar'da yine eklenebilir).
final widgetTipSeenProvider = NotifierProvider<WidgetTipSeen, bool>(
  WidgetTipSeen.new,
);

class WidgetTipSeen extends Notifier<bool> {
  static const _key = 'widget_tip_seen';

  @override
  bool build() => ref.watch(storeProvider).readString(_key) == 'true';

  void dismiss() {
    state = true;
    ref.read(storeProvider).writeString(_key, 'true');
  }
}

class WidgetTipCard extends ConsumerWidget {
  const WidgetTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return SurfaceCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        children: [
          IconCircle(icon: EsikIcon.widget, size: 40, active: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.widgetTipTitle, style: t.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  l10n.widgetTipBody,
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () async {
                    ref.read(widgetTipSeenProvider.notifier).dismiss();
                    await addEsikWidget(context, ref);
                  },
                  child: Text(l10n.widgetTipAction),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: ref.read(widgetTipSeenProvider.notifier).dismiss,
            icon: EsikIconView(EsikIcon.close, size: 16, color: p.textMuted),
          ),
        ],
      ),
    );
  }
}
