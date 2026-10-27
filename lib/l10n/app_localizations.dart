import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @triggerChargingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şarja takınca'**
  String get triggerChargingTitle;

  /// No description provided for @triggerChargingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yatağın yanında'**
  String get triggerChargingSubtitle;

  /// No description provided for @triggerChargingWhen.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu şarja taktığında'**
  String get triggerChargingWhen;

  /// No description provided for @triggerSilencedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessize alınca'**
  String get triggerSilencedTitle;

  /// No description provided for @triggerSilencedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sesi kısınca'**
  String get triggerSilencedSubtitle;

  /// No description provided for @triggerSilencedWhen.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu sessize aldığında'**
  String get triggerSilencedWhen;

  /// No description provided for @triggerAppClosedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kapanınca'**
  String get triggerAppClosedTitle;

  /// No description provided for @triggerAppClosedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Instagram'**
  String get triggerAppClosedSubtitle;

  /// No description provided for @triggerAppClosedWhen.
  ///
  /// In tr, this message translates to:
  /// **'Instagram’ı kapattığında'**
  String get triggerAppClosedWhen;

  /// No description provided for @triggerSleepModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyku modu'**
  String get triggerSleepModeTitle;

  /// No description provided for @triggerSleepModeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Açılınca'**
  String get triggerSleepModeSubtitle;

  /// No description provided for @triggerSleepModeWhen.
  ///
  /// In tr, this message translates to:
  /// **'Uyku modu açıldığında'**
  String get triggerSleepModeWhen;

  /// No description provided for @triggerAirplaneModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uçak modu'**
  String get triggerAirplaneModeTitle;

  /// No description provided for @triggerAirplaneModeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Açılınca'**
  String get triggerAirplaneModeSubtitle;

  /// No description provided for @triggerAirplaneModeWhen.
  ///
  /// In tr, this message translates to:
  /// **'Uçak modunu açtığında'**
  String get triggerAirplaneModeWhen;

  /// No description provided for @triggerAlarmStoppedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı durdurunca'**
  String get triggerAlarmStoppedTitle;

  /// No description provided for @triggerAlarmStoppedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sabah alarmı'**
  String get triggerAlarmStoppedSubtitle;

  /// No description provided for @triggerAlarmStoppedWhen.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı durdurduğunda'**
  String get triggerAlarmStoppedWhen;

  /// No description provided for @triggerUnsilencedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessizden çıkarınca'**
  String get triggerUnsilencedTitle;

  /// No description provided for @triggerUnsilencedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sesi açınca'**
  String get triggerUnsilencedSubtitle;

  /// No description provided for @triggerUnsilencedWhen.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu sessizden çıkardığında'**
  String get triggerUnsilencedWhen;

  /// No description provided for @triggerUnpluggedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şarjdan çıkarınca'**
  String get triggerUnpluggedTitle;

  /// No description provided for @triggerUnpluggedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu alınca'**
  String get triggerUnpluggedSubtitle;

  /// No description provided for @triggerUnpluggedWhen.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu şarjdan çıkardığında'**
  String get triggerUnpluggedWhen;

  /// No description provided for @triggerLeftHomeWifiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ev Wi‑Fi’ından çıkınca'**
  String get triggerLeftHomeWifiTitle;

  /// No description provided for @triggerLeftHomeWifiSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Evden ayrılınca'**
  String get triggerLeftHomeWifiSubtitle;

  /// No description provided for @triggerLeftHomeWifiWhen.
  ///
  /// In tr, this message translates to:
  /// **'Ev Wi‑Fi’ından ayrıldığında'**
  String get triggerLeftHomeWifiWhen;

  /// No description provided for @triggerNfcTagTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kapıdaki etikete dokununca'**
  String get triggerNfcTagTitle;

  /// No description provided for @triggerNfcTagSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NFC etiketi'**
  String get triggerNfcTagSubtitle;

  /// No description provided for @triggerNfcTagWhen.
  ///
  /// In tr, this message translates to:
  /// **'Kapıdaki etikete dokunduğunda'**
  String get triggerNfcTagWhen;

  /// No description provided for @triggersOr.
  ///
  /// In tr, this message translates to:
  /// **'{a} ya da {b}'**
  String triggersOr(String a, String b);

  /// No description provided for @triggersMore.
  ///
  /// In tr, this message translates to:
  /// **'{first} +{count}'**
  String triggersMore(String first, int count);

  /// No description provided for @triggersAnyOf.
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin {count} davranıştan biri olduğunda'**
  String triggersAnyOf(int count);

  /// No description provided for @triggersBackupOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yedek saat'**
  String get triggersBackupOnly;

  /// No description provided for @silentAlertQuiet.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get silentAlertQuiet;

  /// No description provided for @silentAlertVibrate.
  ///
  /// In tr, this message translates to:
  /// **'Titret'**
  String get silentAlertVibrate;

  /// No description provided for @silentAlertRing.
  ///
  /// In tr, this message translates to:
  /// **'Çal'**
  String get silentAlertRing;

  /// No description provided for @weekdayLetters.
  ///
  /// In tr, this message translates to:
  /// **'P,S,Ç,P,C,C,P'**
  String get weekdayLetters;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'bugün'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'yarın'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'dün'**
  String get yesterday;

  /// No description provided for @dayAndTime.
  ///
  /// In tr, this message translates to:
  /// **'{day} {time}'**
  String dayAndTime(String day, String time);

  /// No description provided for @defaultEveningIron.
  ///
  /// In tr, this message translates to:
  /// **'Ütünün fişini çektim mi?'**
  String get defaultEveningIron;

  /// No description provided for @defaultEveningTodo.
  ///
  /// In tr, this message translates to:
  /// **'Yapılacaklar listemi tikledim mi?'**
  String get defaultEveningTodo;

  /// No description provided for @defaultEveningLock.
  ///
  /// In tr, this message translates to:
  /// **'Kapıyı kilitledim mi?'**
  String get defaultEveningLock;

  /// No description provided for @defaultMorningCharger.
  ///
  /// In tr, this message translates to:
  /// **'Çantama şarj aletini koydum mu?'**
  String get defaultMorningCharger;

  /// No description provided for @defaultMorningNotes.
  ///
  /// In tr, this message translates to:
  /// **'Akşamdan aldığım notlara baktım mı?'**
  String get defaultMorningNotes;

  /// No description provided for @defaultMorningKeys.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar ve cüzdan yanımda mı?'**
  String get defaultMorningKeys;

  /// No description provided for @checkTitleEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam kontrolü'**
  String get checkTitleEvening;

  /// No description provided for @checkTitleMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah kontrolü'**
  String get checkTitleMorning;

  /// No description provided for @checkProgressA11y.
  ///
  /// In tr, this message translates to:
  /// **'{done} / {total} tamamlandı'**
  String checkProgressA11y(int done, int total);

  /// No description provided for @checkDoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'tamamlandı'**
  String get checkDoneLabel;

  /// No description provided for @checkTapHint.
  ///
  /// In tr, this message translates to:
  /// **'Maddeye dokun, tik at'**
  String get checkTapHint;

  /// No description provided for @checkSnooze.
  ///
  /// In tr, this message translates to:
  /// **'10 dk sonra'**
  String get checkSnooze;

  /// No description provided for @allDone.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi tamam'**
  String get allDone;

  /// No description provided for @checkDoneAt.
  ///
  /// In tr, this message translates to:
  /// **'{title} · {time}'**
  String checkDoneAt(String title, String time);

  /// No description provided for @checkDoneEvening.
  ///
  /// In tr, this message translates to:
  /// **'İçin rahat. İyi geceler.'**
  String get checkDoneEvening;

  /// No description provided for @checkDoneMorning.
  ///
  /// In tr, this message translates to:
  /// **'Hazırsın. İyi günler.'**
  String get checkDoneMorning;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @iconIron.
  ///
  /// In tr, this message translates to:
  /// **'Ütü'**
  String get iconIron;

  /// No description provided for @iconPlug.
  ///
  /// In tr, this message translates to:
  /// **'Priz'**
  String get iconPlug;

  /// No description provided for @iconFlame.
  ///
  /// In tr, this message translates to:
  /// **'Ocak'**
  String get iconFlame;

  /// No description provided for @iconLock.
  ///
  /// In tr, this message translates to:
  /// **'Kilit'**
  String get iconLock;

  /// No description provided for @iconKey.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar'**
  String get iconKey;

  /// No description provided for @iconBag.
  ///
  /// In tr, this message translates to:
  /// **'Çanta'**
  String get iconBag;

  /// No description provided for @iconWallet.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan'**
  String get iconWallet;

  /// No description provided for @iconBulb.
  ///
  /// In tr, this message translates to:
  /// **'Lamba'**
  String get iconBulb;

  /// No description provided for @iconPill.
  ///
  /// In tr, this message translates to:
  /// **'İlaç'**
  String get iconPill;

  /// No description provided for @iconNotes.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get iconNotes;

  /// No description provided for @iconChecklist.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get iconChecklist;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get historyTitle;

  /// No description provided for @historyLast14.
  ///
  /// In tr, this message translates to:
  /// **'Son 14 gün'**
  String get historyLast14;

  /// No description provided for @historyActivity.
  ///
  /// In tr, this message translates to:
  /// **'Eşik etkinliği'**
  String get historyActivity;

  /// No description provided for @historyRange.
  ///
  /// In tr, this message translates to:
  /// **'{from}–{to} {month}'**
  String historyRange(int from, int to, String month);

  /// No description provided for @historyEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get historyEmpty;

  /// No description provided for @historyScoreA11y.
  ///
  /// In tr, this message translates to:
  /// **'{total} eşikten {done} tanesi tamamlandı'**
  String historyScoreA11y(int total, int done);

  /// No description provided for @historyPercent.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} tamamlandı'**
  String historyPercent(int percent);

  /// No description provided for @historyFirstSoon.
  ///
  /// In tr, this message translates to:
  /// **'İlk eşiğin yakında'**
  String get historyFirstSoon;

  /// No description provided for @historyGreat.
  ///
  /// In tr, this message translates to:
  /// **'Eşiği geçtin'**
  String get historyGreat;

  /// No description provided for @historyHalfway.
  ///
  /// In tr, this message translates to:
  /// **'Yolun yarısındasın'**
  String get historyHalfway;

  /// No description provided for @historyNewDay.
  ///
  /// In tr, this message translates to:
  /// **'Her gün yeni bir eşik'**
  String get historyNewDay;

  /// No description provided for @historyGridA11y.
  ///
  /// In tr, this message translates to:
  /// **'Akşam ve sabah kontrolleri, son iki hafta'**
  String get historyGridA11y;

  /// No description provided for @outcomeDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get outcomeDone;

  /// No description provided for @outcomeViaBackup.
  ///
  /// In tr, this message translates to:
  /// **'Yedek bildirimle'**
  String get outcomeViaBackup;

  /// No description provided for @outcomeMissed.
  ///
  /// In tr, this message translates to:
  /// **'Atlandı'**
  String get outcomeMissed;

  /// No description provided for @outcomeNotTracked.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt yok'**
  String get outcomeNotTracked;

  /// No description provided for @outcomeOff.
  ///
  /// In tr, this message translates to:
  /// **'İzin günü'**
  String get outcomeOff;

  /// No description provided for @historyAverageEvening.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama akşam eşiği'**
  String get historyAverageEvening;

  /// No description provided for @historyEveningTrigger.
  ///
  /// In tr, this message translates to:
  /// **'Akşam tetikleyicisi'**
  String get historyEveningTrigger;

  /// No description provided for @historyEarliest.
  ///
  /// In tr, this message translates to:
  /// **'En erken {time}'**
  String historyEarliest(String time);

  /// No description provided for @historyLatest.
  ///
  /// In tr, this message translates to:
  /// **'En geç {time}'**
  String historyLatest(String time);

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Eşik'**
  String get appName;

  /// No description provided for @todayDoneAt.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı · {time}'**
  String todayDoneAt(String time);

  /// No description provided for @todayContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et · {count} madde kaldı'**
  String todayContinue(int count);

  /// No description provided for @todayCheckNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi kontrol et'**
  String get todayCheckNow;

  /// No description provided for @todayThresholdEvening.
  ///
  /// In tr, this message translates to:
  /// **'Bu akşamki eşiğin'**
  String get todayThresholdEvening;

  /// No description provided for @todayThresholdMorning.
  ///
  /// In tr, this message translates to:
  /// **'Bu sabahki eşiğin'**
  String get todayThresholdMorning;

  /// No description provided for @todayOffDay.
  ///
  /// In tr, this message translates to:
  /// **'Bugün izin günü; Eşik hatırlatmaz. İstersen yine de kontrol edebilirsin.'**
  String get todayOffDay;

  /// No description provided for @todayCardBody.
  ///
  /// In tr, this message translates to:
  /// **'{when} {count} maddelik kontrolün önüne gelir.'**
  String todayCardBody(String when, int count);

  /// No description provided for @todayItemsProgress.
  ///
  /// In tr, this message translates to:
  /// **'{count} madde · {done}/{count}'**
  String todayItemsProgress(int count, int done);

  /// No description provided for @summaryEveningDoneAt.
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam {time} tamam'**
  String summaryEveningDoneAt(String time);

  /// No description provided for @summaryMorningDoneAt.
  ///
  /// In tr, this message translates to:
  /// **'Bu sabah {time} tamam'**
  String summaryMorningDoneAt(String time);

  /// No description provided for @summaryMorningNotDone.
  ///
  /// In tr, this message translates to:
  /// **'Bu sabah yapılmadı'**
  String get summaryMorningNotDone;

  /// No description provided for @summaryMorningPartial.
  ///
  /// In tr, this message translates to:
  /// **'Bu sabah yarım kaldı'**
  String get summaryMorningPartial;

  /// No description provided for @summaryLastNightDoneAt.
  ///
  /// In tr, this message translates to:
  /// **'Dün akşam {time} tamam'**
  String summaryLastNightDoneAt(String time);

  /// No description provided for @summaryLastNightMissed.
  ///
  /// In tr, this message translates to:
  /// **'Dün akşam atlandı'**
  String get summaryLastNightMissed;

  /// No description provided for @summaryLastNightNoRecord.
  ///
  /// In tr, this message translates to:
  /// **'Dün akşam kayıt yok'**
  String get summaryLastNightNoRecord;

  /// No description provided for @summaryLastNightOff.
  ///
  /// In tr, this message translates to:
  /// **'Dün akşam izin günüydü'**
  String get summaryLastNightOff;

  /// No description provided for @summaryGoToEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam eşiğine geç'**
  String get summaryGoToEvening;

  /// No description provided for @summaryGoToMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah eşiğine geç'**
  String get summaryGoToMorning;

  /// No description provided for @summaryEveningLine.
  ///
  /// In tr, this message translates to:
  /// **'Akşam eşiği · {trigger}'**
  String summaryEveningLine(String trigger);

  /// No description provided for @summaryMorningLine.
  ///
  /// In tr, this message translates to:
  /// **'Sabah eşiği · {trigger}'**
  String summaryMorningLine(String trigger);

  /// No description provided for @summaryLast7A11y.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 gün: {done} tamamlandı'**
  String summaryLast7A11y(int done);

  /// No description provided for @modeEveningSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Akşam modu. Sabaha geç'**
  String get modeEveningSwitch;

  /// No description provided for @modeMorningSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Sabah modu. Akşama geç'**
  String get modeMorningSwitch;

  /// No description provided for @modeEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam modu'**
  String get modeEvening;

  /// No description provided for @modeMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah modu'**
  String get modeMorning;

  /// No description provided for @setupCardMore.
  ///
  /// In tr, this message translates to:
  /// **'{issue} · {count} eksik'**
  String setupCardMore(String issue, int count);

  /// No description provided for @setupCardA11y.
  ///
  /// In tr, this message translates to:
  /// **'{detail}. Kurulumu tamamla'**
  String setupCardA11y(String detail);

  /// No description provided for @setupFinish.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu tamamla'**
  String get setupFinish;

  /// No description provided for @dayStripA11y.
  ///
  /// In tr, this message translates to:
  /// **'{day}, {weekday}'**
  String dayStripA11y(int day, String weekday);

  /// No description provided for @dayStripDoneA11y.
  ///
  /// In tr, this message translates to:
  /// **'{day}, {weekday}, {count} eşik tamamlandı'**
  String dayStripDoneA11y(int day, String weekday, int count);

  /// No description provided for @issueNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler kapalı'**
  String get issueNotifications;

  /// No description provided for @issueBattery.
  ///
  /// In tr, this message translates to:
  /// **'Pil kısıtlaması açık'**
  String get issueBattery;

  /// No description provided for @issueNfcOff.
  ///
  /// In tr, this message translates to:
  /// **'NFC kapalı'**
  String get issueNfcOff;

  /// No description provided for @issueNfcTag.
  ///
  /// In tr, this message translates to:
  /// **'Etiket henüz yazılmadı'**
  String get issueNfcTag;

  /// No description provided for @issueNoAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Kurulu alarm yok'**
  String get issueNoAlarm;

  /// No description provided for @windowStartHelp.
  ///
  /// In tr, this message translates to:
  /// **'Aralığın başlangıcı'**
  String get windowStartHelp;

  /// No description provided for @windowEndHelp.
  ///
  /// In tr, this message translates to:
  /// **'Aralığın bitişi'**
  String get windowEndHelp;

  /// No description provided for @backupTimeHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yedek bildirim saati'**
  String get backupTimeHelp;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşiklerim'**
  String get settingsTitle;

  /// No description provided for @beforeBed.
  ///
  /// In tr, this message translates to:
  /// **'Yatmadan önce'**
  String get beforeBed;

  /// No description provided for @beforeLeaving.
  ///
  /// In tr, this message translates to:
  /// **'Evden çıkmadan önce'**
  String get beforeLeaving;

  /// No description provided for @pickStartTime.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç saatini seç'**
  String get pickStartTime;

  /// No description provided for @pickEndTime.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saatini seç'**
  String get pickEndTime;

  /// No description provided for @anyTime.
  ///
  /// In tr, this message translates to:
  /// **'Her saatte'**
  String get anyTime;

  /// No description provided for @onlyInWindow.
  ///
  /// In tr, this message translates to:
  /// **'Sadece bu aralıkta'**
  String get onlyInWindow;

  /// No description provided for @windowOff.
  ///
  /// In tr, this message translates to:
  /// **'Aralık kapalı'**
  String get windowOff;

  /// No description provided for @whatTriggers.
  ///
  /// In tr, this message translates to:
  /// **'Ne olunca?'**
  String get whatTriggers;

  /// No description provided for @firstOneWins.
  ///
  /// In tr, this message translates to:
  /// **'Hangisi önce olursa o gün o hatırlatır.'**
  String get firstOneWins;

  /// No description provided for @pickSeveral.
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla seçebilirsin; hangisi önce olursa o hatırlatır.'**
  String get pickSeveral;

  /// No description provided for @whichDays.
  ///
  /// In tr, this message translates to:
  /// **'Hangi günler?'**
  String get whichDays;

  /// No description provided for @changeBackupTime.
  ///
  /// In tr, this message translates to:
  /// **'Yedek saati değiştir'**
  String get changeBackupTime;

  /// No description provided for @backupRow.
  ///
  /// In tr, this message translates to:
  /// **'Hiçbiri olmazsa {time} hatırlat'**
  String backupRow(String time);

  /// No description provided for @backupReminder.
  ///
  /// In tr, this message translates to:
  /// **'Yedek bildirim'**
  String get backupReminder;

  /// No description provided for @setupCheck.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu kontrol et'**
  String get setupCheck;

  /// No description provided for @setupFinishMissing.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu tamamla · {count} eksik'**
  String setupFinishMissing(int count);

  /// No description provided for @autoSaved.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kendiliğinden kaydedilir'**
  String get autoSaved;

  /// No description provided for @timeButtonA11y.
  ///
  /// In tr, this message translates to:
  /// **'{label}, şu an {time}'**
  String timeButtonA11y(String label, String time);

  /// No description provided for @tileA11y.
  ///
  /// In tr, this message translates to:
  /// **'{title}, {subtitle}'**
  String tileA11y(String title, String subtitle);

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoon;

  /// No description provided for @comingSoonLower.
  ///
  /// In tr, this message translates to:
  /// **'yakında'**
  String get comingSoonLower;

  /// No description provided for @selected.
  ///
  /// In tr, this message translates to:
  /// **'Seçili'**
  String get selected;

  /// No description provided for @whenSilent.
  ///
  /// In tr, this message translates to:
  /// **'Telefon sessizdeyken'**
  String get whenSilent;

  /// No description provided for @silentQuietHint.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim telefonun ses ayarına uyar.'**
  String get silentQuietHint;

  /// No description provided for @silentVibrateHint.
  ///
  /// In tr, this message translates to:
  /// **'Sessizde ya da Rahatsız Etmeyin açıkken de titreşir.'**
  String get silentVibrateHint;

  /// No description provided for @silentMutedHint.
  ///
  /// In tr, this message translates to:
  /// **'Alarm sesi kapalı, bu yüzden duyulmaz. Ses tuşlarıyla alarm sesini aç.'**
  String get silentMutedHint;

  /// No description provided for @silentRingHint.
  ///
  /// In tr, this message translates to:
  /// **'Sessizde de alarm sesi düzeyinde çalar ve titreşir.'**
  String get silentRingHint;

  /// No description provided for @waitFrom.
  ///
  /// In tr, this message translates to:
  /// **'{when} itibarıyla {text}'**
  String waitFrom(String when, String text);

  /// No description provided for @waitCharging.
  ///
  /// In tr, this message translates to:
  /// **'şarja takılması bekleniyor'**
  String get waitCharging;

  /// No description provided for @waitWifi.
  ///
  /// In tr, this message translates to:
  /// **'Wi‑Fi bağlantısı bekleniyor'**
  String get waitWifi;

  /// No description provided for @waitLeaving.
  ///
  /// In tr, this message translates to:
  /// **'Wi‑Fi’dan çıkış bekleniyor'**
  String get waitLeaving;

  /// No description provided for @waitPluggedIn.
  ///
  /// In tr, this message translates to:
  /// **'telefonun şarjda olması bekleniyor'**
  String get waitPluggedIn;

  /// No description provided for @waitUnplug.
  ///
  /// In tr, this message translates to:
  /// **'şarjdan çıkarılması bekleniyor'**
  String get waitUnplug;

  /// No description provided for @waitAlarm.
  ///
  /// In tr, this message translates to:
  /// **'sıradaki alarm {when}'**
  String waitAlarm(String when);

  /// No description provided for @waitAlarmSettling.
  ///
  /// In tr, this message translates to:
  /// **'alarm çaldı, kapanması bekleniyor'**
  String get waitAlarmSettling;

  /// No description provided for @waitNoAlarm.
  ///
  /// In tr, this message translates to:
  /// **'kurulu alarm yok'**
  String get waitNoAlarm;

  /// No description provided for @waitSilence.
  ///
  /// In tr, this message translates to:
  /// **'sesin kısılması bekleniyor'**
  String get waitSilence;

  /// No description provided for @waitAlreadySilent.
  ///
  /// In tr, this message translates to:
  /// **'telefon zaten tamamen sessizde; önce sesi biraz aç'**
  String get waitAlreadySilent;

  /// No description provided for @waitUnsilence.
  ///
  /// In tr, this message translates to:
  /// **'sesin açılması bekleniyor'**
  String get waitUnsilence;

  /// No description provided for @waitNotSilent.
  ///
  /// In tr, this message translates to:
  /// **'zil zaten açık; gece sesi kısarsan sabah çalışır'**
  String get waitNotSilent;

  /// No description provided for @waitNone.
  ///
  /// In tr, this message translates to:
  /// **'kurulu değil'**
  String get waitNone;

  /// No description provided for @statusLine.
  ///
  /// In tr, this message translates to:
  /// **'Durum: {text}'**
  String statusLine(String text);

  /// No description provided for @statusLineKind.
  ///
  /// In tr, this message translates to:
  /// **'{kind}: {text}'**
  String statusLineKind(String kind, String text);

  /// No description provided for @hintCharging.
  ///
  /// In tr, this message translates to:
  /// **'Şarja taktıktan sonra birkaç dakika içinde gelir.'**
  String get hintCharging;

  /// No description provided for @hintUnplugged.
  ///
  /// In tr, this message translates to:
  /// **'Telefon sabah aralığında şarjdayken fişi çekince birkaç dakika içinde gelir.'**
  String get hintUnplugged;

  /// No description provided for @hintAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Saat uygulamasındaki alarm çalıp kapanınca gelir. Ertelersen bekler.'**
  String get hintAlarm;

  /// No description provided for @hintWifi.
  ///
  /// In tr, this message translates to:
  /// **'Wi‑Fi’dan kopup mobil veriye geçince gelir; mobil veri açık olmalı.'**
  String get hintWifi;

  /// No description provided for @hintSilenced.
  ///
  /// In tr, this message translates to:
  /// **'Ses bir kademe kısılınca gelir: sesliden titreşime, titreşimden sessize ya da Rahatsız Etmeyin açılınca.'**
  String get hintSilenced;

  /// No description provided for @hintUnsilenced.
  ///
  /// In tr, this message translates to:
  /// **'Ses bir kademe açılınca gelir: sessizden titreşime, titreşimden sesliye ya da Rahatsız Etmeyin kapanınca.'**
  String get hintUnsilenced;

  /// No description provided for @hintNfc.
  ///
  /// In tr, this message translates to:
  /// **'Etikete dokununca kontrol ekranı açılır.'**
  String get hintNfc;

  /// No description provided for @hintSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu tetikleyici yakında. O zamana kadar yedek saat hatırlatır.'**
  String get hintSoon;

  /// No description provided for @backupOff.
  ///
  /// In tr, this message translates to:
  /// **'Yedek bildirim kapalı'**
  String get backupOff;

  /// No description provided for @backupNext.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki yedek: {when}'**
  String backupNext(String when);

  /// No description provided for @backupLast.
  ///
  /// In tr, this message translates to:
  /// **'Son yedek: {when} {outcome}'**
  String backupLast(String when, String outcome);

  /// No description provided for @triggerLast.
  ///
  /// In tr, this message translates to:
  /// **'Son tetik: {when} {outcome}'**
  String triggerLast(String when, String outcome);

  /// No description provided for @triggerLastKind.
  ///
  /// In tr, this message translates to:
  /// **'Son tetik ({kind}): {when} {outcome}'**
  String triggerLastKind(String kind, String when, String outcome);

  /// No description provided for @outcomeShown.
  ///
  /// In tr, this message translates to:
  /// **'gönderildi'**
  String get outcomeShown;

  /// No description provided for @outcomeAlreadyDone.
  ///
  /// In tr, this message translates to:
  /// **'atlandı: kontrol zaten yapılmıştı'**
  String get outcomeAlreadyDone;

  /// No description provided for @outcomeAlreadyNotified.
  ///
  /// In tr, this message translates to:
  /// **'atlandı: o gün bildirim zaten gelmişti'**
  String get outcomeAlreadyNotified;

  /// No description provided for @outcomeNoPermission.
  ///
  /// In tr, this message translates to:
  /// **'gönderilemedi: bildirim izni kapalı'**
  String get outcomeNoPermission;

  /// No description provided for @outcomeDisabled.
  ///
  /// In tr, this message translates to:
  /// **'atlandı: yedek kapalı'**
  String get outcomeDisabled;

  /// No description provided for @outcomeOffDay.
  ///
  /// In tr, this message translates to:
  /// **'atlandı: izin günü'**
  String get outcomeOffDay;

  /// No description provided for @rangeA11y.
  ///
  /// In tr, this message translates to:
  /// **'Saat aralığı {start} ile {end} arası'**
  String rangeA11y(String start, String end);

  /// No description provided for @itemDeleted.
  ///
  /// In tr, this message translates to:
  /// **'“{title}” silindi'**
  String itemDeleted(String title);

  /// No description provided for @checklistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol listem'**
  String get checklistTitle;

  /// No description provided for @checklistEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu listede henüz madde yok. Aşağıdan ekleyebilirsin.'**
  String get checklistEmpty;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @checklistHint.
  ///
  /// In tr, this message translates to:
  /// **'Basılı tut ve sürükle · silmek için sola kaydır'**
  String get checklistHint;

  /// No description provided for @newItem.
  ///
  /// In tr, this message translates to:
  /// **'Yeni madde'**
  String get newItem;

  /// No description provided for @pickIcon.
  ///
  /// In tr, this message translates to:
  /// **'İkon seç'**
  String get pickIcon;

  /// No description provided for @dragToReorder.
  ///
  /// In tr, this message translates to:
  /// **'Sürükleyerek sırala'**
  String get dragToReorder;

  /// No description provided for @newItemHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Ocağı kapattım mı?'**
  String get newItemHint;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @stepNotifTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlere izin ver'**
  String get stepNotifTitle;

  /// No description provided for @stepNotifDetail.
  ///
  /// In tr, this message translates to:
  /// **'Eşik yalnızca eşik geldiğinde yazar. Günde en fazla iki bildirim.'**
  String get stepNotifDetail;

  /// No description provided for @allow.
  ///
  /// In tr, this message translates to:
  /// **'İzin ver'**
  String get allow;

  /// No description provided for @stepBatteryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arka planda çalışmasına izin ver'**
  String get stepBatteryTitle;

  /// No description provided for @stepBatteryDetail.
  ///
  /// In tr, this message translates to:
  /// **'Samsung pil tasarrufu Eşik’i uyutabilir. Açılan pencerede “İzin ver”e dokun. Pencere yerine ayarlar açılırsa Pil’e dokun ve “Kısıtlamasız”ı seç.'**
  String get stepBatteryDetail;

  /// No description provided for @stepUsageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım erişimi ver'**
  String get stepUsageTitle;

  /// No description provided for @stepUsageDetail.
  ///
  /// In tr, this message translates to:
  /// **'Instagram’ın kapandığını anlamak için hangi uygulamanın açık olduğunu görmemiz gerekir.'**
  String get stepUsageDetail;

  /// No description provided for @stepUsageAction.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım erişimini aç'**
  String get stepUsageAction;

  /// No description provided for @stepNoPermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ek izin gerekmez'**
  String get stepNoPermissionTitle;

  /// No description provided for @stepSilencedDetail.
  ///
  /// In tr, this message translates to:
  /// **'Akşam aralığında telefonun sesini bir kademe kısınca (sesliden titreşime, titreşimden sessize) ya da Rahatsız Etmeyin açılınca Eşik bunu fark eder.'**
  String get stepSilencedDetail;

  /// No description provided for @stepUnsilencedDetail.
  ///
  /// In tr, this message translates to:
  /// **'Sabah aralığında telefonun sesini bir kademe açınca (sessizden titreşime, titreşimden sesliye) ya da Rahatsız Etmeyin kapanınca Eşik bunu fark eder.'**
  String get stepUnsilencedDetail;

  /// No description provided for @gotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get gotIt;

  /// No description provided for @stepNotifAccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim erişimi ver'**
  String get stepNotifAccessTitle;

  /// No description provided for @stepNotifAccessDetail.
  ///
  /// In tr, this message translates to:
  /// **'Uyku modu açıldığında haberimiz olsun diye. Bildirimlerinin içeriği okunmaz.'**
  String get stepNotifAccessDetail;

  /// No description provided for @stepNotifAccessAction.
  ///
  /// In tr, this message translates to:
  /// **'Erişimi aç'**
  String get stepNotifAccessAction;

  /// No description provided for @stepWifiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mobil veri açık kalsın'**
  String get stepWifiTitle;

  /// No description provided for @stepWifiDetail.
  ///
  /// In tr, this message translates to:
  /// **'Sabah aralığında evin Wi‑Fi’ına bağlıyken Eşik hazırda bekler; bağlantı kopup telefon mobil veriye geçince hatırlatır. Wi‑Fi adı okunmaz, konum izni gerekmez.'**
  String get stepWifiDetail;

  /// No description provided for @stepNfcTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etiketi hazırla'**
  String get stepNfcTitle;

  /// No description provided for @stepNfcDetail.
  ///
  /// In tr, this message translates to:
  /// **'Boş bir NFC etiketini telefonun arkasına tut; Eşik etikete kendi bağlantısını yazar.'**
  String get stepNfcDetail;

  /// No description provided for @stepNfcAction.
  ///
  /// In tr, this message translates to:
  /// **'Etiketi yaz'**
  String get stepNfcAction;

  /// No description provided for @stepAlarmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sabah alarmın kurulu olsun'**
  String get stepAlarmTitle;

  /// No description provided for @stepAlarmDetail.
  ///
  /// In tr, this message translates to:
  /// **'Ek izin gerekmez. Saat uygulamasındaki alarm çalıp kapandığında Eşik bunu fark eder. Ertelersen son çalışı bekler.'**
  String get stepAlarmDetail;

  /// No description provided for @stepTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dene'**
  String get stepTestTitle;

  /// No description provided for @stepTestCharging.
  ///
  /// In tr, this message translates to:
  /// **'Önce deneme bildirimi. Gerçeği, seçtiğin saat aralığında telefonu şarja taktıktan sonra birkaç dakika içinde gelir.'**
  String get stepTestCharging;

  /// No description provided for @stepTestWifi.
  ///
  /// In tr, this message translates to:
  /// **'Önce deneme bildirimi. Gerçeği, sabah aralığında Wi‑Fi’ı kapatıp mobil veriye geçince gelir.'**
  String get stepTestWifi;

  /// No description provided for @stepTestAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Önce deneme bildirimi. Gerçeği, sabah aralığında çalan bir alarmı kapattıktan sonra gelir.'**
  String get stepTestAlarm;

  /// No description provided for @stepTestSilenced.
  ///
  /// In tr, this message translates to:
  /// **'Önce deneme bildirimi. Gerçeği, akşam aralığında telefonun sesini kıstığında birkaç saniye içinde gelir.'**
  String get stepTestSilenced;

  /// No description provided for @stepTestUnsilenced.
  ///
  /// In tr, this message translates to:
  /// **'Önce deneme bildirimi. Gerçeği, sabah aralığında telefonun sesini açtığında birkaç saniye içinde gelir.'**
  String get stepTestUnsilenced;

  /// No description provided for @stepTestNfc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamadan çık, kilidi açık telefonu etikete dokundur. Kontrol ekranı açılmalı.'**
  String get stepTestNfc;

  /// No description provided for @stepTestMany.
  ///
  /// In tr, this message translates to:
  /// **'Deneme bildirimi gönderelim. Gerçeğini, seçtiğin davranışlardan o gün ilk olanı gönderir.'**
  String get stepTestMany;

  /// No description provided for @stepTestOther.
  ///
  /// In tr, this message translates to:
  /// **'Deneme bildirimi gönderelim; gerçek tetikleyici de aynı şekilde gelecek.'**
  String get stepTestOther;

  /// No description provided for @finish.
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get finish;

  /// No description provided for @sendTest.
  ///
  /// In tr, this message translates to:
  /// **'Deneme bildirimi gönder'**
  String get sendTest;

  /// No description provided for @notifDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi. İstersen ayarlardan açabilirsin.'**
  String get notifDenied;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @testNotSent.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim gönderilemedi: bildirim izni kapalı.'**
  String get testNotSent;

  /// No description provided for @continueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueLabel;

  /// No description provided for @openInSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlardan aç'**
  String get openInSettings;

  /// No description provided for @turnOnNfc.
  ///
  /// In tr, this message translates to:
  /// **'NFC’yi aç'**
  String get turnOnNfc;

  /// No description provided for @openClock.
  ///
  /// In tr, this message translates to:
  /// **'Saat uygulamasını aç'**
  String get openClock;

  /// No description provided for @detailNotifOn.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler açık. Eşik yalnızca eşik geldiğinde yazar.'**
  String get detailNotifOn;

  /// No description provided for @detailNotifBlocked.
  ///
  /// In tr, this message translates to:
  /// **'İzin verilmiş ama Eşik bildirimleri telefon ayarlarında kapalı. Açılan sayfada bildirimleri aç.'**
  String get detailNotifBlocked;

  /// No description provided for @detailBatteryOk.
  ///
  /// In tr, this message translates to:
  /// **'Eşik pil kısıtlamasından muaf; arka planda uyutulmaz.'**
  String get detailBatteryOk;

  /// No description provided for @detailNoAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Saat uygulamasında kurulu alarm yok. Sabah alarmını kur; çalıp kapandığında Eşik bunu fark eder.'**
  String get detailNoAlarm;

  /// No description provided for @detailNextAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki alarm {when}. Çalıp kapandığında Eşik bunu fark eder. Ertelersen son çalışı bekler.'**
  String detailNextAlarm(String when);

  /// No description provided for @noNfc.
  ///
  /// In tr, this message translates to:
  /// **'Bu telefonda NFC yok. Başka bir sabah tetikleyicisi seç.'**
  String get noNfc;

  /// No description provided for @detailNfcOff.
  ///
  /// In tr, this message translates to:
  /// **'NFC kapalı. Etiketi yazmak ve okumak için açık olmalı.'**
  String get detailNfcOff;

  /// No description provided for @detailTagWritten.
  ///
  /// In tr, this message translates to:
  /// **'Etiket yazıldı. İstersen yeni bir etikete yeniden yazabilirsin.'**
  String get detailTagWritten;

  /// No description provided for @tagReady.
  ///
  /// In tr, this message translates to:
  /// **'Etiket hazır. Kapının yanına yapıştırabilirsin.'**
  String get tagReady;

  /// No description provided for @nfcOffRetry.
  ///
  /// In tr, this message translates to:
  /// **'NFC kapalı. Açıp tekrar dene.'**
  String get nfcOffRetry;

  /// No description provided for @tagReadOnly.
  ///
  /// In tr, this message translates to:
  /// **'Bu etiket kilitli, üzerine yazılamıyor. Boş bir etiket dene.'**
  String get tagReadOnly;

  /// No description provided for @tagIncompatible.
  ///
  /// In tr, this message translates to:
  /// **'Bu etiket uygun değil. NTAG213 ya da benzeri bir etiket dene.'**
  String get tagIncompatible;

  /// No description provided for @tagError.
  ///
  /// In tr, this message translates to:
  /// **'Yazılamadı. Telefonu etikete biraz daha uzun tut.'**
  String get tagError;

  /// No description provided for @setupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum'**
  String get setupTitle;

  /// No description provided for @stepOf.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String stepOf(int current, int total);

  /// No description provided for @holdToTag.
  ///
  /// In tr, this message translates to:
  /// **'Etikete yaklaştır'**
  String get holdToTag;

  /// No description provided for @holdToTagDetail.
  ///
  /// In tr, this message translates to:
  /// **'Telefonun arkasını etikete değdir ve titreşimi bekle.'**
  String get holdToTagDetail;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @later.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get later;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @stepA11y.
  ///
  /// In tr, this message translates to:
  /// **'{number}. adım, {title}, {state}'**
  String stepA11y(int number, String title, String state);

  /// No description provided for @stepStateDone.
  ///
  /// In tr, this message translates to:
  /// **'tamamlandı'**
  String get stepStateDone;

  /// No description provided for @stepStateCurrent.
  ///
  /// In tr, this message translates to:
  /// **'şu anki adım'**
  String get stepStateCurrent;

  /// No description provided for @stepStateUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'sırada'**
  String get stepStateUpcoming;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @startSetup.
  ///
  /// In tr, this message translates to:
  /// **'Kuruluma başla'**
  String get startSetup;

  /// No description provided for @notNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi değil'**
  String get notNow;

  /// No description provided for @pageOf.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa {current} / {total}'**
  String pageOf(int current, int total);

  /// No description provided for @introKicker.
  ///
  /// In tr, this message translates to:
  /// **'Eşik’e hoş geldin'**
  String get introKicker;

  /// No description provided for @introTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yatmadan önce.\nKapıdan çıkmadan önce.'**
  String get introTitle;

  /// No description provided for @introBody.
  ///
  /// In tr, this message translates to:
  /// **'Günün iki eşiğinde kendi kontrol listen, tam doğru anda önünde.'**
  String get introBody;

  /// No description provided for @scenarioKicker.
  ///
  /// In tr, this message translates to:
  /// **'Örnek senaryo'**
  String get scenarioKicker;

  /// No description provided for @scenarioTitle.
  ///
  /// In tr, this message translates to:
  /// **'Saat değil, an.'**
  String get scenarioTitle;

  /// No description provided for @scenarioBody.
  ///
  /// In tr, this message translates to:
  /// **'22:30 alarmı sen dizideyken çalar. Eşik ise telefonu şarja taktığın an gelir; üç maddeye bakar, rahat uyursun.'**
  String get scenarioBody;

  /// No description provided for @calloutPlugged.
  ///
  /// In tr, this message translates to:
  /// **'Şarja taktın'**
  String get calloutPlugged;

  /// No description provided for @calloutPluggedAt.
  ///
  /// In tr, this message translates to:
  /// **'22:47 · eşik'**
  String get calloutPluggedAt;

  /// No description provided for @calloutDoor.
  ///
  /// In tr, this message translates to:
  /// **'Kapı'**
  String get calloutDoor;

  /// No description provided for @calloutLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get calloutLocked;

  /// No description provided for @calloutIron.
  ///
  /// In tr, this message translates to:
  /// **'Ütü'**
  String get calloutIron;

  /// No description provided for @calloutUnplugged.
  ///
  /// In tr, this message translates to:
  /// **'Fiş çekildi'**
  String get calloutUnplugged;

  /// No description provided for @notifyKicker.
  ///
  /// In tr, this message translates to:
  /// **'Son adım'**
  String get notifyKicker;

  /// No description provided for @notifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğru anda\nhaber verelim.'**
  String get notifyTitle;

  /// No description provided for @notifyBody.
  ///
  /// In tr, this message translates to:
  /// **'Sadece eşik geldiğinde yazarız. Günde en fazla iki bildirim, reklam yok.'**
  String get notifyBody;

  /// No description provided for @eveningThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Akşam eşiği'**
  String get eveningThreshold;

  /// No description provided for @morningThreshold.
  ///
  /// In tr, this message translates to:
  /// **'Sabah eşiği'**
  String get morningThreshold;

  /// No description provided for @now.
  ///
  /// In tr, this message translates to:
  /// **'şimdi'**
  String get now;

  /// No description provided for @notifyPreview.
  ///
  /// In tr, this message translates to:
  /// **'Şarja taktın. Ütü, yapılacaklar, kapı: 3 madde.'**
  String get notifyPreview;

  /// No description provided for @tabToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get tabToday;

  /// No description provided for @tabList.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get tabList;

  /// No description provided for @tabHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get tabSettings;

  /// No description provided for @checkNow.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol et'**
  String get checkNow;

  /// No description provided for @evening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get evening;

  /// No description provided for @morning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get morning;

  /// No description provided for @startupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Eşik başlatılamadı'**
  String get startupFailed;

  /// No description provided for @startupTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar zamanında yüklenemedi.'**
  String get startupTimeout;

  /// No description provided for @startupHelp.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdaki metni kopyalayıp geliştiriciye gönderebilirsin.'**
  String get startupHelp;

  /// No description provided for @copyError.
  ///
  /// In tr, this message translates to:
  /// **'Hatayı kopyala'**
  String get copyError;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get languageSystem;

  /// No description provided for @plusName.
  ///
  /// In tr, this message translates to:
  /// **'Eşik Plus'**
  String get plusName;

  /// No description provided for @plusTagline.
  ///
  /// In tr, this message translates to:
  /// **'Eşiklerini tam sana göre kur.'**
  String get plusTagline;

  /// No description provided for @plusFeatureMulti.
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla tetikleyici'**
  String get plusFeatureMulti;

  /// No description provided for @plusFeatureWifiNfc.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz mod, Wi‑Fi ve NFC etiketi'**
  String get plusFeatureWifiNfc;

  /// No description provided for @plusFeatureDays.
  ///
  /// In tr, this message translates to:
  /// **'Çalışacağı günleri seçme'**
  String get plusFeatureDays;

  /// No description provided for @plusFeatureSilent.
  ///
  /// In tr, this message translates to:
  /// **'Sessizdeyken titret ya da çal'**
  String get plusFeatureSilent;

  /// No description provided for @plusFeatureHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş ve istatistikler'**
  String get plusFeatureHistory;

  /// No description provided for @plusOnce.
  ///
  /// In tr, this message translates to:
  /// **'Tek seferlik ödeme, abonelik yok. Reklam yok.'**
  String get plusOnce;

  /// No description provided for @plusBuy.
  ///
  /// In tr, this message translates to:
  /// **'Ömür boyu · {price}'**
  String plusBuy(String price);

  /// No description provided for @plusBuyNoPrice.
  ///
  /// In tr, this message translates to:
  /// **'Plus’ı al'**
  String get plusBuyNoPrice;

  /// No description provided for @plusRestore.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımı geri yükle'**
  String get plusRestore;

  /// No description provided for @plusUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Google Play’e şu an ulaşılamıyor. Biraz sonra tekrar dene.'**
  String get plusUnavailable;

  /// No description provided for @plusPending.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bekleniyor…'**
  String get plusPending;

  /// No description provided for @plusThanks.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler! Plus artık sende.'**
  String get plusThanks;

  /// No description provided for @plusOwned.
  ///
  /// In tr, this message translates to:
  /// **'Plus sende'**
  String get plusOwned;

  /// No description provided for @plusTrialLeft.
  ///
  /// In tr, this message translates to:
  /// **'Deneme: {days} gün kaldı'**
  String plusTrialLeft(int days);

  /// No description provided for @plusFree.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz sürüm'**
  String get plusFree;

  /// No description provided for @plusTrialNote.
  ///
  /// In tr, this message translates to:
  /// **'İlk {days} gün bütün Plus özellikleri açık.'**
  String plusTrialNote(int days);

  /// No description provided for @plusMultiHint.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz mod, Wi‑Fi, NFC ve birden fazla tetikleyici Plus ile.'**
  String get plusMultiHint;

  /// No description provided for @plusTrialEnding.
  ///
  /// In tr, this message translates to:
  /// **'Plus denemesinin son {days} günü'**
  String plusTrialEnding(int days);

  /// No description provided for @plusTrialEndingBody.
  ///
  /// In tr, this message translates to:
  /// **'Sonra her modda tek tetikleyiciyle devam eder.'**
  String get plusTrialEndingBody;

  /// No description provided for @plusHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Plus ile'**
  String get plusHistoryTitle;

  /// No description provided for @plusHistoryBody.
  ///
  /// In tr, this message translates to:
  /// **'Hangi akşam ve sabah kontrol yaptığını, saatlerini ve ortalamanı gör.'**
  String get plusHistoryBody;

  /// No description provided for @seePlus.
  ///
  /// In tr, this message translates to:
  /// **'Plus’a bak'**
  String get seePlus;

  /// No description provided for @oneByOne.
  ///
  /// In tr, this message translates to:
  /// **'Tek tek bak'**
  String get oneByOne;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
