import 'dart:async';

import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/day_mode.dart';
import '../l10n/app_localizations.dart';
import '../ui/esik_icons.dart';
import 'models.dart';
import 'store.dart';

/// main() içinde gerçek örnekle override edilir.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

final storeProvider = Provider<EsikStore>(
  (ref) => EsikStore(ref.watch(sharedPreferencesProvider)),
);

// ---------------------------------------------------------------------------
// Dil

/// Uygulamanın dili. [system] telefonun dilini izler; desteklenmiyorsa İngilizce.
/// Android tarafı (EsikData.language) bildirim metinleri için aynı kaydı okur.
enum AppLanguage { system, tr, en, es }

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final saved = ref.watch(storeProvider).readString(EsikStore.languageKey);
    return AppLanguage.values.where((l) => l.name == saved).firstOrNull ??
        AppLanguage.system;
  }

  void set(AppLanguage value) {
    state = value;
    unawaited(
      ref.read(storeProvider).writeString(EsikStore.languageKey, value.name),
    );
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

/// Telefonun dili; testlerde override edilir.
final deviceLocaleProvider = Provider<Locale>(
  (ref) => PlatformDispatcher.instance.locale,
);

/// Gösterilecek dil: seçilen ya da telefonunki (desteklenmiyorsa İngilizce).
final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(languageProvider);
  if (language != AppLanguage.system) return Locale(language.name);
  final device = ref.watch(deviceLocaleProvider).languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == device,
  );
  return Locale(supported ? device : 'en');
});

/// Widget dışında (varsayılan liste, Android'e giden metinler) çeviriler.
final l10nProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(localeProvider)),
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
class SilentAlertNotifier extends Notifier<SilentAlert> {
  @override
  SilentAlert build() {
    final saved = ref.watch(storeProvider).readString(EsikStore.silentAlertKey);
    return SilentAlert.values.where((a) => a.name == saved).firstOrNull ??
        SilentAlert.quiet;
  }

  void set(SilentAlert value) {
    state = value;
    unawaited(
      ref.read(storeProvider).writeString(EsikStore.silentAlertKey, value.name),
    );
  }
}

/// Sessizdeyken bildirim titresin ya da çalsın mı? Android bildirimi
/// gönderirken diskten okur.
final silentAlertProvider = NotifierProvider<SilentAlertNotifier, SilentAlert>(
  SilentAlertNotifier.new,
);

final onboardingSeenProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

/// Uygulamanın ilk açıldığı eşik günü. Ondan önceki günler geçmişte
/// "atlandı" değil "kayıt yok" sayılır.
final installDayProvider = Provider<DateTime>((ref) {
  final store = ref.watch(storeProvider);
  final saved = parseDayKey(store.readString(EsikStore.installedOnKey) ?? '');
  if (saved != null) return saved;
  final today = thresholdDay(ref.read(clockProvider)());
  unawaited(store.writeString(EsikStore.installedOnKey, dayKey(today)));
  return today;
});

// ---------------------------------------------------------------------------
// Kontrol listesi

/// İlk açılıştaki örnek liste, uygulamanın o anki dilinde.
Map<DayMode, List<CheckItem>> defaultChecklistFor(AppLocalizations l) => {
  DayMode.evening: [
    CheckItem(id: 'e1', title: l.defaultEveningIron, icon: EsikIcon.iron),
    CheckItem(id: 'e2', title: l.defaultEveningTodo, icon: EsikIcon.checklist),
    CheckItem(id: 'e3', title: l.defaultEveningLock, icon: EsikIcon.lock),
  ],
  DayMode.morning: [
    CheckItem(id: 'm1', title: l.defaultMorningCharger, icon: EsikIcon.bag),
    CheckItem(id: 'm2', title: l.defaultMorningNotes, icon: EsikIcon.notes),
    CheckItem(id: 'm3', title: l.defaultMorningKeys, icon: EsikIcon.key),
  ],
};

class ChecklistNotifier extends Notifier<Map<DayMode, List<CheckItem>>> {
  var _counter = 0;

  EsikStore get _store => ref.read(storeProvider);

  @override
  Map<DayMode, List<CheckItem>> build() {
    final json = ref.watch(storeProvider).readJson(EsikStore.checklistKey);
    final defaults = defaultChecklistFor(ref.read(l10nProvider));
    if (json == null) {
      // Android tarafı (bildirim metni) listeyi diskten okur; varsayılanı da yaz.
      _persist(defaults);
      return defaults;
    }
    try {
      return {
        for (final mode in DayMode.values)
          mode: [
            for (final e in (json[mode.name] as List? ?? const []))
              if (e is Map<String, Object?>) CheckItem.fromJson(e),
          ],
      };
    } on Object {
      // Beklenmedik biçimde kayıt: kullanıcıyı boş listeyle bırakmaktansa
      // varsayılan listeye dön.
      return defaults;
    }
  }

  void _save(Map<DayMode, List<CheckItem>> next) {
    state = next;
    _persist(next);
  }

  void _persist(Map<DayMode, List<CheckItem>> lists) => unawaited(
    _store.writeJson(EsikStore.checklistKey, {
      for (final e in lists.entries)
        e.key.name: [for (final i in e.value) i.toJson()],
    }),
  );

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_counter++}';

  void add(DayMode mode, String title, EsikIcon icon) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final item = CheckItem(id: _newId(), title: trimmed, icon: icon);
    _save({
      ...state,
      mode: [...state[mode]!, item],
    });
  }

  void remove(DayMode mode, String id) {
    _save({
      ...state,
      mode: [
        for (final i in state[mode]!)
          if (i.id != id) i,
      ],
    });
  }

  /// [newIndex], öğe yerinden çıkarıldıktan sonraki listedeki hedef sıradır
  /// (ReorderableListView.onReorderItem sözleşmesi).
  void reorder(DayMode mode, int oldIndex, int newIndex) {
    final list = [...state[mode]!];
    list.insert(newIndex, list.removeAt(oldIndex));
    _save({...state, mode: list});
  }

  /// Silmeyi geri almak için.
  void insert(DayMode mode, int index, CheckItem item) {
    final list = [...state[mode]!]
      ..insert(index.clamp(0, state[mode]!.length), item);
    _save({...state, mode: list});
  }
}

final checklistProvider =
    NotifierProvider<ChecklistNotifier, Map<DayMode, List<CheckItem>>>(
      ChecklistNotifier.new,
    );

// ---------------------------------------------------------------------------
// Eşik ayarları

const defaultTriggerConfigs = <DayMode, TriggerConfig>{
  DayMode.evening: TriggerConfig(
    kinds: [TriggerKind.charging],
    windowStart: TimeOfDay(hour: 22, minute: 0),
    windowEnd: TimeOfDay(hour: 2, minute: 0),
    backupTime: TimeOfDay(hour: 22, minute: 30),
  ),
  DayMode.morning: TriggerConfig(
    kinds: [TriggerKind.alarmStopped],
    windowStart: TimeOfDay(hour: 6, minute: 0),
    windowEnd: TimeOfDay(hour: 10, minute: 0),
    backupTime: TimeOfDay(hour: 8, minute: 15),
  ),
};

class TriggerConfigNotifier extends Notifier<Map<DayMode, TriggerConfig>> {
  @override
  Map<DayMode, TriggerConfig> build() {
    final json = ref.watch(storeProvider).readJson(EsikStore.triggersKey);
    if (json == null) {
      // Android tarafı yedek saati diskten okur; varsayılanı da yaz.
      _persist(defaultTriggerConfigs);
      return defaultTriggerConfigs;
    }
    return {
      for (final mode in DayMode.values)
        mode: switch (json[mode.name]) {
          final Map<String, Object?> m => TriggerConfig.fromJson(
            m,
            defaultTriggerConfigs[mode]!,
          ),
          _ => defaultTriggerConfigs[mode]!,
        },
    };
  }

  /// Son yazmanın bitişi. Android ayarı diskten okuduğu için alarmlar ancak
  /// bu tamamlandıktan sonra yeniden kurulmalı.
  Future<void> saved = Future.value();

  void update(DayMode mode, TriggerConfig config) {
    final next = {...state, mode: config};
    // Önce yazmayı başlat: state değişince dinleyiciler hemen çalışır ve
    // [saved]'i bu yazmanın kendisi olarak görmeliler.
    _persist(next);
    state = next;
  }

  void _persist(Map<DayMode, TriggerConfig> configs) {
    saved = ref.read(storeProvider).writeJson(EsikStore.triggersKey, {
      for (final e in configs.entries) e.key.name: e.value.toJson(),
    });
  }
}

final triggerConfigProvider =
    NotifierProvider<TriggerConfigNotifier, Map<DayMode, TriggerConfig>>(
      TriggerConfigNotifier.new,
    );

// ---------------------------------------------------------------------------
// Günlük kayıt: eşik günü → mod → kontrol

typedef CheckLog = Map<String, Map<DayMode, CheckSession>>;

class CheckLogNotifier extends Notifier<CheckLog> {
  /// Bundan eski kayıtlar silinir; geçmiş ekranı yalnızca son 14 günü gösterir.
  static const keepDays = 400;

  @override
  CheckLog build() {
    final json =
        ref.watch(storeProvider).readJson(EsikStore.logKey) ?? const {};
    final log = <String, Map<DayMode, CheckSession>>{};
    for (final day in json.entries) {
      final modes = day.value;
      if (parseDayKey(day.key) == null || modes is! Map<String, Object?>) {
        continue;
      }
      log[day.key] = {
        for (final mode in DayMode.values)
          if (modes[mode.name] case final Map<String, Object?> s)
            mode: CheckSession.fromJson(s),
      };
    }
    return log;
  }

  CheckSession session(DateTime day, DayMode mode) =>
      state[dayKey(day)]?[mode] ?? const CheckSession();

  void _put(DateTime day, DayMode mode, CheckSession session) {
    final key = dayKey(day);
    final next = {...state};
    final modes = {...?next[key]};
    if (session.isEmpty) {
      modes.remove(mode);
    } else {
      modes[mode] = session;
    }
    if (modes.isEmpty) {
      next.remove(key);
    } else {
      next[key] = modes;
    }
    final oldest = thresholdDay(ref.read(clockProvider)())
        .subtract(const Duration(days: keepDays));
    next.removeWhere((k, _) => parseDayKey(k)!.isBefore(oldest));
    state = next;
    unawaited(
      ref.read(storeProvider).writeJson(EsikStore.logKey, {
        for (final d in next.entries)
          d.key: {
            for (final m in d.value.entries) m.key.name: m.value.toJson(),
          },
      }),
    );
  }

  void toggle(DateTime day, DayMode mode, String itemId) {
    final checked = {...session(day, mode).checked};
    if (!checked.remove(itemId)) checked.add(itemId);
    _put(day, mode, CheckSession(checked: checked));
  }

  void complete(
    DateTime day,
    DayMode mode,
    Set<String> ids,
    DateTime at, {
    String source = CheckSession.sourceApp,
  }) => _put(
    day,
    mode,
    CheckSession(checked: ids, completedAt: at, source: source),
  );

  void reset(DateTime day, DayMode mode) =>
      _put(day, mode, const CheckSession());
}

final checkLogProvider = NotifierProvider<CheckLogNotifier, CheckLog>(
  CheckLogNotifier.new,
);

/// Bugünün (eşik gününün) iki kontrolü. Ekranlar bunu kullanır; veri
/// [checkLogProvider]'da kalıcıdır, gün değişince kendiliğinden boşalır.
class TodayProgressNotifier extends Notifier<Map<DayMode, CheckSession>> {
  @override
  Map<DayMode, CheckSession> build() {
    final key = dayKey(ref.watch(todayProvider));
    final day = ref.watch(checkLogProvider)[key];
    return {
      for (final mode in DayMode.values)
        mode: day?[mode] ?? const CheckSession(),
    };
  }

  CheckLogNotifier get _log => ref.read(checkLogProvider.notifier);
  DateTime get _today => ref.read(todayProvider);

  void toggle(DayMode mode, String itemId) => _log.toggle(_today, mode, itemId);

  /// [source]: kontrol yedek saatteki bildirimden açıldıysa
  /// [CheckSession.sourceBackup]; geçmişte "yedek bildirimle" görünür.
  void completeAll(DayMode mode, {String source = CheckSession.sourceApp}) {
    final ids = ref.read(checklistProvider)[mode]!.map((i) => i.id).toSet();
    _log.complete(_today, mode, ids, ref.read(clockProvider)(), source: source);
  }

  void reset(DayMode mode) => _log.reset(_today, mode);
}

final todayProgressProvider =
    NotifierProvider<TodayProgressNotifier, Map<DayMode, CheckSession>>(
      TodayProgressNotifier.new,
    );

/// Bugünden önceki 14 eşik günü, eskiden yeniye.
final historyProvider = Provider<List<DayLog>>((ref) {
  final today = ref.watch(todayProvider);
  final installed = ref.watch(installDayProvider);
  final log = ref.watch(checkLogProvider);
  final configs = ref.watch(triggerConfigProvider);

  (CheckOutcome, TimeOfDay?) outcome(DateTime day, DayMode mode) {
    if (day.isBefore(installed)) return (CheckOutcome.notTracked, null);
    final s = log[dayKey(day)]?[mode];
    if (s == null || !s.isComplete) {
      // Günler bugünkü ayardan okunur; geçmiş ayarlar saklanmıyor.
      final off = !configs[mode]!.activeOn(day);
      return (off ? CheckOutcome.off : CheckOutcome.missed, null);
    }
    return (
      s.viaBackup ? CheckOutcome.viaBackup : CheckOutcome.done,
      TimeOfDay.fromDateTime(s.completedAt!),
    );
  }

  return [
    for (var i = 14; i >= 1; i--)
      () {
        // Gün eklerken saat değil takvim kullan (yaz saati geçişlerine karşı).
        final day = DateTime(today.year, today.month, today.day - i);
        final (e, eAt) = outcome(day, DayMode.evening);
        final (m, mAt) = outcome(day, DayMode.morning);
        return DayLog(
          date: day,
          evening: e,
          morning: m,
          eveningAt: eAt,
          morningAt: mAt,
        );
      }(),
  ];
});
