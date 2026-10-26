// Play Store görsellerinin ham ekranlarını üretir: gerçek uygulama ekranları
// (üç dilde, örnek veriyle, Plus açık) ve kilit ekranındaki bildirimin
// canlandırması. tool/store_marketing.py bunları çerçeveleyip başlık ekler.
//
//   flutter test tool/store_assets_test.dart --update-goldens
//   python3 tool/store_marketing.py
//
// Ham çıktı: build/store_raw/<dil>/ (depoya girmez).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:threshold/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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

const _out = '../build/store_raw';
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

Future<void> _boot(WidgetTester t, DateTime now, String lang) async {
  await _loadFonts();
  _phone(t);

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
        deviceLocaleProvider.overrideWithValue(Locale(lang)),
      ],
      child: const EsikApp(),
    ),
  );
  await _settle(t);
}

/// 393×852 mantıksal piksel, 3× (1179×2556); üstte durum çubuğu payı.
void _phone(WidgetTester t) {
  t.view.physicalSize = const Size(393 * 3, 852 * 3);
  t.view.devicePixelRatio = 3;
  t.view.padding = const FakeViewPadding(top: 50 * 3, bottom: 20 * 3);
  addTearDown(t.view.reset);
}

/// Kontrol ekranındaki kürenin sonsuz animasyonu yüzünden pumpAndSettle bitmez.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 14; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

GoRouter _router(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(Scaffold).first));

Future<void> _shot(WidgetTester t, Finder f, String path) async {
  await _settle(t);
  await expectLater(f, matchesGoldenFile('$_out/$path.png'));
}

void main() {
  final evening = DateTime(2026, 10, 20, 22, 41);
  final morning = DateTime(2026, 10, 21, 7, 24);
  final app = find.byType(EsikApp);

  for (final lang in ['tr', 'en', 'es']) {
    final l10n = lookupAppLocalizations(Locale(lang));

    testWidgets('$lang: kilit ekranı bildirimi', (t) async {
      await _loadFonts();
      _phone(t);
      await t.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: esikTheme(DayMode.evening),
          locale: Locale(lang),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const _LockScreen(),
        ),
      );
      await t.pump();
      await _shot(t, find.byType(_LockScreen), '$lang/1-bildirim');
    });

    testWidgets('$lang: akşam', (t) async {
      await _boot(t, evening, lang);
      await _shot(t, app, '$lang/2-aksam');
    });

    testWidgets('$lang: hızlı kontrol', (t) async {
      await _boot(t, evening, lang);
      _router(t).push('/kontrol');
      await _settle(t);
      await t.tap(find.text(l10n.defaultEveningIron));
      await t.tap(find.text(l10n.defaultEveningLock));
      await _shot(t, app, '$lang/3-kontrol');
    });

    testWidgets('$lang: tetikleyiciler', (t) async {
      await _boot(t, evening, lang);
      _router(t).go('/ayarlar');
      await _settle(t);
      await t.drag(find.byType(ListView).first, const Offset(0, -330));
      await _shot(t, app, '$lang/4-tetikleyiciler');
    });

    testWidgets('$lang: sabah', (t) async {
      await _boot(t, morning, lang);
      await _shot(t, app, '$lang/5-sabah');
    });

    testWidgets('$lang: geçmiş', (t) async {
      await _boot(t, morning, lang);
      _router(t).go('/gecmis');
      await _shot(t, app, '$lang/6-gecmis');
    });
  }
}

/// Kilit ekranında Eşik bildirimi: Android'in gösterdiğinin sadeleştirilmiş
/// canlandırması (metinler EsikNotifications.kt ile aynı anlamda).
class _LockScreen extends StatelessWidget {
  const _LockScreen();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.MMMMEEEEd(l10n.localeName)
        .format(DateTime(2026, 10, 20));
    TextStyle s(double size, {FontWeight w = FontWeight.w400, Color? c}) =>
        TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: w,
          color: c ?? p.text,
          height: 1.25,
        );
    return Scaffold(
      body: Atmosphere(
        glowTop: -120,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(date, style: s(18, c: p.textMuted)),
                Text('22:47', style: s(96, w: FontWeight.w300)),
                const SizedBox(height: 70),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: p.accentGradient,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const EsikLogo(
                              size: 15,
                              archColor: Colors.white,
                              lightColor: Color(0xFFFFF1D6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Eşik · ${l10n.now}',
                            style: s(13, c: p.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.eveningThreshold,
                        style: s(17, w: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.notifyPreview, style: s(15)),
                      const SizedBox(height: 8),
                      for (final item in [
                        l10n.defaultEveningIron,
                        l10n.defaultEveningTodo,
                        l10n.defaultEveningLock,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('•  $item', style: s(14, c: p.textMuted)),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          for (final a in [l10n.allDone, l10n.oneByOne])
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 26, 12),
                              child: Text(
                                a,
                                style: s(15, w: FontWeight.w600, c: p.accent),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
