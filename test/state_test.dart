import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/features/setup/setup_guide_screen.dart';
import 'package:threshold/ui/esik_icons.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 20, 22, 14)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  List<String> titles(ProviderContainer c, DayMode m) =>
      c.read(checklistProvider)[m]!.map((i) => i.title).toList();

  group('kontrol listesi', () {
    test('ekleme boş metni yok sayar, metni kırpar', () {
      final c = container();
      final n = c.read(checklistProvider.notifier);
      n.add(DayMode.evening, '   ', EsikIcon.flame);
      n.add(DayMode.evening, '  Ocağı kapattım mı?  ', EsikIcon.flame);
      expect(titles(c, DayMode.evening).last, 'Ocağı kapattım mı?');
      expect(titles(c, DayMode.evening), hasLength(4));
      expect(titles(c, DayMode.morning), hasLength(3));
    });

    test('sıralama: ilk madde en sona', () {
      final c = container();
      c.read(checklistProvider.notifier).reorder(DayMode.evening, 0, 2);
      expect(titles(c, DayMode.evening), [
        'Yapılacaklar listemi tikledim mi?',
        'Kapıyı kilitledim mi?',
        'Ütünün fişini çektim mi?',
      ]);
    });

    test('silme ve geri alma aynı yere koyar', () {
      final c = container();
      final n = c.read(checklistProvider.notifier);
      final item = c.read(checklistProvider)[DayMode.evening]![1];
      n.remove(DayMode.evening, item.id);
      expect(titles(c, DayMode.evening), hasLength(2));
      n.insert(DayMode.evening, 1, item);
      expect(titles(c, DayMode.evening)[1], item.title);
    });
  });

  test('tümünü tamamla saati kaydeder, sıfırla temizler', () {
    final c = container();
    final n = c.read(todayProgressProvider.notifier);
    n.completeAll(DayMode.evening);
    final s = c.read(todayProgressProvider)[DayMode.evening]!;
    expect(s.isComplete, isTrue);
    expect(s.checked, hasLength(3));
    expect(s.completedAt, DateTime(2026, 10, 20, 22, 14));
    n.reset(DayMode.evening);
    expect(c.read(todayProgressProvider)[DayMode.evening]!.checked, isEmpty);
  });

  test('çalışan tetikleyiciler önce, sessiz mod ikisi de çalışır', () {
    expect(TriggerKind.forMode(DayMode.evening).take(2), [
      TriggerKind.charging,
      TriggerKind.silenced,
    ]);
    expect(TriggerKind.forMode(DayMode.morning).take(2), [
      TriggerKind.alarmStopped,
      TriggerKind.unsilenced,
    ]);
    expect(TriggerKind.forMode(DayMode.morning).last.supported, isFalse);
  });

  test('her mod yalnızca kendi tetikleyicilerini sunar', () {
    expect(TriggerKind.forMode(DayMode.evening), hasLength(5));
    expect(
      TriggerKind.forMode(DayMode.morning)
          .every((k) => k.mode == DayMode.morning),
      isTrue,
    );
  });

  test('kurulum adımları tetikleyiciye göre değişir', () {
    List<String> steps(TriggerKind k) =>
        setupStepsFor([k]).map((s) => s.title).toList();
    expect(steps(TriggerKind.charging), [
      'Bildirimlere izin ver',
      'Arka planda çalışmasına izin ver',
      'Dene',
    ]);
    expect(steps(TriggerKind.appClosed), contains('Kullanım erişimi ver'));
    expect(steps(TriggerKind.leftHomeWifi), contains('Mobil veri açık kalsın'));
    expect(steps(TriggerKind.nfcTag), contains('Etiketi hazırla'));
    expect(steps(TriggerKind.silenced), contains('Ek izin gerekmez'));
    expect(steps(TriggerKind.unsilenced), hasLength(4));
  });

  test('geçmiş 14 gün, dünle biter', () {
    final c = container();
    final logs = c.read(historyProvider);
    expect(logs, hasLength(14));
    expect(logs.last.date, DateTime(2026, 10, 19));
  });

  group('birden fazla tetikleyici ve günler', () {
    const base = TriggerConfig(
      kinds: [TriggerKind.alarmStopped],
      windowStart: TimeOfDay(hour: 6, minute: 0),
      windowEnd: TimeOfDay(hour: 10, minute: 0),
      backupTime: TimeOfDay(hour: 8, minute: 15),
    );

    test('tetikleyiciler sıralı eklenir, sonuncusu çıkarılamaz', () {
      final two = base
          .toggle(TriggerKind.nfcTag)
          .toggle(TriggerKind.unsilenced);
      expect(two.kinds, [
        TriggerKind.alarmStopped,
        TriggerKind.unsilenced,
        TriggerKind.nfcTag,
      ]);
      expect(base.toggle(TriggerKind.alarmStopped), same(base));
      expect(two.title, 'Alarmı durdurunca +2');
      final pair = base.toggle(TriggerKind.unsilenced);
      expect(pair.title, 'Alarmı durdurunca ya da sessizden çıkarınca');
      expect(
        pair.when,
        'Alarmı durdurduğunda ya da telefonu sessizden çıkardığında',
      );
    });

    test('son gün çıkarılamaz', () {
      var c = base;
      for (var d = 1; d <= 6; d++) {
        c = c.toggleDay(d);
      }
      expect(c.days, {7});
      expect(c.toggleDay(7), same(c));
    });

    test('eski kayıttaki tek tetikleyici okunur', () {
      final c = TriggerConfig.fromJson({'kind': 'nfcTag'}, base);
      expect(c.kinds, [TriggerKind.nfcTag]);
      expect(c.days, allWeekdays);
    });

    test('izin günü geçmişte atlandı sayılmaz', () async {
      SharedPreferences.setMockInitialValues({'installed_on': '2026-10-01'});
      prefs = await SharedPreferences.getInstance();
      final c = container();
      c
          .read(triggerConfigProvider.notifier)
          .update(
            DayMode.evening,
            c
                .read(triggerConfigProvider)[DayMode.evening]!
                .copyWith(days: {1, 2, 3, 4, 5}),
          );
      final logs = c.read(historyProvider);
      final sunday = logs.firstWhere((l) => l.date == DateTime(2026, 10, 18));
      final monday = logs.firstWhere((l) => l.date == DateTime(2026, 10, 19));
      expect(sunday.evening, CheckOutcome.off);
      expect(sunday.morning, CheckOutcome.missed);
      expect(monday.evening, CheckOutcome.missed);
    });

    test('kurulum her tetikleyicinin adımını içerir', () {
      final titles = setupStepsFor([
        TriggerKind.alarmStopped,
        TriggerKind.nfcTag,
      ]).map((s) => s.title);
      expect(
        titles,
        containsAllInOrder([
          'Sabah alarmın kurulu olsun',
          'Etiketi hazırla',
          'Dene',
        ]),
      );
    });
  });

  test('lowerFirst Türkçe harfleri doğru küçültür', () {
    expect(lowerFirst('Alarmı durdurunca'), 'alarmı durdurunca');
    expect(lowerFirst('İnstagram'), 'instagram');
    expect(lowerFirst('Işık'), 'ışık');
  });
}
