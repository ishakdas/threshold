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
  silenced(
    DayMode.evening,
    'Sessize alınca',
    'Sesi kısınca',
    'Telefonu sessize aldığında',
    EsikIcon.bellOff,
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
  unsilenced(
    DayMode.morning,
    'Sessizden çıkarınca',
    'Sesi açınca',
    'Telefonu sessizden çıkardığında',
    EsikIcon.bellRing,
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
    charging ||
    silenced ||
    alarmStopped ||
    unsilenced ||
    leftHomeWifi ||
    nfcTag => true,
    appClosed || sleepMode || airplaneMode || unplugged => false,
  };

  /// Önce çalışanlar, "Yakında" olanlar sonda.
  static List<TriggerKind> forMode(DayMode mode) => [
    ...values.where((k) => k.mode == mode && k.supported),
    ...values.where((k) => k.mode == mode && !k.supported),
  ];
}

/// Telefon sessizdeyken (sessiz, titreşim ya da Rahatsız Etmeyin) Eşik
/// bildirimi nasıl duyurur. Android tarafı (EsikNotifications.kt) aynı adları okur.
enum SilentAlert {
  /// Telefonun ayarına uyar.
  quiet('Kapalı', EsikIcon.bellOff),

  /// Sessizde de titreşir.
  vibrate('Titret', EsikIcon.vibrate),

  /// Sessizde de çalar ve titreşir (alarm sesi düzeyinde).
  ring('Çal', EsikIcon.bellRing);

  const SilentAlert(this.label, this.icon);
  final String label;
  final EsikIcon icon;
}

/// Haftanın bütün günleri (DateTime.monday = 1 … DateTime.sunday = 7).
const allWeekdays = {1, 2, 3, 4, 5, 6, 7};

/// Pazartesiden başlayarak günlerin tek harfi.
const weekdayLetters = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
const weekdayNames = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

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
  });

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

  bool activeOn(DateTime day) => days.contains(day.weekday);

  /// Başlık: "Şarja takınca", "Şarja takınca ya da sessize alınca",
  /// "Alarmı durdurunca +2".
  String get title => switch (kinds) {
    [final k] => k.title,
    [final a, final b] => '${a.title} ya da ${lowerFirst(b.title)}',
    [final a, ...final rest] => '${a.title} +${rest.length}',
    [] => 'Yalnızca yedek saat',
  };

  /// Dar yerler için: "Şarja takınca", "Şarja takınca +1".
  String get shortTitle =>
      kinds.length <= 1 ? title : '${kinds.first.title} +${kinds.length - 1}';

  /// Cümle içinde: "Telefonu şarja taktığında ya da sessize aldığında".
  String get when => switch (kinds) {
    [final k] => k.when,
    [final a, final b] => '${a.when} ya da ${lowerFirst(b.when)}',
    _ => 'Seçtiğin ${kinds.length} davranıştan biri olduğunda',
  };

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
  }) => TriggerConfig(
    kinds: kinds ?? this.kinds,
    days: days ?? this.days,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    windowEnabled: windowEnabled ?? this.windowEnabled,
    backupEnabled: backupEnabled ?? this.backupEnabled,
    backupTime: backupTime ?? this.backupTime,
  );

  Map<String, Object?> toJson() => {
    'kinds': [for (final k in kinds) k.name],
    'days': days.toList()..sort(),
    'windowStart': _timeToJson(windowStart),
    'windowEnd': _timeToJson(windowEnd),
    'windowEnabled': windowEnabled,
    'backupEnabled': backupEnabled,
    'backupTime': _timeToJson(backupTime),
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

/// Bir anı bugüne göre yazar: "bugün 14:05", "yarın 07:30", "dün 22:41".
String formatWhen(DateTime at, DateTime now) {
  final d = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final day = switch (d.difference(today).inDays) {
    0 => 'bugün',
    1 => 'yarın',
    -1 => 'dün',
    _ => '${at.day}.${at.month}',
  };
  return '$day ${formatTime(TimeOfDay.fromDateTime(at))}';
}

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
