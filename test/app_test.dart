import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold/app.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/theme/esik_palette.dart';

Widget _app(DateTime now) => ProviderScope(
  overrides: [clockProvider.overrideWithValue(() => now)],
  child: const EsikApp(),
);

void main() {
  testWidgets('akşam açılışı: lacivert tema ve akşam eşiği', (tester) async {
    await tester.pumpWidget(_app(DateTime(2026, 10, 20, 22, 14)));
    await tester.pumpAndSettle();

    expect(find.text('Eşik'), findsOneWidget);
    expect(find.text('Şarja takınca'), findsOneWidget);
    expect(find.text('Akşam modu'), findsOneWidget);

    final context = tester.element(find.text('Şarja takınca'));
    expect(Theme.of(context).extension<EsikPalette>(), EsikPalette.evening);
  });

  testWidgets('mod anahtarı sabaha geçirir', (tester) async {
    await tester.pumpWidget(_app(DateTime(2026, 10, 20, 22, 14)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Akşam modu'));
    await tester.pumpAndSettle();

    expect(find.text('Alarmı durdurunca'), findsOneWidget);
    expect(find.text('Sabah modu'), findsOneWidget);
  });

  testWidgets('ana buton hızlı kontrole gider', (tester) async {
    await tester.pumpWidget(_app(DateTime(2026, 10, 21, 7, 18)));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Kontrol et'));
    await tester.pumpAndSettle();

    expect(find.text('Hızlı kontrol'), findsOneWidget);
  });
}
