import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/app.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/l10n/app_localizations.dart';

final eveningNow = DateTime(2026, 10, 20, 22, 14);

/// Testler Türkçe metinleri bekler; test ortamının dili ise İngilizce.
final trL10n = lookupAppLocalizations(const Locale('tr'));
final turkishDevice = deviceLocaleProvider.overrideWithValue(
  const Locale('tr'),
);
final morningNow = DateTime(2026, 10, 21, 7, 18);

/// Uygulamayı telefon boyutunda açar. [onboardingSeen] false ise ilk açılıştır.
Future<void> pumpApp(
  WidgetTester tester, {
  DateTime? now,
  bool onboardingSeen = true,
  bool settleAnimations = true,
  Locale deviceLocale = const Locale('tr'),
}) async {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'onboarding_seen': onboardingSeen});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => now ?? eveningNow),
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceLocaleProvider.overrideWithValue(deviceLocale),
      ],
      child: const EsikApp(),
    ),
  );
  // Hızlı kontrol açıksa kürenin sonsuz animasyonu pumpAndSettle'ı bitirmez.
  settleAnimations ? await tester.pumpAndSettle() : await settle(tester);
}

/// Kürenin sonsuz "nefes" animasyonu yüzünden pumpAndSettle bitmez;
/// geçişleri sabit sürelerle ilerletir.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
