import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  testWidgets('telefon İngilizceyse uygulama İngilizce açılır', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('en', 'US'));
    expect(find.text('Tonight’s threshold'), findsOneWidget);
    expect(find.text('Check now'), findsOneWidget);
    expect(find.text('When charging'), findsOneWidget);
  });

  testWidgets('telefon İspanyolcaysa uygulama İspanyolca açılır', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocale: const Locale('es', 'ES'));
    expect(find.text('Tu umbral de esta noche'), findsOneWidget);
    expect(find.text('Comprobar ahora'), findsOneWidget);
  });

  testWidgets('desteklenmeyen dilde İngilizceye düşer', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('de', 'DE'));
    expect(find.text('Check now'), findsOneWidget);
  });

  testWidgets('ilk açılıştaki örnek liste telefonun dilinde', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('en'));
    await tester.tap(find.bySemanticsLabel('List'));
    await tester.pumpAndSettle();
    expect(find.text('Did I unplug the iron?'), findsOneWidget);
  });

  testWidgets('Ayarlar’dan dil seçilince hemen değişir ve kalır', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Español'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // Alttaki cam sekme çubuğunun üstüne çıkar.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    // Kart başlığı da İspanyolca oldu (sayfanın üstü kaydırılmış durumda).
    expect(find.text('Idioma'), findsOneWidget);

    final c = ProviderScope.containerOf(tester.element(find.text('Español')));
    expect(c.read(languageProvider), AppLanguage.es);
    expect(c.read(sharedPreferencesProvider).getString('language'), 'es');
  });

  test('üç dilde de aynı anahtarlar var', () {
    final tr = lookupAppLocalizations(const Locale('tr'));
    final en = lookupAppLocalizations(const Locale('en'));
    final es = lookupAppLocalizations(const Locale('es'));
    expect(en.todayContinue(1), 'Continue · 1 item left');
    expect(en.todayContinue(3), 'Continue · 3 items left');
    expect(es.todayCardBody('Al cargar', 2), contains('2 elementos'));
    expect(
      tr.todayCardBody('Telefonu şarja taktığında', 3),
      'Telefonu şarja taktığında 3 maddelik kontrolün önüne gelir.',
    );
  });
}
