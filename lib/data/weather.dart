import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/day_mode.dart';
import 'app_state.dart';
import 'models.dart';
import 'store.dart';

/// Hava durumuna göre çıkan maddeler (şemsiye, mont…) için tahmin.
///
/// Konum izni istenmez: kullanıcı şehrini kendisi seçer. Tahmin Open-Meteo'dan
/// (anahtar ve hesap gerektirmez) yalnızca şehrin koordinatlarıyla alınır ve
/// telefonda saklanır; Android ve iOS bildirimleri de bu kaydı okur
/// (EsikData.kt, EsikCore.swift).
class WeatherPlace {
  const WeatherPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() => {
    'name': name,
    'lat': latitude,
    'lon': longitude,
  };

  static WeatherPlace? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'], lat = json['lat'], lon = json['lon'];
    if (name is! String || lat is! num || lon is! num) return null;
    return WeatherPlace(
      name: name,
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
    );
  }
}

class WeatherState {
  const WeatherState({this.place, this.days = const {}, this.fetchedAt});

  final WeatherPlace? place;

  /// Gün anahtarı (yyyy-MM-dd) → tahmin.
  final Map<String, WeatherDay> days;
  final DateTime? fetchedAt;

  WeatherDay? on(DateTime day) => days[dayKey(day)];

  Map<String, Object?> toJson() => {
    'place': place?.toJson(),
    'days': {for (final e in days.entries) e.key: e.value.toJson()},
    if (fetchedAt != null) 'fetchedAt': fetchedAt!.toIso8601String(),
  };

  factory WeatherState.fromJson(Map<String, Object?>? json) {
    if (json == null) return const WeatherState();
    return WeatherState(
      place: WeatherPlace.fromJson(json['place']),
      days: {
        if (json['days'] case final Map m)
          for (final e in m.entries) '${e.key}': ?WeatherDay.fromJson(e.value),
      },
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? ''),
    );
  }
}

class WeatherNotifier extends Notifier<WeatherState> {
  /// Tahmin bundan eskiyse yenilenir.
  static const maxAge = Duration(hours: 3);

  @override
  WeatherState build() => WeatherState.fromJson(
    ref.watch(storeProvider).readJson(EsikStore.weatherKey),
  );

  void _save(WeatherState next) {
    state = next;
    unawaited(
      ref.read(storeProvider).writeJson(EsikStore.weatherKey, next.toJson()),
    );
  }

  Future<void> setPlace(WeatherPlace? place) async {
    _save(WeatherState(place: place));
    if (place != null) await refresh(force: true);
  }

  /// Şehir seçiliyse ve tahmin eskiyse yeniler. İnternet yoksa sessizce geçer.
  Future<void> refresh({bool force = false}) async {
    final place = state.place;
    if (place == null) return;
    final now = ref.read(clockProvider)();
    final last = state.fetchedAt;
    if (!force && last != null && now.difference(last) < maxAge) return;
    try {
      final json = await _getJson(
        Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': '${place.latitude}',
          'longitude': '${place.longitude}',
          'daily': 'precipitation_probability_max,temperature_2m_min,temperature_2m_max',
          'timezone': 'auto',
          'forecast_days': '3',
        }),
      );
      final daily = json['daily'] as Map<String, Object?>;
      final dates = (daily['time'] as List).cast<String>();
      final rain = daily['precipitation_probability_max'] as List;
      final min = daily['temperature_2m_min'] as List;
      final max = daily['temperature_2m_max'] as List;
      final days = <String, WeatherDay>{
        for (var i = 0; i < dates.length; i++)
          if (rain[i] is num && min[i] is num && max[i] is num)
            dates[i]: WeatherDay(
              rainChance: (rain[i] as num).round(),
              minTemp: (min[i] as num).toDouble(),
              maxTemp: (max[i] as num).toDouble(),
            ),
      };
      _save(WeatherState(place: place, days: days, fetchedAt: now));
    } on Object catch (e) {
      debugPrint('Weather.refresh: $e');
    }
  }
}

final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

/// Şehir arama (Open-Meteo Geocoding). İnternet yoksa boş.
Future<List<WeatherPlace>> searchPlaces(String query, String language) async {
  if (query.trim().length < 2) return const [];
  try {
    final json = await _getJson(
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query.trim(),
        'count': '6',
        'language': language,
        'format': 'json',
      }),
    );
    return [
      for (final r in (json['results'] as List? ?? const []).whereType<Map>())
        if (r['name'] is String &&
            r['latitude'] is num &&
            r['longitude'] is num)
          WeatherPlace(
            name: [
              r['name'],
              if (r['admin1'] is String && r['admin1'] != r['name'])
                r['admin1'],
              if (r['country'] is String) r['country'],
            ].join(', '),
            latitude: (r['latitude'] as num).toDouble(),
            longitude: (r['longitude'] as num).toDouble(),
          ),
    ];
  } on Object catch (e) {
    debugPrint('Weather.search: $e');
    return const [];
  }
}

Future<Map<String, Object?>> _getJson(Uri uri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 10));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    return jsonDecode(body) as Map<String, Object?>;
  } finally {
    client.close();
  }
}

/// Maddenin hangi günün havasına bakacağı: sabah o günün, akşam ertesi günün
/// (akşam yarının hazırlığı yapılır).
DateTime weatherDayFor(DayMode mode, DateTime thresholdDay) =>
    mode == DayMode.morning
    ? thresholdDay
    : DateTime(thresholdDay.year, thresholdDay.month, thresholdDay.day + 1);

/// Bugünün listeleri: maddenin günleri ve hava koşulu süzülmüş hâli. Kontrol
/// ekranı, bugün ekranı ve "Hepsi tamam" bunu kullanır.
final todayItemsProvider = Provider<Map<DayMode, List<CheckItem>>>((ref) {
  final today = ref.watch(todayProvider);
  final lists = ref.watch(checklistProvider);
  final weather = ref.watch(weatherProvider);
  return {
    for (final mode in DayMode.values)
      mode: [
        for (final item in lists[mode]!)
          if (item.visibleOn(today, weather.on(weatherDayFor(mode, today))))
            item,
      ],
  };
});
