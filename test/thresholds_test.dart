import 'dart:convert';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/store.dart';
import 'package:threshold/data/threshold_templates.dart';

void main() {
  final everyDay = defaultTriggerConfigs[DayMode.morning]!;
  final weekend = everyDay.copyWith(
    kinds: [TriggerKind.unplugged],
    windowStart: const TimeOfDay(hour: 9, minute: 0),
  );

  test('yeni eşik günlerini diğerinden alır; o günün eşiği seçilir', () {
    final list = [everyDay].withThreshold(weekend, {6, 7});
    expect(list.map((c) => c.days), [
      {1, 2, 3, 4, 5},
      {6, 7},
    ]);
    expect(list.on(DateTime(2026, 11, 7))!.kinds, [TriggerKind.unplugged]);
    expect(list.on(DateTime(2026, 11, 2))!.kinds, [TriggerKind.alarmStopped]);
    expect(list.allKinds, [TriggerKind.alarmStopped, TriggerKind.unplugged]);
  });

  test('başka eşikteki güne dokununca taşınır; son gün alınamaz', () {
    final list = [everyDay].withThreshold(weekend, {6, 7});
    final moved = list.toggleDay(1, 5);
    expect(moved[0].days, {1, 2, 3, 4});
    expect(moved[1].days, {5, 6, 7});
    final single = [everyDay].withThreshold(weekend, {7});
    expect(identical(single.toggleDay(0, 7), single), isTrue);
    expect(identical(single.toggleDay(1, 7), single), isTrue);
    // Kendi gününü kapatmak izinli gün yapar.
    expect(list.toggleDay(1, 6)[1].days, {7});
    expect(list.toggleDay(1, 6).on(DateTime(2026, 11, 7)), isNull);
  });

  test('eşik silinince günleri ilk eşiğe geçer; son eşik silinmez', () {
    final list = [everyDay].withThreshold(weekend, {6, 7});
    expect(list.without(1).single.days, allWeekdays);
    final one = list.without(0);
    expect(identical(one.without(0), one), isTrue);
  });

  test('Plus yoksa yalnızca ilk eşik, her gün', () {
    final list = [everyDay].withThreshold(weekend, {6, 7});
    final free = list.effective(plus: false);
    expect(free, hasLength(1));
    expect(free.single.days, allWeekdays);
  });

  test('eski tek eşikli kayıt okunur ve yeni biçimde yazılır', () async {
    SharedPreferences.setMockInitialValues({
      EsikStore.triggersKey: jsonEncode({
        'evening': defaultTriggerConfigs[DayMode.evening]!
            .copyWith(days: {1, 2, 3})
            .toJson(),
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    final t = c.read(thresholdsProvider);
    expect(t[DayMode.evening]!.single.days, {1, 2, 3});
    expect(t[DayMode.morning]!.single.kinds, [TriggerKind.alarmStopped]);
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString(EsikStore.thresholdsKey), contains('"evening":['));
  });

  test('hazır düzenler: günler çakışmaz, çok eşikli olanlar Plus', () {
    for (final template in thresholdTemplates) {
      for (final list in template.thresholds.values) {
        final days = [for (final c in list) ...c.days];
        expect(days.toSet().length, days.length, reason: template.id);
      }
    }
    expect(
      thresholdTemplates.firstWhere((t) => t.id == 'everyday').plusOnly,
      isFalse,
    );
    expect(
      thresholdTemplates.firstWhere((t) => t.id == 'workweek').plusOnly,
      isTrue,
    );
  });
}
