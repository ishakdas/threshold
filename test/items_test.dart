import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/day_mode.dart';
import 'package:threshold/data/app_state.dart';
import 'package:threshold/data/models.dart';
import 'package:threshold/data/reminders.dart';
import 'package:threshold/data/templates.dart';
import 'package:threshold/data/weather.dart';
import 'package:threshold/ui/esik_icons.dart';

void main() {
  const rainy = WeatherDay(rainChance: 80, minTemp: 3, maxTemp: 9);
  const sunny = WeatherDay(rainChance: 5, minTemp: 18, maxTemp: 31);

  test('madde ayarları kaydedilir; eski kayıtta varsayılanlar', () {
    const item = CheckItem(
      id: 'x',
      title: 'Şemsiye',
      icon: EsikIcon.umbrella,
      days: {1, 3},
      weather: WeatherNeed.rain,
      photo: true,
    );
    final back = CheckItem.fromJson(item.toJson());
    expect(back.days, {1, 3});
    expect(back.weather, WeatherNeed.rain);
    expect(back.photo, isTrue);
    final old = CheckItem.fromJson({
      'id': 'y',
      'title': 'Kapı',
      'icon': 'lock',
    });
    expect(old.days, allWeekdays);
    expect(old.weather, WeatherNeed.always);
    expect(old.photo, isFalse);
  });

  test('madde yalnızca kendi günlerinde ve havasında görünür', () {
    const umbrella = CheckItem(
      id: 'u',
      title: 'Şemsiye',
      icon: EsikIcon.umbrella,
      weather: WeatherNeed.rain,
    );
    const badge = CheckItem(
      id: 'b',
      title: 'Kart',
      icon: EsikIcon.bag,
      days: {1, 2, 3, 4, 5},
    );
    final monday = DateTime(2026, 11, 2);
    final saturday = DateTime(2026, 11, 7);
    expect(umbrella.visibleOn(monday, rainy), isTrue);
    expect(umbrella.visibleOn(monday, sunny), isFalse);
    // Hava bilinmiyorsa gösterilir.
    expect(umbrella.visibleOn(monday, null), isTrue);
    expect(badge.visibleOn(monday, null), isTrue);
    expect(badge.visibleOn(saturday, null), isFalse);
    expect(rainy.matches(WeatherNeed.cold), isTrue);
    expect(sunny.matches(WeatherNeed.hot), isTrue);
  });

  test('bugünün listesi: sabah bugünün, akşam yarının havası', () async {
    final today = DateTime(2026, 11, 2); // Pazartesi
    SharedPreferences.setMockInitialValues({
      'checklist.v1':
          '{"evening":[{"id":"e","title":"Mont hazır","icon":"coat","weather":"cold"}],'
          '"morning":[{"id":"m","title":"Şemsiye","icon":"umbrella","weather":"rain"},'
          '{"id":"s","title":"Spor","icon":"bag","days":[2,4]}]}',
      'weather.v1':
          '{"place":{"name":"X","lat":1,"lon":2},"days":{'
          '"2026-11-02":{"rain":10,"min":12,"max":20},'
          '"2026-11-03":{"rain":90,"min":2,"max":8}}}',
    });
    final c = await container(now: today.add(const Duration(hours: 9)));
    final items = c.read(todayItemsProvider);
    expect(items[DayMode.morning]!.map((i) => i.id), isEmpty);
    expect(items[DayMode.evening]!.map((i) => i.id), ['e']);
  });

  test('şablon eklenince aynı adlı madde tekrar eklenmez', () async {
    SharedPreferences.setMockInitialValues({});
    final c = await container();
    final l10n = c.read(l10nProvider);
    final weather = checklistTemplates.firstWhere(
      (t) => t.items.any((i) => i.weather == WeatherNeed.rain),
    );
    final notifier = c.read(checklistProvider.notifier);
    for (var i = 0; i < 2; i++) {
      for (final e in weather.build(l10n).entries) {
        notifier.addAll(e.key, e.value);
      }
    }
    final morning = c.read(checklistProvider)[DayMode.morning]!;
    expect(morning.where((i) => i.weather == WeatherNeed.rain).length, 1);
    expect(morning.every((i) => i.id.isNotEmpty), isTrue);
  });

  test('tekrar hatırlatma ayarı sınırlanır', () {
    expect(ReminderSettings.fromJson({'max': 9, 'minutes': 7}).max, 5);
    expect(ReminderSettings.fromJson({'max': 9, 'minutes': 7}).minutes, 10);
    expect(ReminderSettings.fromJson(null).max, 5);
  });
}

Future<ProviderContainer> container({DateTime? now}) async {
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(c.dispose);
  return c;
}
