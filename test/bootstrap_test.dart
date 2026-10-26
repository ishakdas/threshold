import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/bootstrap.dart';

void main() {
  testWidgets('ayarlar yüklenince uygulama açılır', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    await tester.pumpWidget(const EsikBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Eşik'), findsOneWidget);
    expect(find.text('Eşik başlatılamadı'), findsNothing);
  });

  testWidgets('yükleme hata verirse açılışta kalmaz, hatayı gösterir', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      EsikBootstrap(
        loadPreferences: () async => throw PlatformException(
          code: 'channel-error',
          message: 'Kanal kurulamadı',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Eşik başlatılamadı'), findsOneWidget);
    expect(find.textContaining('Kanal kurulamadı'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('yükleme hiç bitmezse zaman aşımında hatayı gösterir', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      EsikBootstrap(
        loadPreferences: () => Completer<SharedPreferences>().future,
        timeout: const Duration(seconds: 1),
      ),
    );
    expect(find.text('Eşik başlatılamadı'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('zamanında yüklenemedi'), findsOneWidget);
  });

  testWidgets('Tekrar dene başarılı olursa uygulama açılır', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    var calls = 0;
    await tester.pumpWidget(
      EsikBootstrap(
        loadPreferences: () {
          calls++;
          if (calls == 1) throw StateError('ilk deneme');
          return SharedPreferences.getInstance();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eşik başlatılamadı'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(find.text('Eşik'), findsOneWidget);
  });
}
