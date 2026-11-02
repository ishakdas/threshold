import 'package:threshold/features/trigger/arc_range_picker.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/theme/esik_palette.dart';

import 'helpers.dart';

void main() {
  testWidgets('akşam açılışı: lacivert tema ve akşam eşiği', (tester) async {
    await pumpApp(tester);

    expect(find.text('Eşik'), findsOneWidget);
    expect(find.text('Şarja takınca'), findsOneWidget);
    expect(find.text('Bu akşamki eşiğin'), findsOneWidget);
    expect(find.text('Akşam modu'), findsOneWidget);

    final context = tester.element(find.text('Şarja takınca'));
    expect(Theme.of(context).extension<EsikPalette>(), EsikPalette.evening);
  });

  testWidgets('sabah açılışı: alarm eşiği büyük kartta', (tester) async {
    await pumpApp(tester, now: morningNow);

    expect(find.text('Alarmı durdurunca'), findsOneWidget);
    expect(find.text('Bu sabahki eşiğin'), findsOneWidget);
  });

  testWidgets('mod anahtarı sabaha geçirir', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Akşam modu'));
    await tester.pumpAndSettle();

    expect(find.text('Alarmı durdurunca'), findsOneWidget);
    expect(find.text('Sabah modu'), findsOneWidget);
  });

  testWidgets('ilk açılışta onboarding, Atla ile ana ekran', (tester) async {
    await pumpApp(tester, onboardingSeen: false);

    expect(find.text('Eşik’e hoş geldin'), findsOneWidget);
    await tester.tap(find.text('Atla'));
    await tester.pumpAndSettle();

    expect(find.text('Şarja takınca'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_seen'), isTrue);
  });

  testWidgets(
    'onboarding: düzen ve paket seçilir, özet gösterilir, kuruluma götürür',
    (tester) async {
      await pumpApp(tester, onboardingSeen: false);

      await tester.tap(find.bySemanticsLabel('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Saat değil, an.'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Haftalık rutinin nasıl?'), findsOneWidget);
      await tester.tap(find.text('Hafta içi iş, hafta sonu rahat'));
      await tester.pumpAndSettle();

      // Paketler: ilk ikisi seçili gelir; "Havaya göre" de eklenir.
      await tester.tap(find.bySemanticsLabel('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Kontrol listeni hazırla'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.bySemanticsLabel('Havaya göre'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.bySemanticsLabel('Havaya göre'));
      await tester.pumpAndSettle();

      // Özet: ne zaman ve hangi maddeler.
      await tester.tap(find.bySemanticsLabel('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Eşik böyle çalışacak'), findsOneWidget);
      expect(find.text('Şemsiyemi aldım mı?'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Kuruluma başla'), findsOneWidget);

      await tester.tap(find.text('Kuruluma başla'));
      await tester.pumpAndSettle();
      expect(find.text('Kurulum'), findsOneWidget);
      expect(find.text('Bildirimlere izin ver'), findsWidgets);

      final c = ProviderScope.containerOf(tester.element(find.text('Kurulum')));
      expect(c.read(thresholdsProvider)[DayMode.morning], hasLength(2));
      final morning = c
          .read(checklistProvider)[DayMode.morning]!
          .map((i) => i.title);
      expect(morning, contains('Şemsiyemi aldım mı?'));
      expect(morning, contains('Anahtarlarım yanımda mı?'));
      // Paket seçilince örnek liste kalkar.
      expect(morning, isNot(contains('Çantama şarj aletini koydum mu?')));
    },
  );

  testWidgets('sekmeler: liste, geçmiş, ayarlar', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Liste'));
    await tester.pumpAndSettle();
    expect(find.text('Kontrol listem'), findsOneWidget);
    expect(find.text('Ütünün fişini çektim mi?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Geçmiş').last);
    await tester.pumpAndSettle();
    expect(find.text('Eşik etkinliği'), findsOneWidget);
    // Yeni kurulum: henüz geçmiş yok.
    expect(find.bySemanticsLabel('Henüz kayıt yok'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Eşikler'));
    await tester.pumpAndSettle();
    expect(find.text('Eşiklerim'), findsOneWidget);
    expect(find.text('Akşam eşikleri'), findsOneWidget);
    expect(find.text('22:00–02:00'), findsOneWidget);

    // Düzenle: eşiğin ekranı; saate dokununca saat seçici açılır.
    await tester.tap(find.text('Düzenle').first);
    await tester.pumpAndSettle();
    expect(find.text('Eşiği düzenle'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('22:00'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('22:00'));
    await tester.pumpAndSettle();
    expect(find.text('Aralığın başlangıcı'), findsOneWidget);
  });

  testWidgets('saat tutamacı sürüklenince sayfa kaymaz, saat değişir', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Eşikler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Düzenle').first);
    await tester.pumpAndSettle();

    final picker = find.byType(ArcRangePicker);
    await tester.scrollUntilVisible(
      picker,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    final box = tester.renderObject<RenderBox>(picker);
    final w = box.size.width;
    final r = (w - 40) / 2;
    final center = box.localToGlobal(Offset(w / 2, r + 22));
    // Akşam yayı 18:00–06:00; bitiş 02:00, yayın üçte ikisinde.
    const f = 2 / 3;
    final a = math.pi * (1 - f);
    final knob = center + Offset(math.cos(a), -math.sin(a)) * r;

    final list = find.byType(Scrollable).first;
    final before = tester.state<ScrollableState>(list).position.pixels;
    // Dikey sürükleme: önceden sayfa kaydırması kazanırdı.
    await tester.dragFrom(knob, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(tester.state<ScrollableState>(list).position.pixels, before);
    final c = ProviderScope.containerOf(tester.element(picker));
    // Kaydedilene kadar ayar değişmez.
    expect(
      c.read(thresholdsProvider)[DayMode.evening]!.first.windowEnd,
      const TimeOfDay(hour: 2, minute: 0),
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(
      c.read(thresholdsProvider)[DayMode.evening]!.first.windowEnd,
      isNot(const TimeOfDay(hour: 2, minute: 0)),
    );
  });
}
