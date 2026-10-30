import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/native_bridge.dart';
import '../../data/plus.dart';

/// Eşik'in çalışmasını engelleyen, kullanıcının düzeltebileceği bir eksik.
enum SetupIssue { notifications, battery, nfcOff, nfcTag, noAlarm, shortcut }

extension SetupIssueText on SetupIssue {
  String label(AppLocalizations l) => switch (this) {
    SetupIssue.notifications => l.issueNotifications,
    SetupIssue.battery => l.issueBattery,
    SetupIssue.nfcOff => l.issueNfcOff,
    SetupIssue.nfcTag => l.issueNfcTag,
    SetupIssue.noAlarm => l.issueNoAlarm,
    SetupIssue.shortcut => l.issueShortcut,
  };
}

/// Bir modun tetikleyicisine özel eksikler. iOS'ta tek eksik, Kestirmeler
/// otomasyonunun henüz hiç çalışmamış olması.
List<SetupIssue> triggerIssues(SetupHealth h, TriggerKind kind) => isIOS
    ? [if (!h.shortcutsSeen.contains(kind)) SetupIssue.shortcut]
    : [
        if (kind == TriggerKind.nfcTag && h.nfc != NfcState.on)
          SetupIssue.nfcOff,
        if (kind == TriggerKind.nfcTag && !h.nfcTagWritten) SetupIssue.nfcTag,
        if (kind == TriggerKind.alarmStopped && h.nextAlarm == null)
          SetupIssue.noAlarm,
      ];

/// Bir modun bütün eksikleri: ortak olanlar ve seçili tetikleyicilere özel olanlar.
List<SetupIssue> setupIssues(SetupHealth h, List<TriggerKind> kinds) => [
  if (!h.notifications) SetupIssue.notifications,
  if (!h.battery) SetupIssue.battery,
  for (final kind in kinds) ...triggerIssues(h, kind),
];

/// Her mod için eksikler. Android kanalı yoksa (testler) null.
final setupIssuesProvider = Provider<Map<DayMode, List<SetupIssue>>?>((ref) {
  final health = ref.watch(setupHealthProvider).value;
  if (health == null) return null;
  final configs = ref.watch(effectiveTriggerConfigProvider);
  return {
    for (final mode in DayMode.values)
      mode: setupIssues(health, configs[mode]!.kinds),
  };
});
