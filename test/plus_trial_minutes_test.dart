// Test APK'sının 5 dakikalık denemesi. Yalnızca şöyle çalıştırılınca sınar:
//   flutter test --dart-define=ESIK_TRIAL_MINUTES=5 test/plus_trial_minutes_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/plus.dart';

import 'helpers.dart';

void main() {
  final start = DateTime(2026, 10, 26, 14, 32);

  Future<PlusState> plusAt(DateTime now) async {
    SharedPreferences.setMockInitialValues({
      'installed_on': '2026-10-26',
      'trial_start': start.millisecondsSinceEpoch,
    });
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        turkishDevice,
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    return c.read(plusProvider);
  }

  test(
    '5 dakika dolunca deneme biter',
    () async {
      final early = await plusAt(start.add(const Duration(minutes: 2)));
      expect(early.active, isTrue);
      expect(early.testStart, start);
      expect(early.testMinutesLeft, 3);

      final late = await plusAt(
        start.add(const Duration(minutes: 5, seconds: 1)),
      );
      expect(late.active, isFalse);
      expect(late.testMinutesLeft, 0);
    },
    skip: trialMinutesOverride != 5
        ? 'yalnızca --dart-define=ESIK_TRIAL_MINUTES=5 ile'
        : false,
  );
}
