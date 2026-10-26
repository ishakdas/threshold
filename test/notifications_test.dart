import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/store.dart';
import 'package:threshold/platform/native_bridge.dart';

import 'package:threshold/features/setup/setup_health.dart';

import 'helpers.dart';

const _channel = MethodChannel('esik/native');

/// Android tarafını taklit eder; yapılan çağrıları kaydeder.
List<MethodCall> fakeNative(
  WidgetTester? tester, {
  bool permission = true,
  bool testSent = true,
  String nfc = 'written',
  Map<String, Object?> Function()? health,
}) {
  final calls = <MethodCall>[];
  final messenger =
      tester?.binding.defaultBinaryMessenger ??
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_channel, (call) async {
    calls.add(call);
    return switch (call.method) {
      'requestNotificationPermission' || 'notificationsGranted' => permission,
      'showTestNotification' => testSent,
      'writeNfcTag' => nfc,
      'setupHealth' => health?.call(),
      _ => null,
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(_channel, null));
  return calls;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeBridge', () {
    test('Android kanalı yoksa sessizce varsayılan döner', () async {
      final bridge = NativeBridge();
      expect(await bridge.requestNotificationPermission(), isFalse);
      expect(await bridge.showTestNotification(DayMode.evening), isFalse);
      expect(await bridge.takeLaunchRoute(), isNull);
    });

    test('çağrıları doğru adla ve argümanla gönderir', () async {
      final calls = fakeNative(null);
      final bridge = NativeBridge();
      expect(await bridge.requestNotificationPermission(), isTrue);
      expect(await bridge.showTestNotification(DayMode.morning), isTrue);
      expect(calls.map((c) => c.method), [
        'requestNotificationPermission',
        'showTestNotification',
      ]);
      expect(calls.last.arguments, {'mode': 'morning'});
    });
  });

  test('durum: yedek ve tetikleyici sonuçları okunur', () {
    final at = DateTime(2026, 10, 23, 7, 2);
    final status = ThresholdStatus.parse({
      'morning': {
        'next': null,
        'lastAt': null,
        'lastOutcome': null,
        'triggerAt': at.millisecondsSinceEpoch,
        'triggerOutcome': 'shown',
      },
      'evening': {'next': 0, 'triggerOutcome': 'bilinmeyen'},
    })!;
    expect(status[DayMode.morning]!.triggerAt, at);
    expect(status[DayMode.morning]!.triggerOutcome, NotifyOutcome.shown);
    expect(status[DayMode.morning]!.next, isNull);
    expect(status[DayMode.evening]!.triggerOutcome, isNull);
    expect(status[DayMode.evening]!.waits, isEmpty);
  });

  test('durum: tetikleyicinin beklediği şey okunur', () {
    final at = DateTime(2026, 10, 24, 7, 0);
    final status = ThresholdStatus.parse({
      'morning': {
        'triggerKind': 'alarmStopped',
        'triggerWaits': [
          {
            'kind': 'alarmStopped',
            'wait': 'alarm',
            'at': at.millisecondsSinceEpoch,
          },
          {'kind': 'unsilenced', 'wait': 'unsilence', 'at': null},
          {'kind': 'bilinmeyen', 'wait': 'alarm'},
        ],
      },
      'evening': {
        'triggerWaits': [
          {'kind': 'charging', 'wait': 'charging', 'at': null},
        ],
      },
    })!;
    final morning = status[DayMode.morning]!;
    expect(morning.triggerKind, TriggerKind.alarmStopped);
    expect(morning.waits.map((w) => (w.kind, w.wait)), [
      (TriggerKind.alarmStopped, TriggerWait.alarm),
      (TriggerKind.unsilenced, TriggerWait.unsilence),
    ]);
    expect(morning.waits.first.at, at);
    expect(status[DayMode.evening]!.waits.single.wait, TriggerWait.charging);
  });

  testWidgets('ayar değişince Android işleri yeniden kurulur', (tester) async {
    final calls = fakeNative(tester);
    await pumpApp(tester);
    final c = ProviderScope.containerOf(tester.element(find.text('Eşik')));
    calls.clear();
    c
        .read(triggerConfigProvider.notifier)
        .update(
          DayMode.morning,
          c
              .read(triggerConfigProvider)[DayMode.morning]!
              .toggle(TriggerKind.leftHomeWifi),
        );
    await tester.pumpAndSettle();
    expect(calls.map((c) => c.method), contains('reschedule'));
  });

  group('Android ile kayıt biçimi', () {
    test('EsikData.kt’nin yazdığı oturum okunur', () {
      // EsikData.completeAll'un ürettiği biçim.
      final s = CheckSession.fromJson({
        'checked': ['e1', 'e2', 'e3'],
        'completedAt': '2026-10-21T00:12:05',
        'source': 'backup',
      });
      expect(s.isComplete, isTrue);
      expect(s.completedAt, DateTime(2026, 10, 21, 0, 12, 5));
      expect(s.viaBackup, isTrue);
      expect(s.checked, {'e1', 'e2', 'e3'});
    });

    test('ilk açılışta varsayılan liste ve ayarlar diske yazılır', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      c.read(checklistProvider);
      c.read(triggerConfigProvider);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString(EsikStore.checklistKey), contains('Ütünün'));
      expect(
        prefs.getString(EsikStore.triggersKey),
        contains('"backupTime":"22:30"'),
      );
    });
  });

  test(
    'yedek bildirimden tamamlanan kontrol geçmişte yedekle görünür',
    () async {
      SharedPreferences.setMockInitialValues({'installed_on': '2026-10-01'});
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime(2026, 10, 20, 22, 40);
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(c.dispose);
      c
          .read(todayProgressProvider.notifier)
          .completeAll(DayMode.evening, source: CheckSession.sourceBackup);
      c.read(todayProgressProvider.notifier).completeAll(DayMode.morning);

      now = DateTime(2026, 10, 21, 9, 0);
      c.read(clockTickProvider.notifier).refresh();
      final yesterday = c.read(historyProvider).last;
      expect(yesterday.date, DateTime(2026, 10, 20));
      expect(yesterday.evening, CheckOutcome.viaBackup);
      expect(yesterday.morning, CheckOutcome.done);
    },
  );

  group('kurulum rehberi', () {
    Future<void> openSetup(WidgetTester tester) async {
      await pumpApp(tester);
      GoRouter.of(tester.element(find.text('Eşik'))).push('/kurulum');
      await tester.pumpAndSettle();
    }

    testWidgets('izin adımı Android izin penceresini açar', (tester) async {
      final calls = fakeNative(tester);
      await openSetup(tester);

      await tester.tap(find.text('İzin ver'));
      await tester.pumpAndSettle();

      expect(
        calls.map((c) => c.method),
        contains('requestNotificationPermission'),
      );
      expect(find.text('Adım 2 / 3'), findsOneWidget);
    });

    testWidgets('izin verilmezse uyarır ama ilerler', (tester) async {
      fakeNative(tester, permission: false);
      await openSetup(tester);

      await tester.tap(find.text('İzin ver'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bildirim izni verilmedi'), findsOneWidget);
      expect(find.text('Adım 2 / 3'), findsOneWidget);
    });

    testWidgets('deneme bildirimi gönderilemezse son adımda kalır', (
      tester,
    ) async {
      fakeNative(tester, testSent: false);
      await openSetup(tester);
      await tester.tap(find.text('İzin ver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İzin ver'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deneme bildirimi gönder'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bildirim gönderilemedi'), findsOneWidget);
      expect(find.text('Adım 3 / 3'), findsOneWidget);
    });

    testWidgets('deneme bildirimi gönderilince ana ekrana döner', (
      tester,
    ) async {
      final calls = fakeNative(tester);
      await openSetup(tester);
      for (final label in ['İzin ver', 'İzin ver', 'Deneme bildirimi gönder']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      expect(
        calls.map((c) => c.method),
        containsAllInOrder([
          'requestNotificationPermission',
          'openBatterySettings',
          'showTestNotification',
        ]),
      );
      expect(find.text('Şarja takınca'), findsOneWidget);
    });
  });

  group('NFC etiketi', () {
    Future<void> openNfcSetup(WidgetTester tester) async {
      await pumpApp(tester);
      final element = tester.element(find.text('Eşik'));
      final c = ProviderScope.containerOf(element);
      c
          .read(triggerConfigProvider.notifier)
          .update(
            DayMode.morning,
            c
                .read(triggerConfigProvider)[DayMode.morning]!
                .copyWith(kinds: [TriggerKind.nfcTag]),
          );
      GoRouter.of(element).push('/kurulum?mod=sabah');
      await tester.pumpAndSettle();
      for (final label in ['İzin ver', 'İzin ver']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      expect(find.text('Etiketi hazırla'), findsWidgets);
    }

    testWidgets('etiket yazılınca son adıma geçer', (tester) async {
      final calls = fakeNative(tester);
      await openNfcSetup(tester);

      await tester.tap(find.text('Etiketi yaz'));
      await tester.pumpAndSettle();

      expect(calls.map((c) => c.method), contains('writeNfcTag'));
      expect(find.textContaining('Etiket hazır'), findsOneWidget);
      expect(find.text('Adım 4 / 4'), findsOneWidget);

      await tester.tap(find.text('Bitir'));
      await tester.pumpAndSettle();
      expect(
        calls.map((c) => c.method),
        isNot(contains('showTestNotification')),
      );
    });

    testWidgets('NFC kapalıysa uyarır ve adımda kalır', (tester) async {
      fakeNative(tester, nfc: 'disabled');
      await openNfcSetup(tester);

      await tester.tap(find.text('Etiketi yaz'));
      await tester.pumpAndSettle();

      expect(find.textContaining('NFC kapalı'), findsOneWidget);
      expect(find.text('Adım 3 / 4'), findsOneWidget);
    });
  });

  group('kurulum durumu', () {
    Map<String, Object?> healthy({bool battery = true}) => {
      'notificationPermission': true,
      'notificationsEnabled': true,
      'battery': battery,
      'nfc': 'on',
      'nfcTagWritten': false,
      'nextAlarm': DateTime(2026, 10, 21, 7, 30).millisecondsSinceEpoch,
      'alarmVolume': 5,
    };

    test('eksikler tetikleyiciye göre hesaplanır', () {
      final h = SetupHealth.parse({...healthy(), 'nextAlarm': null})!;
      expect(setupIssues(h, [TriggerKind.charging]), isEmpty);
      expect(setupIssues(h, [TriggerKind.alarmStopped]), [SetupIssue.noAlarm]);
      expect(setupIssues(h, [TriggerKind.nfcTag]), [SetupIssue.nfcTag]);
      expect(setupIssues(h, [TriggerKind.alarmStopped, TriggerKind.nfcTag]), [
        SetupIssue.noAlarm,
        SetupIssue.nfcTag,
      ]);
      final off = SetupHealth.parse({
        ...healthy(battery: false),
        'notificationsEnabled': false,
        'nfc': 'off',
      })!;
      expect(setupIssues(off, [TriggerKind.nfcTag]), [
        SetupIssue.notifications,
        SetupIssue.battery,
        SetupIssue.nfcOff,
        SetupIssue.nfcTag,
      ]);
    });

    testWidgets('Bugün ekranı eksik pil ayarını gösterir', (tester) async {
      fakeNative(tester, health: () => healthy(battery: false));
      await pumpApp(tester);
      expect(find.text('Pil kısıtlaması açık'), findsOneWidget);
    });

    testWidgets(
      'rehber ilk eksik adımdan başlar, ayardan dönünce kendisi ilerler',
      (tester) async {
        var battery = false;
        final calls = fakeNative(
          tester,
          health: () => healthy(battery: battery),
        );
        await pumpApp(tester);
        GoRouter.of(tester.element(find.text('Eşik'))).push('/kurulum');
        await tester.pumpAndSettle();

        // Bildirimler zaten açık: rehber pil adımında açılır.
        expect(find.text('Adım 2 / 3'), findsOneWidget);
        await tester.tap(find.text('İzin ver'));
        await tester.pumpAndSettle();
        expect(calls.map((c) => c.method), contains('openBatterySettings'));
        // Ayar değişmeden dönüldü: adımda kalır, atlanabilir.
        expect(find.text('Adım 2 / 3'), findsOneWidget);
        expect(find.text('Atla'), findsOneWidget);

        // Kullanıcı Kısıtlamasız'ı seçip uygulamaya döndü.
        battery = true;
        final c = ProviderScope.containerOf(tester.element(find.text('Atla')));
        c.read(clockTickProvider.notifier).refresh();
        await tester.pumpAndSettle();
        expect(find.text('Adım 3 / 3'), findsOneWidget);
      },
    );
  });

  testWidgets('henüz desteklenmeyen tetikleyici seçilemez', (tester) async {
    await pumpApp(tester);
    final element = tester.element(find.text('Eşik'));
    GoRouter.of(element).go('/ayarlar');
    await tester.pumpAndSettle();

    expect(find.text('Yakında'), findsWidgets);
    await tester.tap(find.text('Uyku modu'));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(element);
    expect(c.read(triggerConfigProvider)[DayMode.evening]!.kinds, [
      TriggerKind.charging,
    ]);
  });

  testWidgets('bildirimden açılış yönlendirmesi hızlı kontrolü açar', (
    tester,
  ) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      _channel,
      (call) async => call.method == 'takeLaunchRoute'
          ? '/kontrol?mod=sabah&kaynak=yedek'
          : null,
    );
    addTearDown(() => messenger.setMockMethodCallHandler(_channel, null));

    await pumpApp(tester, settleAnimations: false);
    expect(find.text('Sabah kontrolü'), findsOneWidget);
  });
}
