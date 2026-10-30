import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' show TimeOfDay;

import '../core/day_mode.dart';
import '../ui/esik_icons.dart';

/// iOS'ta tetikleyiciler uygulamanın kendisinde değil, Kestirmeler
/// otomasyonlarında çalışır (ios/Runner/EsikIntents.swift).
bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

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
  charging(DayMode.evening, EsikIcon.plug),
  silenced(DayMode.evening, EsikIcon.bellOff),
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

/// Bir modun eşik ayarı: hangi davranışlar, hangi günler ve saatlerde, yedek saat.
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
