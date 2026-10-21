import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/store.dart';
import 'package:threshold/ui/esik_icons.dart';

void main() {
  late SharedPreferences prefs;
  var now = DateTime(2026, 10, 20, 22, 14);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 10, 20, 22, 14);
  });

  /// Uygulamayı yeniden açmayı taklit eder: aynı depoyla yeni bir kapsayıcı.
  ProviderContainer open() {
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // Yazmalar beklenmeden yapılır; mikro görevlerin bitmesini bekle.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('eşik günü', () {
    test('04:00 öncesi bir önceki güne sayılır', () {
      expect(
        thresholdDay(DateTime(2026, 10, 21, 0, 12)),
        DateTime(2026, 10, 20),
      );
      expect(
        thresholdDay(DateTime(2026, 10, 21, 3, 59)),
        DateTime(2026, 10, 20),
      );
      expect(
        thresholdDay(DateTime(2026, 10, 21, 4, 0)),
        DateTime(2026, 10, 21),
      );
      expect(
        thresholdDay(DateTime(2026, 10, 20, 22, 14)),
        DateTime(2026, 10, 20),
      );
    });

    test('ay ve yıl sınırında doğru', () {
      expect(thresholdDay(DateTime(2027, 1, 1, 1, 0)), DateTime(2026, 12, 31));
      expect(dayKey(DateTime(2026, 3, 5)), '2026-03-05');
      expect(parseDayKey('2026-03-05'), DateTime(2026, 3, 5));
      expect(parseDayKey('bozuk'), isNull);
    });
  });

  test('liste değişiklikleri yeniden açılışta korunur', () async {
    final a = open();
    final n = a.read(checklistProvider.notifier);
    n.add(DayMode.evening, 'Ocağı kapattım mı?', EsikIcon.flame);
    n.reorder(DayMode.evening, 3, 0);
    n.remove(DayMode.morning, 'm2');
    await flush();

    final b = open();
    final evening = b.read(checklistProvider)[DayMode.evening]!;
    expect(evening.first.title, 'Ocağı kapattım mı?');
    expect(evening.first.icon, EsikIcon.flame);
    expect(evening, hasLength(4));
    expect(b.read(checklistProvider)[DayMode.morning]!.map((i) => i.id), [
      'm1',
      'm3',
    ]);
  });

  test('eşik ayarları yeniden açılışta korunur', () async {
    final a = open();
    a
        .read(triggerConfigProvider.notifier)
        .update(
          DayMode.morning,
          defaultTriggerConfigs[DayMode.morning]!.copyWith(
            kind: TriggerKind.nfcTag,
            windowStart: const TimeOfDay(hour: 6, minute: 30),
            backupEnabled: false,
          ),
        );
    await flush();

    final c = open().read(triggerConfigProvider)[DayMode.morning]!;
    expect(c.kind, TriggerKind.nfcTag);
    expect(c.windowStart, const TimeOfDay(hour: 6, minute: 30));
    expect(c.backupEnabled, isFalse);
  });

  test('bozuk kayıt varsayılana düşer, uygulama çökmez', () async {
    await prefs.setString(EsikStore.checklistKey, '{bozuk json');
    await prefs.setString(
      EsikStore.triggersKey,
      '{"evening":{"kind":"nfcTag","windowStart":"99:99"}}',
    );
    final c = open();
    expect(c.read(checklistProvider), defaultChecklist);
    final evening = c.read(triggerConfigProvider)[DayMode.evening]!;
    // nfcTag bir sabah tetikleyicisi; akşama yazılmışsa varsayılan kullanılır.
    expect(evening.kind, TriggerKind.charging);
    expect(evening.windowStart, const TimeOfDay(hour: 22, minute: 0));
  });

  test('bugünün ilerlemesi kalıcıdır, ertesi gün sıfırlanır', () async {
    final a = open();
    a.read(todayProgressProvider.notifier).toggle(DayMode.evening, 'e1');
    await flush();
    expect(open().read(todayProgressProvider)[DayMode.evening]!.checked, {
      'e1',
    });

    // Gece yarısını geçmek aynı eşik günüdür.
    now = DateTime(2026, 10, 21, 0, 30);
    expect(open().read(todayProgressProvider)[DayMode.evening]!.checked, {
      'e1',
    });

    // Ertesi akşam yeni gün.
    now = DateTime(2026, 10, 21, 21, 0);
    expect(
      open().read(todayProgressProvider)[DayMode.evening]!.checked,
      isEmpty,
    );
  });

  test('uygulama açıkken gün değişirse ön plana dönüşte yenilenir', () {
    final c = open();
    c.read(todayProgressProvider.notifier).completeAll(DayMode.evening);
    expect(c.read(todayProgressProvider)[DayMode.evening]!.isComplete, isTrue);

    now = DateTime(2026, 10, 21, 21, 0);
    c.read(clockTickProvider.notifier).refresh();
    expect(c.read(todayProgressProvider)[DayMode.evening]!.isComplete, isFalse);
  });

  test(
    'geçmiş: kurulumdan önceki günler kayıt yok, sonrası gerçek sonuç',
    () async {
      // Kurulum 15 Ekim; bugün 20 Ekim.
      await prefs.setString(EsikStore.installedOnKey, '2026-10-15');
      final c = open();
      final log = c.read(checkLogProvider.notifier);
      log.complete(DateTime(2026, 10, 18), DayMode.evening, {
        'e1',
        'e2',
        'e3',
      }, DateTime(2026, 10, 19, 0, 12));

      final h = c.read(historyProvider);
      expect(h, hasLength(14));
      expect(h.first.date, DateTime(2026, 10, 6));
      expect(h.last.date, DateTime(2026, 10, 19));

      DayLog on(int day) => h.firstWhere((l) => l.date.day == day);
      expect(on(14).evening, CheckOutcome.notTracked);
      expect(on(15).evening, CheckOutcome.missed);
      expect(on(18).evening, CheckOutcome.done);
      expect(on(18).eveningAt, const TimeOfDay(hour: 0, minute: 12));
      expect(on(18).morning, CheckOutcome.missed);
    },
  );

  test('ilk açılışta kurulum günü kaydedilir', () async {
    open().read(installDayProvider);
    await flush();
    expect(prefs.getString(EsikStore.installedOnKey), '2026-10-20');
  });

  test('bir yıldan eski kayıtlar budanır', () async {
    final c = open();
    final log = c.read(checkLogProvider.notifier);
    log.toggle(DateTime(2025, 1, 1), DayMode.evening, 'e1');
    log.toggle(DateTime(2026, 10, 20), DayMode.evening, 'e1');
    expect(c.read(checkLogProvider).keys, ['2026-10-20']);
  });
}
