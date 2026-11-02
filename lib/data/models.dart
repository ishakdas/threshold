import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' show TimeOfDay;

import '../core/day_mode.dart';
import '../ui/esik_icons.dart';

/// iOS'ta tetikleyiciler uygulamanın kendisinde değil, Kestirmeler
/// otomasyonlarında çalışır (ios/Runner/EsikIntents.swift).
bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

/// Maddenin hangi havada listede çıkacağı. Hava bilinmiyorsa her zaman çıkar.
enum WeatherNeed {
  always,

  /// Yağış olasılığı yüksekse (ör. şemsiye).
  rain,

  /// Hava soğuksa (ör. mont, eldiven).
  cold,

  /// Hava sıcaksa (ör. su, güneş kremi).
  hot,
}

/// Bir günün hava tahmini (Open-Meteo). Koşullar [WeatherNeed] için.
class WeatherDay {
  const WeatherDay({
    required this.rainChance,
    required this.minTemp,
    required this.maxTemp,
  });

  /// Gün içindeki en yüksek yağış olasılığı (%).
  final int rainChance;
  final double minTemp;
  final double maxTemp;

  static const rainAt = 50;
  static const coldAt = 5.0;
  static const hotAt = 28.0;

  bool matches(WeatherNeed need) => switch (need) {
    WeatherNeed.always => true,
    WeatherNeed.rain => rainChance >= rainAt,
    WeatherNeed.cold => minTemp <= coldAt,
    WeatherNeed.hot => maxTemp >= hotAt,
  };

  Map<String, Object?> toJson() => {
    'rain': rainChance,
    'min': minTemp,
    'max': maxTemp,
  };

  static WeatherDay? fromJson(Object? json) {
    if (json is! Map) return null;
    final rain = json['rain'], min = json['min'], max = json['max'];
    if (rain is! num || min is! num || max is! num) return null;
    return WeatherDay(
      rainChance: rain.round(),
      minTemp: min.toDouble(),
      maxTemp: max.toDouble(),
    );
  }
}

/// Kontrol listesindeki tek bir madde ("Ütünün fişini çektim mi?").
class CheckItem {
  const CheckItem({
    required this.id,
    required this.title,
    required this.icon,
    this.days = allWeekdays,
    this.weather = WeatherNeed.always,
    this.photo = false,
  });

  final String id;
  final String title;
  final EsikIcon icon;

  /// Listede çıktığı günler (eşik günü); 1 = Pazartesi … 7 = Pazar.
  final Set<int> days;

  /// Yalnızca bu havada çıkar (ör. şemsiye yağmurda).
  final WeatherNeed weather;

  /// İşaretlerken fotoğraf çekilir ("Kilitledim mi?" güvencesi).
  final bool photo;

  /// [day] gününün listesinde var mı. [forecast] bilinmiyorsa hava koşulu
  /// sayılmaz (madde gösterilir).
  bool visibleOn(DateTime day, WeatherDay? forecast) =>
      days.contains(day.weekday) &&
      (forecast == null || forecast.matches(weather));

  CheckItem copyWith({
    String? title,
    EsikIcon? icon,
    Set<int>? days,
    WeatherNeed? weather,
    bool? photo,
  }) => CheckItem(
    id: id,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    days: days ?? this.days,
    weather: weather ?? this.weather,
    photo: photo ?? this.photo,
  );

  /// Android ve iOS tarafı (EsikData.kt, EsikCore.swift) aynı alanları okur.
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'icon': icon.name,
    if (days.length < 7) 'days': days.toList()..sort(),
    if (weather != WeatherNeed.always) 'weather': weather.name,
    if (photo) 'photo': true,
  };

  factory CheckItem.fromJson(Map<String, Object?> json) {
    final days = {
      for (final d in json['days'] as List? ?? const [])
        if (d is int && d >= 1 && d <= 7) d,
    };
    return CheckItem(
      id: json['id']! as String,
      title: json['title']! as String,
      icon: _byName(EsikIcon.values, json['icon'], EsikIcon.checklist),
      days: days.isEmpty ? allWeekdays : days,
      weather: _byName(WeatherNeed.values, json['weather'], WeatherNeed.always),
      photo: json['photo'] == true,
    );
  }
}

/// Kayıtlı bir enum adını çözer; bilinmeyen ya da eksik ad için [fallback].
T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

String _timeToJson(TimeOfDay t) => formatTime(t);

TimeOfDay _timeFromJson(Object? v, TimeOfDay fallback) {
  if (v is! String) return fallback;
  final parts = v.split(':');
  if (parts.length != 2) return fallback;
  final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return fallback;
  }
  return TimeOfDay(hour: h, minute: m);
}

/// Bir eşiği başlatan davranış. Her tetikleyici yalnızca bir moda aittir.
enum TriggerKind {
  charging(DayMode.evening, EsikIcon.plug),
  silenced(DayMode.evening, EsikIcon.bellOff),

  /// Wi‑Fi ve mobil veri ikisi de kapalı (uçak modu dahil).
  offline(DayMode.evening, EsikIcon.wifiOff),
  appClosed(DayMode.evening, EsikIcon.app),
  sleepMode(DayMode.evening, EsikIcon.bed),
  airplaneMode(DayMode.evening, EsikIcon.airplane),
  alarmStopped(DayMode.morning, EsikIcon.alarm),
  unsilenced(DayMode.morning, EsikIcon.bellRing),
  unplugged(DayMode.morning, EsikIcon.plug),
  leftHomeWifi(DayMode.morning, EsikIcon.wifi),
  nfcTag(DayMode.morning, EsikIcon.nfc);

  const TriggerKind(this.mode, this.icon);

  // Adları ve cümle içindeki hâlleri: lib/l10n/texts.dart.
  final DayMode mode;
  final EsikIcon icon;

  /// Bu platformda çalışan tetikleyiciler. Android'de uygulama kendisi
  /// yakalar (android/.../Triggers.kt); iOS'ta yalnızca Kestirmeler'in
  /// otomasyon sunduğu anlar (sessiz mod düğmesi için otomasyon yok).
  /// Diğerleri listede gösterilmez; eski ayarlarda kalmışsa yedek saat devrede.
  bool get supported => isIOS ? _supportedIOS : _supportedAndroid;

  bool get _supportedIOS => switch (this) {
    charging ||
    offline ||
    sleepMode ||
    alarmStopped ||
    unplugged ||
    leftHomeWifi ||
    nfcTag => true,
    _ => false,
  };

  bool get _supportedAndroid => switch (this) {
    charging ||
    silenced ||
    offline ||
    alarmStopped ||
    unsilenced ||
    leftHomeWifi ||
    unplugged ||
    nfcTag => true,
    appClosed || sleepMode || airplaneMode => false,
  };

  /// Eşik Plus olmadan da kullanılabilir. Diğer çalışan tetikleyiciler
  /// (sessiz mod, Wi‑Fi, NFC) Plus'a özel. Android tarafı (EsikData.FREE_KINDS) aynı listeyi
  /// kullanır.
  bool get free => switch (this) {
    charging || alarmStopped => true,
    _ => false,
  };

  bool get plusOnly => supported && !free;

  /// Seçilebilen (çalışan) tetikleyiciler.
  static List<TriggerKind> forMode(DayMode mode) =>
      values.where((k) => k.mode == mode && k.supported).toList();
}

/// Telefon sessizdeyken (sessiz, titreşim ya da Rahatsız Etmeyin) Eşik
/// bildirimi nasıl duyurur. Android tarafı (EsikNotifications.kt) aynı adları okur.
enum SilentAlert {
  /// Telefonun ayarına uyar.
  quiet(EsikIcon.bellOff),

  /// Sessizde de titreşir.
  vibrate(EsikIcon.vibrate),

  /// Sessizde de çalar ve titreşir (alarm sesi düzeyinde).
  ring(EsikIcon.bellRing);

  const SilentAlert(this.icon);
  final EsikIcon icon;
}

/// Haftanın bütün günleri (DateTime.monday = 1 … DateTime.sunday = 7).
const allWeekdays = {1, 2, 3, 4, 5, 6, 7};

/// Bir modun eşikleri. Her eşik kendi günlerinde geçerlidir (ör. hafta içi,
/// hafta sonu); günler çakışmaz, hiçbir eşiğe ait olmayan gün izinlidir.
/// Kontrol listesi modun ortak listesidir; günlere göre farkı maddenin
/// günleri sağlar. Android ve iOS tarafı (EsikData.kt, EsikCore.swift) aynı
/// kuralla o günün eşiğini seçer.
extension ThresholdList on List<TriggerConfig> {
  /// [day] (eşik günü) için geçerli eşik; o gün izinliyse null.
  TriggerConfig? on(DateTime day) => where((c) => c.activeOn(day)).firstOrNull;

  /// Eşiklerin herhangi birinde seçili tetikleyiciler, [TriggerKind] sırasıyla.
  List<TriggerKind> get allKinds => [
    for (final k in TriggerKind.values)
      if (any((c) => c.kinds.contains(k))) k,
  ];

  /// Plus yoksa yalnızca ilk eşik, her gün (bkz. [TriggerConfig.effective]).
  List<TriggerConfig> effective({required bool plus}) =>
      plus ? this : [first.effective(plus: false)];

  /// [index]'teki eşikte [weekday] gününü açar ya da kapatır. Gün başka bir
  /// eşikteyse buraya taşınır. Bir eşiğin son günü alınamaz; değişmezse
  /// aynı liste döner.
  List<TriggerConfig> toggleDay(int index, int weekday) {
    final owner = indexWhere((c) => c.days.contains(weekday));
    if (owner == index) {
      final next = this[index].toggleDay(weekday);
      if (identical(next, this[index])) return this;
      return [...take(index), next, ...skip(index + 1)];
    }
    if (owner >= 0 && this[owner].days.length == 1) return this;
    return [
      for (var i = 0; i < length; i++)
        if (i == index)
          this[i].copyWith(days: {...this[i].days, weekday})
        else if (i == owner)
          this[i].copyWith(days: {...this[i].days}..remove(weekday))
        else
          this[i],
    ];
  }

  /// [template]'in ayarlarıyla [days] günleri için yeni eşik ekler; o günler
  /// diğer eşiklerden alınır, günü kalmayan eşik çıkar.
  List<TriggerConfig> withThreshold(TriggerConfig template, Set<int> days) => [
    for (final c in this)
      if (c.days.difference(days).isNotEmpty)
        c.copyWith(days: c.days.difference(days)),
    template.copyWith(days: days),
  ];

  /// [index]'teki eşiği siler; günleri ilk kalan eşiğe geçer. Son eşik silinmez.
  List<TriggerConfig> without(int index) {
    if (length <= 1) return this;
    final rest = [...take(index), ...skip(index + 1)];
    return [
      rest.first.copyWith(days: {...rest.first.days, ...this[index].days}),
      ...rest.skip(1),
    ];
  }
}

/// Bir eşiğin ayarı: hangi davranışlar, hangi günler ve saatlerde, yedek saat.
class TriggerConfig {
  const TriggerConfig({
    required this.kinds,
    this.days = allWeekdays,
    required this.windowStart,
    required this.windowEnd,
    this.windowEnabled = true,
    this.backupEnabled = true,
    required this.backupTime,
    this.delay = Duration.zero,
  });

  /// [delay]'in üst sınırı; Android tarafı (EsikData.MAX_DELAY_SECONDS) aynı.
  static const maxDelay = Duration(minutes: 59, seconds: 59);

  /// Seçili tetikleyiciler; en az biri. Hangisi önce olursa o gün o bildirir.
  final List<TriggerKind> kinds;

  /// Eşiğin çalıştığı günler (eşik günü, 04:00'te başlar). Diğer günlerde
  /// ne tetikleyici ne yedek saat hatırlatır.
  final Set<int> days;
  final TimeOfDay windowStart;
  final TimeOfDay windowEnd;
  final bool windowEnabled;
  final bool backupEnabled;
  final TimeOfDay backupTime;

  /// Tetikleyiciden ne kadar sonra bildirilir; sıfır: hemen. O arada kontrol
  /// yapılırsa bildirim gelmez. Yedek saati etkilemez.
  final Duration delay;

  bool activeOn(DateTime day) => days.contains(day.weekday);

  /// Tetikleyiciyi ekler ya da çıkarır; sonuncusu çıkarılamaz.
  /// Sıra her zaman [TriggerKind.values] sırasıdır.
  TriggerConfig toggle(TriggerKind kind) {
    final next = kinds.contains(kind)
        ? kinds.where((k) => k != kind).toList()
        : [...kinds, kind];
    if (next.isEmpty) return this;
    next.sort((a, b) => a.index.compareTo(b.index));
    return copyWith(kinds: next);
  }

  /// Eşik Plus yoksa geçerli olan hâli: tek ve ücretsiz bir tetikleyici,
  /// her gün. Kullanıcının asıl seçimi saklanır; Plus alınınca geri gelir.
  TriggerConfig effective({required bool plus}) {
    if (plus) return this;
    final mode = kinds.first.mode;
    final kind =
        kinds.where((k) => k.free).firstOrNull ??
        (mode == DayMode.evening
            ? TriggerKind.charging
            : TriggerKind.alarmStopped);
    return copyWith(kinds: [kind], days: allWeekdays);
  }

  /// Günü ekler ya da çıkarır; son gün çıkarılamaz.
  TriggerConfig toggleDay(int weekday) {
    final next = {...days};
    if (!next.remove(weekday)) next.add(weekday);
    return next.isEmpty ? this : copyWith(days: next);
  }

  TriggerConfig copyWith({
    List<TriggerKind>? kinds,
    Set<int>? days,
    TimeOfDay? windowStart,
    TimeOfDay? windowEnd,
    bool? windowEnabled,
    bool? backupEnabled,
    TimeOfDay? backupTime,
    Duration? delay,
  }) => TriggerConfig(
    kinds: kinds ?? this.kinds,
    days: days ?? this.days,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    windowEnabled: windowEnabled ?? this.windowEnabled,
    backupEnabled: backupEnabled ?? this.backupEnabled,
    backupTime: backupTime ?? this.backupTime,
    delay: delay ?? this.delay,
  );

  Map<String, Object?> toJson() => {
    'kinds': [for (final k in kinds) k.name],
    'days': days.toList()..sort(),
    'windowStart': _timeToJson(windowStart),
    'windowEnd': _timeToJson(windowEnd),
    'windowEnabled': windowEnabled,
    'backupEnabled': backupEnabled,
    'backupTime': _timeToJson(backupTime),
    'delaySeconds': delay.inSeconds,
  };

  /// [fallback], eksik ya da bozuk alanlar için kullanılır. Eski kayıtlardaki
  /// tek "kind" alanı da okunur.
  factory TriggerConfig.fromJson(
    Map<String, Object?> json,
    TriggerConfig fallback,
  ) {
    final mode = fallback.kinds.first.mode;
    final names = switch (json['kinds']) {
      final List<Object?> list => list,
      _ => [json['kind']],
    };
    // Başka bir moda ait ya da bilinmeyen tetikleyiciler atılır.
    final kinds = TriggerKind.values
        .where((k) => k.mode == mode && names.contains(k.name))
        .toList();
    final days = switch (json['days']) {
      final List<Object?> list => {
        for (final d in list)
          if (d is int && d >= 1 && d <= 7) d,
      },
      _ => fallback.days,
    };
    return TriggerConfig(
      kinds: kinds.isEmpty ? fallback.kinds : kinds,
      days: days.isEmpty ? fallback.days : days,
      windowStart: _timeFromJson(json['windowStart'], fallback.windowStart),
      windowEnd: _timeFromJson(json['windowEnd'], fallback.windowEnd),
      windowEnabled: json['windowEnabled'] as bool? ?? fallback.windowEnabled,
      backupEnabled: json['backupEnabled'] as bool? ?? fallback.backupEnabled,
      backupTime: _timeFromJson(json['backupTime'], fallback.backupTime),
      delay: Duration(
        seconds: switch (json['delaySeconds']) {
          final int s => s.clamp(0, maxDelay.inSeconds),
          _ => fallback.delay.inSeconds,
        },
      ),
    );
  }
}

/// Bir eşik gününün bir modundaki kontrol: tiklenen maddeler ve bitiş anı.
class CheckSession {
  const CheckSession({
    this.checked = const {},
    this.completedAt,
    this.source,
    this.checkedAt = const {},
    this.photos = const {},
  });

  final Set<String> checked;

  /// Her maddenin işaretlendiği an ("Kapı 08:12'de kilitlendi").
  final Map<String, DateTime> checkedAt;

  /// Fotoğrafla kontrol edilen maddelerin fotoğraf dosyası (uygulamanın
  /// photos klasöründe, yalnızca ad).
  final Map<String, String> photos;
  final DateTime? completedAt;

  /// Nereden tamamlandı: [sourceApp], [sourceNotification] ya da [sourceBackup].
  /// Android tarafı (EsikData.kt) aynı değerleri yazar.
  final String? source;

  static const sourceApp = 'app';
  static const sourceNotification = 'notification';
  static const sourceBackup = 'backup';

  bool get isComplete => completedAt != null;
  bool get isEmpty => checked.isEmpty && completedAt == null;
  bool get viaBackup => source == sourceBackup;

  Map<String, Object?> toJson() => {
    'checked': checked.toList(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    'source': ?source,
    if (checkedAt.isNotEmpty)
      'checkedAt': {
        for (final e in checkedAt.entries) e.key: e.value.toIso8601String(),
      },
    if (photos.isNotEmpty) 'photos': photos,
  };

  factory CheckSession.fromJson(Map<String, Object?> json) => CheckSession(
    checked: {...(json['checked'] as List? ?? const []).whereType<String>()},
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    source: json['source'] as String?,
    checkedAt: {
      if (json['checkedAt'] case final Map m)
        for (final e in m.entries)
          if (e.key is String && DateTime.tryParse('${e.value}') != null)
            e.key as String: DateTime.parse('${e.value}'),
    },
    photos: {
      if (json['photos'] case final Map m)
        for (final e in m.entries)
          if (e.key is String && e.value is String)
            e.key as String: e.value as String,
    },
  );
}

/// Bir günün bir eşiğinin sonucu.
enum CheckOutcome {
  /// Tetikleyiciyle gelen kontrol tamamlandı.
  done,

  /// Tetikleyici çalışmadı, yedek saatteki bildirimle tamamlandı.
  viaBackup,

  /// Kontrol yapılmadı.
  missed,

  /// O gün uygulama henüz kurulu değildi; ne tamam ne atlandı sayılır.
  notTracked,

  /// Eşiğin çalışmadığı gün (Ayarlar → günler); atlandı sayılmaz.
  off;

  bool get completed => this == done || this == viaBackup;
  bool get tracked => this != notTracked && this != off;
}

class DayLog {
  const DayLog({
    required this.date,
    required this.evening,
    required this.morning,
    this.eveningAt,
    this.morningAt,
  });

  final DateTime date;
  final CheckOutcome evening;
  final CheckOutcome morning;
  final TimeOfDay? eveningAt;
  final TimeOfDay? morningAt;

  CheckOutcome outcome(DayMode mode) =>
      mode == DayMode.evening ? evening : morning;
}

String formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Saati bulunma ekiyle yazar: "22:30’da", "08:15’te", "23:08’de".
/// Ek, saatin okunuşundaki son sayıya göre seçilir (dakika 00 ise saate göre).
String timeAt(TimeOfDay t) {
  final n = t.minute != 0 ? t.minute : t.hour;
  // Birler: bir, iki, üç, dört, beş, altı, yedi, sekiz, dokuz.
  const units = ['', 'de', 'de', 'te', 'te', 'te', 'da', 'de', 'de', 'da'];
  // Onlar: sıfır, on, yirmi, otuz, kırk, elli.
  const tens = ['da', 'da', 'de', 'da', 'ta', 'de'];
  final suffix = n % 10 != 0 ? units[n % 10] : tens[n ~/ 10];
  return '${formatTime(t)}’$suffix';
}

/// İlk harfi küçültür; Türkçede "İ" → "i", "I" → "ı".
String lowerFirst(String s, {bool turkish = true}) {
  if (s.isEmpty) return s;
  final first = switch (s[0]) {
    'İ' when turkish => 'i',
    'I' when turkish => 'ı',
    final c => c.toLowerCase(),
  };
  return first + s.substring(1);
}
