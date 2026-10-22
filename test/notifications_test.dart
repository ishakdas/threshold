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

import 'helpers.dart';

const _channel = MethodChannel('esik/native');

/// Android tarafını taklit eder; yapılan çağrıları kaydeder.
List<MethodCall> fakeNative(
  WidgetTester? tester, {
  bool permission = true,
  bool testSent = true,
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
      await tester.tap(find.text('Pil ayarını aç'));
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
      for (final label in [
        'İzin ver',
        'Pil ayarını aç',
        'Deneme bildirimi gönder',
      ]) {
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
