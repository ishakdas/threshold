import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/features/setup/setup_guide_screen.dart';
import 'package:threshold/ui/esik_icons.dart';

void main() {
  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
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

  test('her mod yalnızca kendi tetikleyicilerini sunar', () {
    expect(TriggerKind.forMode(DayMode.evening), hasLength(4));
    expect(
      TriggerKind.forMode(DayMode.morning)
          .every((k) => k.mode == DayMode.morning),
      isTrue,
    );
  });

  test('kurulum adımları tetikleyiciye göre değişir', () {
    List<String> steps(TriggerKind k) =>
        setupStepsFor(k).map((s) => s.title).toList();
    expect(steps(TriggerKind.charging), [
      'Bildirimlere izin ver',
      'Arka planda çalışmasına izin ver',
      'Dene',
    ]);
    expect(steps(TriggerKind.appClosed), contains('Kullanım erişimi ver'));
    expect(steps(TriggerKind.leftHomeWifi), contains('Ev Wi‑Fi’ını seç'));
    expect(steps(TriggerKind.nfcTag), contains('Etiketi hazırla'));
  });

  test('geçmiş 14 gün, dünle biter', () {
    final c = container();
    final logs = c.read(historyProvider);
    expect(logs, hasLength(14));
    expect(logs.last.date, DateTime(2026, 10, 19));
  });

  test('lowerFirst Türkçe harfleri doğru küçültür', () {
    expect(lowerFirst('Alarmı durdurunca'), 'alarmı durdurunca');
    expect(lowerFirst('İnstagram'), 'instagram');
    expect(lowerFirst('Işık'), 'ışık');
  });
}
