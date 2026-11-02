import 'package:flutter/material.dart' show BuildContext, TimeOfDay;
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../ui/esik_icons.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Ekranlarda kısa yol: `context.l10n.today`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension L10nHelpers on AppLocalizations {
  bool get isTurkish => localeName == 'tr';

  /// Cümle içinde saat: Türkçede bulunma ekiyle ("22:30’da"), diğer dillerde
  /// yalın ("22:30"); "{time}" çevirideki edatla birleşir ("at 22:30").
  String at(TimeOfDay t) => isTurkish ? timeAt(t) : formatTime(t);

  /// Cümle ortasına giren ad: ilk harf küçük.
  String lower(String s) => lowerFirst(s, turkish: isTurkish);

  /// Pazartesiden başlayarak günlerin tek harfi.
  List<String> get weekdayLetterList => weekdayLetters.split(',');

  /// [weekday]: 1 = Pazartesi … 7 = Pazar.
  String weekdayName(int weekday) =>
      DateFormat.EEEE(localeName).format(DateTime(2024, 1, weekday));

  /// Bir anı bugüne göre yazar: "bugün 14:05", "tomorrow 07:30".
  String when(DateTime at, DateTime now) {
    final d = DateTime(at.year, at.month, at.day);
    final today0 = DateTime(now.year, now.month, now.day);
    final day = switch (d.difference(today0).inDays) {
      0 => today,
      1 => tomorrow,
      -1 => yesterday,
      _ => DateFormat.MMMd(localeName).format(at),
    };
    return dayAndTime(day, formatTime(TimeOfDay.fromDateTime(at)));
  }
}

extension DelayText on AppLocalizations {
  /// "30 sn", "5 dk", "2 dk 30 sn"; sıfırsa "Hemen".
  String delay(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0 && s == 0) return delayNow;
    if (m == 0) return delaySeconds(s);
    if (s == 0) return delayMinutes(m);
    return delayMinSec(m, s);
  }
}

extension TriggerKindText on TriggerKind {
  String title(AppLocalizations l) => switch (this) {
    TriggerKind.charging => l.triggerChargingTitle,
    TriggerKind.silenced => l.triggerSilencedTitle,
    TriggerKind.offline => l.triggerOfflineTitle,
    TriggerKind.appClosed => l.triggerAppClosedTitle,
    TriggerKind.sleepMode => l.triggerSleepModeTitle,
    TriggerKind.airplaneMode => l.triggerAirplaneModeTitle,
    TriggerKind.alarmStopped => l.triggerAlarmStoppedTitle,
    TriggerKind.unsilenced => l.triggerUnsilencedTitle,
    TriggerKind.unplugged => l.triggerUnpluggedTitle,
    TriggerKind.leftHomeWifi => l.triggerLeftHomeWifiTitle,
    TriggerKind.nfcTag => l.triggerNfcTagTitle,
  };

  String subtitle(AppLocalizations l) => switch (this) {
    TriggerKind.charging => l.triggerChargingSubtitle,
    TriggerKind.silenced => l.triggerSilencedSubtitle,
    TriggerKind.offline => l.triggerOfflineSubtitle,
    TriggerKind.appClosed => l.triggerAppClosedSubtitle,
    TriggerKind.sleepMode => l.triggerSleepModeSubtitle,
    TriggerKind.airplaneMode => l.triggerAirplaneModeSubtitle,
    TriggerKind.alarmStopped => l.triggerAlarmStoppedSubtitle,
    TriggerKind.unsilenced => l.triggerUnsilencedSubtitle,
    TriggerKind.unplugged => l.triggerUnpluggedSubtitle,
    TriggerKind.leftHomeWifi => l.triggerLeftHomeWifiSubtitle,
    TriggerKind.nfcTag => l.triggerNfcTagSubtitle,
  };

  /// Cümle içinde kullanılan hâli: "Telefonu şarja taktığında ...".
  String when(AppLocalizations l) => switch (this) {
    TriggerKind.charging => l.triggerChargingWhen,
    TriggerKind.silenced => l.triggerSilencedWhen,
    TriggerKind.offline => l.triggerOfflineWhen,
    TriggerKind.appClosed => l.triggerAppClosedWhen,
    TriggerKind.sleepMode => l.triggerSleepModeWhen,
    TriggerKind.airplaneMode => l.triggerAirplaneModeWhen,
    TriggerKind.alarmStopped => l.triggerAlarmStoppedWhen,
    TriggerKind.unsilenced => l.triggerUnsilencedWhen,
    TriggerKind.unplugged => l.triggerUnpluggedWhen,
    TriggerKind.leftHomeWifi => l.triggerLeftHomeWifiWhen,
    TriggerKind.nfcTag => l.triggerNfcTagWhen,
  };
}

extension TriggerConfigText on TriggerConfig {
  /// Başlık: "Şarja takınca", "Şarja takınca ya da sessize alınca",
  /// "Alarmı durdurunca +2".
  String title(AppLocalizations l) => switch (kinds) {
    [final k] => k.title(l),
    [final a, final b] => l.triggersOr(a.title(l), l.lower(b.title(l))),
    [final a, ...final rest] => l.triggersMore(a.title(l), rest.length),
    [] => l.triggersBackupOnly,
  };

  /// Dar yerler için: "Şarja takınca", "Şarja takınca +1".
  String shortTitle(AppLocalizations l) => kinds.length <= 1
      ? title(l)
      : l.triggersMore(kinds.first.title(l), kinds.length - 1);

  /// Cümle içinde: "Telefonu şarja taktığında ya da sessize aldığında".
  String when(AppLocalizations l) => switch (kinds) {
    [final k] => k.when(l),
    [final a, final b] => l.triggersOr(a.when(l), l.lower(b.when(l))),
    _ => l.triggersAnyOf(kinds.length),
  };
}

extension SilentAlertText on SilentAlert {
  String label(AppLocalizations l) => switch (this) {
    SilentAlert.quiet => l.silentAlertQuiet,
    SilentAlert.vibrate => l.silentAlertVibrate,
    SilentAlert.ring => l.silentAlertRing,
  };
}

extension ThresholdDaysText on TriggerConfig {
  /// Eşiğin adı, günlerinden: "Her gün", "Hafta içi", "Pzt, Çar"…
  String daysLabel(AppLocalizations l) {
    final d = days;
    if (d.length == 7) return l.daysEveryDay;
    if (d.length == 5 && d.containsAll({1, 2, 3, 4, 5})) return l.daysWeekdays;
    if (d.length == 2 && d.containsAll({6, 7})) return l.daysWeekend;
    if (d.length == 2 && d.containsAll({5, 6})) return l.daysWeekendNights;
    // Pazartesi'den başlayan bir haftanın günleri (2026-11-02 bir Pazartesi).
    final names = [
      for (final w in d.toList()..sort())
        DateFormat.E(l.localeName).format(DateTime(2026, 11, 1 + w)),
    ];
    return names.join(', ');
  }
}

extension WeatherNeedText on WeatherNeed {
  String label(AppLocalizations l) => switch (this) {
    WeatherNeed.always => l.weatherAlways,
    WeatherNeed.rain => l.weatherRain,
    WeatherNeed.cold => l.weatherCold,
    WeatherNeed.hot => l.weatherHot,
  };

  String hint(AppLocalizations l) => switch (this) {
    WeatherNeed.always => '',
    WeatherNeed.rain => l.weatherHintRain,
    WeatherNeed.cold => l.weatherHintCold,
    WeatherNeed.hot => l.weatherHintHot,
  };
}

extension EsikIconText on EsikIcon {
  /// Madde ikonunun kısa adı ("Ütü"); listede olmayan ikonlarda null.
  String? label(AppLocalizations l) => switch (this) {
    EsikIcon.iron => l.iconIron,
    EsikIcon.plug => l.iconPlug,
    EsikIcon.flame => l.iconFlame,
    EsikIcon.lock => l.iconLock,
    EsikIcon.key => l.iconKey,
    EsikIcon.bag => l.iconBag,
    EsikIcon.wallet => l.iconWallet,
    EsikIcon.bulb => l.iconBulb,
    EsikIcon.pill => l.iconPill,
    EsikIcon.notes => l.iconNotes,
    EsikIcon.checklist => l.iconChecklist,
    EsikIcon.umbrella => l.iconUmbrella,
    EsikIcon.coat => l.iconCoat,
    EsikIcon.drop => l.iconDrop,
    EsikIcon.paw => l.iconPaw,
    _ => null,
  };
}
