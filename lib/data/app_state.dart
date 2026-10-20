import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/day_mode.dart';
import '../ui/esik_icons.dart';
import 'models.dart';

// 2. aşama: liste, tetikleyici ve ilerleme bellekte tutulur. 3. aşamada bu
// notifier'lar aynı arayüzle yerel veritabanına bağlanacak.

/// main() içinde gerçek örnekle override edilir.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding_seen';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}

/// Kullanıcı onboarding'i bitirdi mi?
final onboardingSeenProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class ChecklistNotifier extends Notifier<Map<DayMode, List<CheckItem>>> {
  var _nextId = 100;

  @override
  Map<DayMode, List<CheckItem>> build() => {
    DayMode.evening: const [
      CheckItem(
        id: 'e1',
        title: 'Ütünün fişini çektim mi?',
        icon: EsikIcon.iron,
      ),
      CheckItem(
        id: 'e2',
        title: 'Yapılacaklar listemi tikledim mi?',
        icon: EsikIcon.checklist,
      ),
      CheckItem(id: 'e3', title: 'Kapıyı kilitledim mi?', icon: EsikIcon.lock),
    ],
    DayMode.morning: const [
      CheckItem(
        id: 'm1',
        title: 'Çantama şarj aletini koydum mu?',
        icon: EsikIcon.bag,
      ),
      CheckItem(
        id: 'm2',
        title: 'Akşamdan aldığım notlara baktım mı?',
        icon: EsikIcon.notes,
      ),
      CheckItem(
        id: 'm3',
        title: 'Anahtar ve cüzdan yanımda mı?',
        icon: EsikIcon.key,
      ),
    ],
  };

  void add(DayMode mode, String title, EsikIcon icon) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final item = CheckItem(id: 'n${_nextId++}', title: trimmed, icon: icon);
    state = {
      ...state,
      mode: [...state[mode]!, item],
    };
  }

  void remove(DayMode mode, String id) {
    state = {
      ...state,
      mode: [
        for (final i in state[mode]!)
          if (i.id != id) i,
      ],
    };
  }

  /// [newIndex], öğe yerinden çıkarıldıktan sonraki listedeki hedef sıradır
  /// (ReorderableListView.onReorderItem sözleşmesi).
  void reorder(DayMode mode, int oldIndex, int newIndex) {
    final list = [...state[mode]!];
    list.insert(newIndex, list.removeAt(oldIndex));
    state = {...state, mode: list};
  }

  /// Silmeyi geri almak için.
  void insert(DayMode mode, int index, CheckItem item) {
    final list = [...state[mode]!]
      ..insert(index.clamp(0, state[mode]!.length), item);
    state = {...state, mode: list};
  }
}

final checklistProvider =
    NotifierProvider<ChecklistNotifier, Map<DayMode, List<CheckItem>>>(
      ChecklistNotifier.new,
    );

class TriggerConfigNotifier extends Notifier<Map<DayMode, TriggerConfig>> {
  @override
  Map<DayMode, TriggerConfig> build() => {
    DayMode.evening: const TriggerConfig(
      kind: TriggerKind.charging,
      windowStart: TimeOfDay(hour: 22, minute: 0),
      windowEnd: TimeOfDay(hour: 2, minute: 0),
      backupTime: TimeOfDay(hour: 22, minute: 30),
    ),
    DayMode.morning: const TriggerConfig(
      kind: TriggerKind.alarmStopped,
      windowStart: TimeOfDay(hour: 6, minute: 0),
      windowEnd: TimeOfDay(hour: 10, minute: 0),
      backupTime: TimeOfDay(hour: 8, minute: 15),
    ),
  };

  void update(DayMode mode, TriggerConfig config) =>
      state = {...state, mode: config};
}

final triggerConfigProvider =
    NotifierProvider<TriggerConfigNotifier, Map<DayMode, TriggerConfig>>(
      TriggerConfigNotifier.new,
    );

/// Bugünkü bir eşik kontrolünün durumu.
class CheckSession {
  const CheckSession({this.checked = const {}, this.completedAt});

  final Set<String> checked;
  final DateTime? completedAt;

  bool get isComplete => completedAt != null;
}

class TodayProgressNotifier extends Notifier<Map<DayMode, CheckSession>> {
  @override
  Map<DayMode, CheckSession> build() => {
    DayMode.evening: const CheckSession(),
    DayMode.morning: const CheckSession(),
  };

  void toggle(DayMode mode, String itemId) {
    final s = state[mode]!;
    final checked = {...s.checked};
    if (!checked.remove(itemId)) checked.add(itemId);
    state = {...state, mode: CheckSession(checked: checked)};
  }

  void completeAll(DayMode mode) {
    final ids = ref.read(checklistProvider)[mode]!.map((i) => i.id).toSet();
    final now = ref.read(clockProvider)();
    state = {...state, mode: CheckSession(checked: ids, completedAt: now)};
  }

  void reset(DayMode mode) => state = {...state, mode: const CheckSession()};
}

final todayProgressProvider =
    NotifierProvider<TodayProgressNotifier, Map<DayMode, CheckSession>>(
      TodayProgressNotifier.new,
    );

/// Son 14 günün kaydı. 2. aşamada örnek veridir; 3. aşamada veritabanından gelir.
final historyProvider = Provider<List<DayLog>>((ref) {
  final today = ref.watch(clockProvider)();
  final start = DateTime(today.year, today.month, today.day);
  // Eskiden yeniye 14 gün. a: akşam, s: sabah; d: tamam, y: yedekle, m: atlandı.
  const evening = 'dddmdydddddddd';
  const morning = 'dydddddddddddm';
  const eveningTimes = [
    (22, 51),
    (23, 4),
    (22, 40),
    (0, 0),
    (23, 12),
    (22, 30),
    (23, 40),
    (0, 12),
    (22, 47),
    (23, 2),
    (22, 58),
    (22, 31),
    (23, 15),
    (23, 8),
  ];
  const morningTimes = [
    (7, 42),
    (8, 15),
    (7, 20),
    (7, 55),
    (8, 2),
    (9, 20),
    (10, 5),
    (7, 31),
    (7, 18),
    (7, 46),
    (8, 0),
    (7, 12),
    (7, 38),
    (0, 0),
  ];
  CheckOutcome o(String c) => switch (c) {
    'd' => CheckOutcome.done,
    'y' => CheckOutcome.viaBackup,
    _ => CheckOutcome.missed,
  };
  return [
    for (var i = 0; i < 14; i++)
      DayLog(
        date: start.subtract(Duration(days: 14 - i)),
        evening: o(evening[i]),
        morning: o(morning[i]),
        eveningAt: evening[i] == 'm'
            ? null
            : TimeOfDay(hour: eveningTimes[i].$1, minute: eveningTimes[i].$2),
        morningAt: morning[i] == 'm'
            ? null
            : TimeOfDay(hour: morningTimes[i].$1, minute: morningTimes[i].$2),
      ),
  ];
});
