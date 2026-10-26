import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/plus.dart';

import 'helpers.dart';

void main() {
  Future<ProviderContainer> container(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        turkishDevice,
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 20, 22, 14)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('deneme ve satın alma', () {
    test('ilk gün 15 gün kalır', () async {
      final c = await container({});
      final plus = c.read(plusProvider);
      expect(plus.trialDaysLeft, 15);
      expect(plus.inTrial, isTrue);
      expect(plus.active, isTrue);
    });

    test('15 gün sonra deneme biter', () async {
      final c = await container({'installed_on': '2026-10-05'});
      expect(c.read(plusProvider).trialDaysLeft, 0);
      expect(c.read(plusProvider).active, isFalse);
    });

    test('veriler silinse de deneme eski başlangıçtan sayılır', () async {
      // Veriler silindi: uygulama bugün kurulmuş sanıyor, ama Android'in
      // kurulum zamanı (trial_start) 20 gün önce.
      final c = await container({
        'installed_on': '2026-10-20',
        'trial_start': DateTime(2026, 9, 30, 12).millisecondsSinceEpoch,
      });
      expect(c.read(plusProvider).trialDaysLeft, 0);
      expect(c.read(plusProvider).active, isFalse);
    });

    test('satın alınca deneme bitse de açık kalır ve saklanır', () async {
      final c = await container({'installed_on': '2026-09-01'});
      c.read(plusOwnedProvider.notifier).set(true);
      expect(c.read(plusProvider).active, isTrue);
      expect(c.read(sharedPreferencesProvider).getBool('plus_owned'), isTrue);
    });
  });

  test('Plus yoksa tek ve ücretsiz tetikleyici, her gün', () {
    const morning = TriggerConfig(
      kinds: [TriggerKind.leftHomeWifi, TriggerKind.unsilenced],
      days: {1, 2, 3, 4, 5},
      windowStart: TimeOfDay(hour: 6, minute: 0),
      windowEnd: TimeOfDay(hour: 10, minute: 0),
      backupTime: TimeOfDay(hour: 8, minute: 15),
    );
    final free = morning.effective(plus: false);
    expect(free.kinds, [TriggerKind.unsilenced]);
    expect(free.days, allWeekdays);
    expect(morning.effective(plus: true), same(morning));
    // Hiç ücretsiz tetikleyici seçili değilse modun varsayılanı.
    expect(
      morning
          .copyWith(kinds: [TriggerKind.nfcTag])
          .effective(plus: false)
          .kinds,
      [TriggerKind.alarmStopped],
    );
  });

  group('ücretsiz sürüm', () {
    const expired = {'installed_on': '2026-09-01'};

    testWidgets(
      'Plus’a özel tetikleyici Plus sayfasını açar, satın alınca açılır',
      (tester) async {
        FakePlusBilling.buyCount = 0;
        await pumpApp(tester, now: morningNow, prefs: expired);
        await tester.tap(find.bySemanticsLabel('Ayarlar'));
        await tester.pumpAndSettle();
        expect(find.text('Ücretsiz sürüm'), findsOneWidget);

        await tester.tap(find.textContaining('Wi‑Fi’ından çıkınca'));
        await tester.pumpAndSettle();
        expect(find.text('Eşik Plus'), findsWidgets);
        expect(find.text('Birden fazla tetikleyici'), findsOneWidget);

        await tester.tap(find.text('Plus’ı al'));
        await tester.pumpAndSettle();
        expect(FakePlusBilling.buyCount, 1);
        expect(find.text('Teşekkürler! Plus artık sende.'), findsOneWidget);
      },
    );

    testWidgets('ücretsiz sürümde başka tetikleyiciye dokununca o seçilir', (
      tester,
    ) async {
      await pumpApp(tester, prefs: expired);
      await tester.tap(find.bySemanticsLabel('Ayarlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sessize alınca'));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.text('Eşiklerim')),
      );
      expect(c.read(triggerConfigProvider)[DayMode.evening]!.kinds, [
        TriggerKind.silenced,
      ]);
    });

    testWidgets('geçmiş yerine Plus tanıtımı', (tester) async {
      await pumpApp(tester, prefs: expired);
      GoRouter.of(tester.element(find.text('Eşik'))).go('/gecmis');
      await tester.pumpAndSettle();
      expect(find.text('Geçmiş Plus ile'), findsOneWidget);
    });

    testWidgets('denemenin son günlerinde Bugün’de uyarı', (tester) async {
      await pumpApp(tester, prefs: {'installed_on': '2026-10-08'});
      expect(find.text('Plus denemesinin son 3 günü'), findsOneWidget);
    });
  });
}
