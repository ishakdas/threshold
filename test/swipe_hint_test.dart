import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  Future<void> openList(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Liste'));
    // Bekleme bitip madde sola kaydığı an.
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('liste açılınca ilk madde kayıp "Sil"i gösterir, geri döner', (
    tester,
  ) async {
    await pumpApp(tester);
    await openList(tester);
    expect(find.text('Sil'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Sil'), findsNothing);
  });

  testWidgets('üç açılıştan sonra gösterilmez', (tester) async {
    await pumpApp(tester, prefs: {'swipe_hint': '3'});
    await openList(tester);
    expect(find.text('Sil'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('swipe_hint'), '3');
    await tester.pumpAndSettle();
  });
}
