import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  Future<void> openCheck(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Kontrol et'));
    await settle(tester);
    expect(find.text('Akşam kontrolü'), findsOneWidget);
  }

  testWidgets('madde tiklenince sayaç artar, tekrar dokununca geri alınır', (
    tester,
  ) async {
    await openCheck(tester);
    expect(find.text('0/3'), findsOneWidget);

    await tester.tap(find.text('Ütünün fişini çektim mi?'));
    await settle(tester);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.text('Ütünün fişini çektim mi?'));
    await settle(tester);
    expect(find.text('0/3'), findsOneWidget);
  });

  testWidgets('tüm maddeler tiklenince kendiliğinden tamamlanır', (
    tester,
  ) async {
    await openCheck(tester);

    for (final title in [
      'Ütünün fişini çektim mi?',
      'Yapılacaklar listemi tikledim mi?',
      'Kapıyı kilitledim mi?',
    ]) {
      await tester.tap(find.text(title));
      await settle(tester);
    }
    await tester.pump(const Duration(milliseconds: 700));
    await settle(tester);

    expect(find.text('Hepsi tamam'), findsOneWidget);
    expect(find.text('İçin rahat. İyi geceler.'), findsOneWidget);
  });

  testWidgets('Hepsi tamam, Geri al ve ana ekrandaki durum', (tester) async {
    await openCheck(tester);

    await tester.tap(find.text('Hepsi tamam'));
    await settle(tester);
    expect(find.text('Akşam kontrolü · 22:14'), findsOneWidget);

    await tester.tap(find.text('Geri al'));
    await settle(tester);
    expect(find.text('0/3'), findsOneWidget);

    await tester.tap(find.text('Hepsi tamam'));
    await settle(tester);
    await tester.tap(find.text('Kapat'));
    await settle(tester);
    expect(find.text('Tamamlandı · 22:14'), findsOneWidget);
  });
}
