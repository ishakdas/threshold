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
}

/// Bir günün bir eşiğinin sonucu.
enum CheckOutcome {
  /// Tetikleyiciyle gelen kontrol tamamlandı.
  done,

  /// Tetikleyici çalışmadı, yedek saatteki bildirimle tamamlandı.
  viaBackup,

  /// Kontrol yapılmadı.
  missed,
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
