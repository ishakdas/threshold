import 'package:flutter/material.dart' show TimeOfDay;

import '../core/day_mode.dart';
import '../ui/esik_icons.dart';

/// Kontrol listesindeki tek bir madde ("Ütünün fişini çektim mi?").
class CheckItem {
  const CheckItem({required this.id, required this.title, required this.icon});

  final String id;
  final String title;
  final EsikIcon icon;

  CheckItem copyWith({String? title, EsikIcon? icon}) =>
      CheckItem(id: id, title: title ?? this.title, icon: icon ?? this.icon);

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'icon': icon.name,
  };

  factory CheckItem.fromJson(Map<String, Object?> json) => CheckItem(
    id: json['id']! as String,
    title: json['title']! as String,
    icon: _byName(EsikIcon.values, json['icon'], EsikIcon.checklist),
  );
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
  charging(
    DayMode.evening,
    'Şarja takınca',
    'Yatağın yanında',
    'Telefonu şarja taktığında',
    EsikIcon.plug,
  ),
  appClosed(
    DayMode.evening,
    'Uygulama kapanınca',
    'Instagram',
    'Instagram’ı kapattığında',
    EsikIcon.app,
  ),
  sleepMode(
    DayMode.evening,
    'Uyku modu',
    'Açılınca',
    'Uyku modu açıldığında',
    EsikIcon.bed,
  ),
  airplaneMode(
    DayMode.evening,
    'Uçak modu',
    'Açılınca',
    'Uçak modunu açtığında',
    EsikIcon.airplane,
  ),
  alarmStopped(
    DayMode.morning,
    'Alarmı durdurunca',
    'Sabah alarmı',
    'Alarmı durdurduğunda',
    EsikIcon.alarm,
  ),
  unplugged(
    DayMode.morning,
    'Şarjdan çıkarınca',
    'Telefonu alınca',
    'Telefonu şarjdan çıkardığında',
    EsikIcon.plug,
  ),
  leftHomeWifi(
    DayMode.morning,
    'Ev Wi‑Fi’ından çıkınca',
    'Evden ayrılınca',
    'Ev Wi‑Fi’ından ayrıldığında',
    EsikIcon.wifi,
  ),
  nfcTag(
    DayMode.morning,
    'Kapıdaki etikete dokununca',
    'NFC etiketi',
    'Kapıdaki etikete dokunduğunda',
    EsikIcon.nfc,
  );

  const TriggerKind(this.mode, this.title, this.subtitle, this.when, this.icon);

  final DayMode mode;
  final String title;
  final String subtitle;

  /// Cümle içinde kullanılan hâli: "Telefonu şarja taktığında ...".
  final String when;
  final EsikIcon icon;

  /// Android'de çalışan tetikleyiciler (android/.../Triggers.kt). Diğerleri
  /// listede "Yakında" olarak görünür; o güne kadar yedek saat devrede.
  bool get supported => switch (this) {
    charging || alarmStopped || leftHomeWifi || nfcTag => true,
    appClosed || sleepMode || airplaneMode || unplugged => false,
  };

  static List<TriggerKind> forMode(DayMode mode) =>
      values.where((k) => k.mode == mode).toList();
}

/// Bir modun eşik ayarı: hangi davranış, hangi saatlerde, yedek saat.
class TriggerConfig {
  const TriggerConfig({
    required this.kind,
    required this.windowStart,
    required this.windowEnd,
    this.windowEnabled = true,
    this.backupEnabled = true,
    required this.backupTime,
  });

  final TriggerKind kind;
  final TimeOfDay windowStart;
  final TimeOfDay windowEnd;
  final bool windowEnabled;
  final bool backupEnabled;
  final TimeOfDay backupTime;

  TriggerConfig copyWith({
    TriggerKind? kind,
    TimeOfDay? windowStart,
    TimeOfDay? windowEnd,
    bool? windowEnabled,
    bool? backupEnabled,
    TimeOfDay? backupTime,
  }) => TriggerConfig(
    kind: kind ?? this.kind,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    windowEnabled: windowEnabled ?? this.windowEnabled,
    backupEnabled: backupEnabled ?? this.backupEnabled,
    backupTime: backupTime ?? this.backupTime,
  );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'windowStart': _timeToJson(windowStart),
    'windowEnd': _timeToJson(windowEnd),
    'windowEnabled': windowEnabled,
    'backupEnabled': backupEnabled,
    'backupTime': _timeToJson(backupTime),
  };

  /// [fallback], eksik ya da bozuk alanlar için kullanılır.
  factory TriggerConfig.fromJson(
    Map<String, Object?> json,
    TriggerConfig fallback,
  ) {
    final kind = _byName(TriggerKind.values, json['kind'], fallback.kind);
    return TriggerConfig(
      // Başka bir moda ait tetikleyici kaydedilmişse varsayılana dön.
      kind: kind.mode == fallback.kind.mode ? kind : fallback.kind,
      windowStart: _timeFromJson(json['windowStart'], fallback.windowStart),
      windowEnd: _timeFromJson(json['windowEnd'], fallback.windowEnd),
      windowEnabled: json['windowEnabled'] as bool? ?? fallback.windowEnabled,
      backupEnabled: json['backupEnabled'] as bool? ?? fallback.backupEnabled,
      backupTime: _timeFromJson(json['backupTime'], fallback.backupTime),
    );
  }
}

/// Bir eşik gününün bir modundaki kontrol: tiklenen maddeler ve bitiş anı.
class CheckSession {
  const CheckSession({this.checked = const {}, this.completedAt, this.source});

  final Set<String> checked;
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
  };

  factory CheckSession.fromJson(Map<String, Object?> json) => CheckSession(
    checked: {...(json['checked'] as List? ?? const []).whereType<String>()},
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    source: json['source'] as String?,
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
  notTracked;

  bool get completed => this == done || this == viaBackup;
  bool get tracked => this != notTracked;
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

/// Türkçe kurallarına uygun ilk harfi küçültme ("İ" → "i", "I" → "ı").
String lowerFirst(String s) {
  if (s.isEmpty) return s;
  final first = switch (s[0]) {
    'İ' => 'i',
    'I' => 'ı',
    final c => c.toLowerCase(),
  };
  return first + s.substring(1);
}
