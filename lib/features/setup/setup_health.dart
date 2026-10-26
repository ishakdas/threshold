import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../platform/native_bridge.dart';

/// Eşik'in çalışmasını engelleyen, kullanıcının düzeltebileceği bir eksik.
enum SetupIssue {
  notifications('Bildirimler kapalı'),
  battery('Pil kısıtlaması açık'),
  nfcOff('NFC kapalı'),
  nfcTag('Etiket henüz yazılmadı'),
  noAlarm('Kurulu alarm yok');

  const SetupIssue(this.label);
  final String label;
}

/// Bir modun tetikleyicisine özel eksikler.
List<SetupIssue> triggerIssues(SetupHealth h, TriggerKind kind) => [
  if (kind == TriggerKind.nfcTag && h.nfc != NfcState.on) SetupIssue.nfcOff,
  if (kind == TriggerKind.nfcTag && !h.nfcTagWritten) SetupIssue.nfcTag,
  if (kind == TriggerKind.alarmStopped && h.nextAlarm == null)
    SetupIssue.noAlarm,
];

/// Bir modun bütün eksikleri: ortak olanlar ve tetikleyiciye özel olanlar.
List<SetupIssue> setupIssues(SetupHealth h, TriggerKind kind) => [
  if (!h.notifications) SetupIssue.notifications,
  if (!h.battery) SetupIssue.battery,
  ...triggerIssues(h, kind),
];

/// Her mod için eksikler. Android kanalı yoksa (testler) null.
final setupIssuesProvider = Provider<Map<DayMode, List<SetupIssue>>?>((ref) {
  final health = ref.watch(setupHealthProvider).value;
  if (health == null) return null;
  final configs = ref.watch(triggerConfigProvider);
  return {
    for (final mode in DayMode.values)
      mode: setupIssues(health, configs[mode]!.kind),
  };
});
