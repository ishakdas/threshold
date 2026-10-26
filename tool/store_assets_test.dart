// Play Store görsellerini gerçek ekranlardan üretir: telefon ekran görüntüleri
// (1080×1920) ve öne çıkan grafik (1024×500). Örnek veriyle, Inter yazı
// tipiyle çizer.
//
//   flutter test tool/store_assets_test.dart --update-goldens
//
// Çıktı: docs/play/gorseller/
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/app.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/store.dart';
import 'package:threshold/theme/esik_palette.dart';
import 'package:threshold/theme/esik_theme.dart';
import 'package:threshold/ui/atmosphere.dart';
import 'package:threshold/ui/esik_logo.dart';

const _out = '../docs/play/gorseller';
const _channel = MethodChannel('esik/native');

Future<void> _loadFonts() async {
  final loader = FontLoader('Inter');
  for (final w in ['Light', 'Regular', 'Medium', 'SemiBold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Son iki haftanın örnek kaydı: çoğu gün tamam, birkaçı yedekle, biri atlanmış.
Map<String, Object?> _sampleLog(DateTime today) {
  final log = <String, Object?>{};
  for (var i = 1; i <= 14; i++) {
    final day = DateTime(today.year, today.month, today.day - i);
    Map<String, Object?> done(String mode, int h, int m, String source) => {
      'checked': mode == 'evening' ? ['e1', 'e2', 'e3'] : ['m1', 'm2', 'm3'],
      'completedAt': DateTime(
        day.year,
        day.month,
        day.day + (mode == 'evening' && h < 4 ? 1 : 0),
        h,
        m,
      ).toIso8601String().substring(0, 19),
      'source': source,
    };
    log[dayKey(day)] = {
      if (i != 4 && i != 11)
        'evening': done(
          'evening',
          i == 6 ? 22 : 23,
          (i * 7) % 60,
          i == 6 ? 'backup' : 'notification',
        ),
      if (i != 9)
        'morning': done(
          'morning',
          7,
          (i * 11) % 60,
          i == 2 ? 'backup' : 'notification',
        ),
    };
  }
  return log;
}

Future<void> _boot(WidgetTester t, DateTime now) async {
  await _loadFonts();
  t.view.physicalSize = const Size(1080, 1920);
  t.view.devicePixelRatio = 2.75;
  t.view.padding = const FakeViewPadding(top: 24 * 2.75, bottom: 16 * 2.75);
  addTearDown(t.view.reset);

  // Kurulum tamam: uyarı kartı görünmesin.
  t.binding.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
    call,
  ) async {
    if (call.method == 'setupHealth') {
      return {
        'notificationPermission': true,
        'notificationsEnabled': true,
        'battery': true,
        'nfc': 'on',
        'nfcTagWritten': true,
        'nextAlarm': DateTime(2026, 10, 21, 7, 30).millisecondsSinceEpoch,
        'alarmVolume': 5,
      };
    }
    return null;
  });

  final evening = defaultTriggerConfigs[DayMode.evening]!.toggle(
    TriggerKind.silenced,
  );
  final morning = defaultTriggerConfigs[DayMode.morning]!.copyWith(
    days: {1, 2, 3, 4, 5},
  );
  // tool/ test klasörü sayılmıyor; bu dosya yine de bir test.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    'onboarding_seen': true,
    'installed_on': '2026-09-01',
    'plus_owned': true,
    EsikStore.logKey: jsonEncode(_sampleLog(thresholdDay(now))),
    EsikStore.triggersKey: jsonEncode({
      'evening': evening.toJson(),
      'morning': morning.toJson(),
    }),
  });
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => now),
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceLocaleProvider.overrideWithValue(const Locale('tr')),
      ],
      child: const EsikApp(),
    ),
  );
  await _settle(t);
}

/// Kontrol ekranındaki kürenin sonsuz animasyonu yüzünden pumpAndSettle bitmez.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 14; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

GoRouter _router(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(Scaffold).first));

Future<void> _shot(WidgetTester t, String name) async {
  await _settle(t);
  await expectLater(find.byType(EsikApp), matchesGoldenFile('$_out/$name.png'));
}

void main() {
  final evening = DateTime(2026, 10, 20, 22, 41);
  final morning = DateTime(2026, 10, 21, 7, 24);

  testWidgets('telefon-1: akşam', (t) async {
    await _boot(t, evening);
    await _shot(t, 'telefon-1');
  });

  testWidgets('telefon-2: hızlı kontrol', (t) async {
    await _boot(t, evening);
    _router(t).push('/kontrol');
    await _settle(t);
    await t.tap(find.text('Ütünün fişini çektim mi?'));
    await t.tap(find.text('Kapıyı kilitledim mi?'));
    await _shot(t, 'telefon-2');
  });

  testWidgets('telefon-3: sabah', (t) async {
    await _boot(t, morning);
    await _shot(t, 'telefon-3');
  });

  testWidgets('telefon-4: tetikleyiciler', (t) async {
    await _boot(t, evening);
    _router(t).go('/ayarlar');
    await _settle(t);
    await t.drag(find.byType(ListView).first, const Offset(0, -330));
    await _shot(t, 'telefon-4');
  });

  testWidgets('telefon-5: geçmiş', (t) async {
    await _boot(t, morning);
    _router(t).go('/gecmis');
    await _shot(t, 'telefon-5');
  });

  testWidgets('telefon-6: liste', (t) async {
    await _boot(t, evening);
    _router(t).go('/liste');
    await _shot(t, 'telefon-6');
  });

  testWidgets('öne çıkan grafik', (t) async {
    await _loadFonts();
    t.view.physicalSize = const Size(1024, 500);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: esikTheme(DayMode.evening),
        home: const _FeatureGraphic(),
      ),
    );
    await t.pump();
    await expectLater(
      find.byType(_FeatureGraphic),
      matchesGoldenFile('$_out/one-cikan-1024x500.png'),
    );
  });
}

/// 1024×500: logo, ad ve tek cümle.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Atmosphere(
        glowTop: -420,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 96),
          child: Row(
            children: [
              EsikLogo(size: 240, archColor: p.text),
              const SizedBox(width: 56),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eşik',
                      style: t.headlineMedium?.copyWith(
                        fontSize: 104,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Yatmadan ve evden çıkmadan önce,\ndoğru anda kontrol et.',
                      style: t.bodyLarge?.copyWith(
                        fontSize: 27,
                        color: p.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
