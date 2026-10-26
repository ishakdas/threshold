// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get triggerChargingTitle => 'Şarja takınca';

  @override
  String get triggerChargingSubtitle => 'Yatağın yanında';

  @override
  String get triggerChargingWhen => 'Telefonu şarja taktığında';

  @override
  String get triggerSilencedTitle => 'Sessize alınca';

  @override
  String get triggerSilencedSubtitle => 'Sesi kısınca';

  @override
  String get triggerSilencedWhen => 'Telefonu sessize aldığında';

  @override
  String get triggerAppClosedTitle => 'Uygulama kapanınca';

  @override
  String get triggerAppClosedSubtitle => 'Instagram';

  @override
  String get triggerAppClosedWhen => 'Instagram’ı kapattığında';

  @override
  String get triggerSleepModeTitle => 'Uyku modu';

  @override
  String get triggerSleepModeSubtitle => 'Açılınca';

  @override
  String get triggerSleepModeWhen => 'Uyku modu açıldığında';

  @override
  String get triggerAirplaneModeTitle => 'Uçak modu';

  @override
  String get triggerAirplaneModeSubtitle => 'Açılınca';

  @override
  String get triggerAirplaneModeWhen => 'Uçak modunu açtığında';

  @override
  String get triggerAlarmStoppedTitle => 'Alarmı durdurunca';

  @override
  String get triggerAlarmStoppedSubtitle => 'Sabah alarmı';

  @override
  String get triggerAlarmStoppedWhen => 'Alarmı durdurduğunda';

  @override
  String get triggerUnsilencedTitle => 'Sessizden çıkarınca';

  @override
  String get triggerUnsilencedSubtitle => 'Sesi açınca';

  @override
  String get triggerUnsilencedWhen => 'Telefonu sessizden çıkardığında';

  @override
  String get triggerUnpluggedTitle => 'Şarjdan çıkarınca';

  @override
  String get triggerUnpluggedSubtitle => 'Telefonu alınca';

  @override
  String get triggerUnpluggedWhen => 'Telefonu şarjdan çıkardığında';

  @override
  String get triggerLeftHomeWifiTitle => 'Ev Wi‑Fi’ından çıkınca';

  @override
  String get triggerLeftHomeWifiSubtitle => 'Evden ayrılınca';

  @override
  String get triggerLeftHomeWifiWhen => 'Ev Wi‑Fi’ından ayrıldığında';

  @override
  String get triggerNfcTagTitle => 'Kapıdaki etikete dokununca';

  @override
  String get triggerNfcTagSubtitle => 'NFC etiketi';

  @override
  String get triggerNfcTagWhen => 'Kapıdaki etikete dokunduğunda';

  @override
  String triggersOr(String a, String b) {
    return '$a ya da $b';
  }

  @override
  String triggersMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String triggersAnyOf(int count) {
    return 'Seçtiğin $count davranıştan biri olduğunda';
  }

  @override
  String get triggersBackupOnly => 'Yalnızca yedek saat';

  @override
  String get silentAlertQuiet => 'Kapalı';

  @override
  String get silentAlertVibrate => 'Titret';

  @override
  String get silentAlertRing => 'Çal';

  @override
  String get weekdayLetters => 'P,S,Ç,P,C,C,P';

  @override
  String get today => 'bugün';

  @override
  String get tomorrow => 'yarın';

  @override
  String get yesterday => 'dün';

  @override
  String dayAndTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get defaultEveningIron => 'Ütünün fişini çektim mi?';

  @override
  String get defaultEveningTodo => 'Yapılacaklar listemi tikledim mi?';

  @override
  String get defaultEveningLock => 'Kapıyı kilitledim mi?';

  @override
  String get defaultMorningCharger => 'Çantama şarj aletini koydum mu?';

  @override
  String get defaultMorningNotes => 'Akşamdan aldığım notlara baktım mı?';

  @override
  String get defaultMorningKeys => 'Anahtar ve cüzdan yanımda mı?';

  @override
  String get checkTitleEvening => 'Akşam kontrolü';

  @override
  String get checkTitleMorning => 'Sabah kontrolü';

  @override
  String checkProgressA11y(int done, int total) {
    return '$done / $total tamamlandı';
  }

  @override
  String get checkDoneLabel => 'tamamlandı';

  @override
  String get checkTapHint => 'Maddeye dokun, tik at';

  @override
  String get checkSnooze => '10 dk sonra';

  @override
  String get allDone => 'Hepsi tamam';

  @override
  String checkDoneAt(String title, String time) {
    return '$title · $time';
  }

  @override
  String get checkDoneEvening => 'İçin rahat. İyi geceler.';

  @override
  String get checkDoneMorning => 'Hazırsın. İyi günler.';

  @override
  String get undo => 'Geri al';

  @override
  String get close => 'Kapat';

  @override
  String get iconIron => 'Ütü';

  @override
  String get iconPlug => 'Priz';

  @override
  String get iconFlame => 'Ocak';

  @override
  String get iconLock => 'Kilit';

  @override
  String get iconKey => 'Anahtar';

  @override
  String get iconBag => 'Çanta';

  @override
  String get iconWallet => 'Cüzdan';

  @override
  String get iconBulb => 'Lamba';

  @override
  String get iconPill => 'İlaç';

  @override
  String get iconNotes => 'Not';

  @override
  String get iconChecklist => 'Liste';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get historyLast14 => 'Son 14 gün';

  @override
  String get historyActivity => 'Eşik etkinliği';

  @override
  String historyRange(int from, int to, String month) {
    return '$from–$to $month';
  }

  @override
  String get historyEmpty => 'Henüz kayıt yok';

  @override
  String historyScoreA11y(int total, int done) {
    return '$total eşikten $done tanesi tamamlandı';
  }

  @override
  String historyPercent(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String get historyFirstSoon => 'İlk eşiğin yakında';

  @override
  String get historyGreat => 'Eşiği geçtin';

  @override
  String get historyHalfway => 'Yolun yarısındasın';

  @override
  String get historyNewDay => 'Her gün yeni bir eşik';

  @override
  String get historyGridA11y => 'Akşam ve sabah kontrolleri, son iki hafta';

  @override
  String get outcomeDone => 'Tamamlandı';

  @override
  String get outcomeViaBackup => 'Yedek bildirimle';

  @override
  String get outcomeMissed => 'Atlandı';

  @override
  String get outcomeNotTracked => 'Kayıt yok';

  @override
  String get outcomeOff => 'İzin günü';

  @override
  String get historyAverageEvening => 'Ortalama akşam eşiği';

  @override
  String get historyEveningTrigger => 'Akşam tetikleyicisi';

  @override
  String historyEarliest(String time) {
    return 'En erken $time';
  }

  @override
  String historyLatest(String time) {
    return 'En geç $time';
  }

  @override
  String get appName => 'Eşik';

  @override
  String todayDoneAt(String time) {
    return 'Tamamlandı · $time';
  }

  @override
  String todayContinue(int count) {
    return 'Devam et · $count madde kaldı';
  }

  @override
  String get todayCheckNow => 'Şimdi kontrol et';

  @override
  String get todayThresholdEvening => 'Bu akşamki eşiğin';

  @override
  String get todayThresholdMorning => 'Bu sabahki eşiğin';

  @override
  String get todayOffDay =>
      'Bugün izin günü; Eşik hatırlatmaz. İstersen yine de kontrol edebilirsin.';

  @override
  String todayCardBody(String when, int count) {
    return '$when $count maddelik kontrolün önüne gelir.';
  }

  @override
  String todayItemsProgress(int count, int done) {
    return '$count madde · $done/$count';
  }

  @override
  String summaryEveningDoneAt(String time) {
    return 'Bu akşam $time tamam';
  }

  @override
  String summaryMorningDoneAt(String time) {
    return 'Bu sabah $time tamam';
  }

  @override
  String get summaryMorningNotDone => 'Bu sabah yapılmadı';

  @override
  String get summaryMorningPartial => 'Bu sabah yarım kaldı';

  @override
  String summaryLastNightDoneAt(String time) {
    return 'Dün akşam $time tamam';
  }

  @override
  String get summaryLastNightMissed => 'Dün akşam atlandı';

  @override
  String get summaryLastNightNoRecord => 'Dün akşam kayıt yok';

  @override
  String get summaryLastNightOff => 'Dün akşam izin günüydü';

  @override
  String get summaryGoToEvening => 'Akşam eşiğine geç';

  @override
  String get summaryGoToMorning => 'Sabah eşiğine geç';

  @override
  String summaryEveningLine(String trigger) {
    return 'Akşam eşiği · $trigger';
  }

  @override
  String summaryMorningLine(String trigger) {
    return 'Sabah eşiği · $trigger';
  }

  @override
  String summaryLast7A11y(int done) {
    return 'Son 7 gün: $done tamamlandı';
  }

  @override
  String get modeEveningSwitch => 'Akşam modu. Sabaha geç';

  @override
  String get modeMorningSwitch => 'Sabah modu. Akşama geç';

  @override
  String get modeEvening => 'Akşam modu';

  @override
  String get modeMorning => 'Sabah modu';

  @override
  String setupCardMore(String issue, int count) {
    return '$issue · $count eksik';
  }

  @override
  String setupCardA11y(String detail) {
    return '$detail. Kurulumu tamamla';
  }

  @override
  String get setupFinish => 'Kurulumu tamamla';

  @override
  String dayStripA11y(int day, String weekday) {
    return '$day, $weekday';
  }

  @override
  String dayStripDoneA11y(int day, String weekday, int count) {
    return '$day, $weekday, $count eşik tamamlandı';
  }

  @override
  String get issueNotifications => 'Bildirimler kapalı';

  @override
  String get issueBattery => 'Pil kısıtlaması açık';

  @override
  String get issueNfcOff => 'NFC kapalı';

  @override
  String get issueNfcTag => 'Etiket henüz yazılmadı';

  @override
  String get issueNoAlarm => 'Kurulu alarm yok';

  @override
  String get windowStartHelp => 'Aralığın başlangıcı';

  @override
  String get windowEndHelp => 'Aralığın bitişi';

  @override
  String get backupTimeHelp => 'Yedek bildirim saati';

  @override
  String get settingsTitle => 'Eşiklerim';

  @override
  String get beforeBed => 'Yatmadan önce';

  @override
  String get beforeLeaving => 'Evden çıkmadan önce';

  @override
  String get pickStartTime => 'Başlangıç saatini seç';

  @override
  String get pickEndTime => 'Bitiş saatini seç';

  @override
  String get anyTime => 'Her saatte';

  @override
  String get onlyInWindow => 'Sadece bu aralıkta';

  @override
  String get windowOff => 'Aralık kapalı';

  @override
  String get whatTriggers => 'Ne olunca?';

  @override
  String get firstOneWins => 'Hangisi önce olursa o gün o hatırlatır.';

  @override
  String get pickSeveral =>
      'Birden fazla seçebilirsin; hangisi önce olursa o hatırlatır.';

  @override
  String get whichDays => 'Hangi günler?';

  @override
  String get changeBackupTime => 'Yedek saati değiştir';

  @override
  String backupRow(String time) {
    return 'Hiçbiri olmazsa $time hatırlat';
  }

  @override
  String get backupReminder => 'Yedek bildirim';

  @override
  String get setupCheck => 'Kurulumu kontrol et';

  @override
  String setupFinishMissing(int count) {
    return 'Kurulumu tamamla · $count eksik';
  }

  @override
  String get autoSaved => 'Değişiklikler kendiliğinden kaydedilir';

  @override
  String timeButtonA11y(String label, String time) {
    return '$label, şu an $time';
  }

  @override
  String tileA11y(String title, String subtitle) {
    return '$title, $subtitle';
  }

  @override
  String get comingSoon => 'Yakında';

  @override
  String get comingSoonLower => 'yakında';

  @override
  String get selected => 'Seçili';

  @override
  String get whenSilent => 'Telefon sessizdeyken';

  @override
  String get silentQuietHint => 'Bildirim telefonun ses ayarına uyar.';

  @override
  String get silentVibrateHint =>
      'Sessizde ya da Rahatsız Etmeyin açıkken de titreşir.';

  @override
  String get silentMutedHint =>
      'Alarm sesi kapalı, bu yüzden duyulmaz. Ses tuşlarıyla alarm sesini aç.';

  @override
  String get silentRingHint =>
      'Sessizde de alarm sesi düzeyinde çalar ve titreşir.';

  @override
  String waitFrom(String when, String text) {
    return '$when itibarıyla $text';
  }

  @override
  String get waitCharging => 'şarja takılması bekleniyor';

  @override
  String get waitWifi => 'Wi‑Fi bağlantısı bekleniyor';

  @override
  String get waitLeaving => 'Wi‑Fi’dan çıkış bekleniyor';

  @override
  String waitAlarm(String when) {
    return 'sıradaki alarm $when';
  }

  @override
  String get waitAlarmSettling => 'alarm çaldı, kapanması bekleniyor';

  @override
  String get waitNoAlarm => 'kurulu alarm yok';

  @override
  String get waitSilence => 'sesin kısılması bekleniyor';

  @override
  String get waitAlreadySilent =>
      'telefon zaten tamamen sessizde; önce sesi biraz aç';

  @override
  String get waitUnsilence => 'sesin açılması bekleniyor';

  @override
  String get waitNotSilent =>
      'zil zaten açık; gece sesi kısarsan sabah çalışır';

  @override
  String get waitNone => 'kurulu değil';

  @override
  String statusLine(String text) {
    return 'Durum: $text';
  }

  @override
  String statusLineKind(String kind, String text) {
    return '$kind: $text';
  }

  @override
  String get hintCharging =>
      'Şarja taktıktan sonra birkaç dakika içinde gelir.';

  @override
  String get hintAlarm =>
      'Saat uygulamasındaki alarm çalıp kapanınca gelir. Ertelersen bekler.';

  @override
  String get hintWifi =>
      'Wi‑Fi’dan kopup mobil veriye geçince gelir; mobil veri açık olmalı.';

  @override
  String get hintSilenced =>
      'Ses bir kademe kısılınca gelir: sesliden titreşime, titreşimden sessize ya da Rahatsız Etmeyin açılınca.';

  @override
  String get hintUnsilenced =>
      'Ses bir kademe açılınca gelir: sessizden titreşime, titreşimden sesliye ya da Rahatsız Etmeyin kapanınca.';

  @override
  String get hintNfc => 'Etikete dokununca kontrol ekranı açılır.';

  @override
  String get hintSoon =>
      'Bu tetikleyici yakında. O zamana kadar yedek saat hatırlatır.';

  @override
  String get backupOff => 'Yedek bildirim kapalı';

  @override
  String backupNext(String when) {
    return 'Sıradaki yedek: $when';
  }

  @override
  String backupLast(String when, String outcome) {
    return 'Son yedek: $when $outcome';
  }

  @override
  String triggerLast(String when, String outcome) {
    return 'Son tetik: $when $outcome';
  }

  @override
  String triggerLastKind(String kind, String when, String outcome) {
    return 'Son tetik ($kind): $when $outcome';
  }

  @override
  String get outcomeShown => 'gönderildi';

  @override
  String get outcomeAlreadyDone => 'atlandı: kontrol zaten yapılmıştı';

  @override
  String get outcomeAlreadyNotified => 'atlandı: o gün bildirim zaten gelmişti';

  @override
  String get outcomeNoPermission => 'gönderilemedi: bildirim izni kapalı';

  @override
  String get outcomeDisabled => 'atlandı: yedek kapalı';

  @override
  String get outcomeOffDay => 'atlandı: izin günü';

  @override
  String rangeA11y(String start, String end) {
    return 'Saat aralığı $start ile $end arası';
  }

  @override
  String itemDeleted(String title) {
    return '“$title” silindi';
  }

  @override
  String get checklistTitle => 'Kontrol listem';

  @override
  String get checklistEmpty =>
      'Bu listede henüz madde yok. Aşağıdan ekleyebilirsin.';

  @override
  String get delete => 'Sil';

  @override
  String get checklistHint => 'Basılı tut ve sürükle · silmek için sola kaydır';

  @override
  String get newItem => 'Yeni madde';

  @override
  String get pickIcon => 'İkon seç';

  @override
  String get dragToReorder => 'Sürükleyerek sırala';

  @override
  String get newItemHint => 'Örn. Ocağı kapattım mı?';

  @override
  String get add => 'Ekle';

  @override
  String get stepNotifTitle => 'Bildirimlere izin ver';

  @override
  String get stepNotifDetail =>
      'Eşik yalnızca eşik geldiğinde yazar. Günde en fazla iki bildirim.';

  @override
  String get allow => 'İzin ver';

  @override
  String get stepBatteryTitle => 'Arka planda çalışmasına izin ver';

  @override
  String get stepBatteryDetail =>
      'Samsung pil tasarrufu Eşik’i uyutabilir. Açılan pencerede “İzin ver”e dokun. Pencere yerine ayarlar açılırsa Pil’e dokun ve “Kısıtlamasız”ı seç.';

  @override
  String get stepUsageTitle => 'Kullanım erişimi ver';

  @override
  String get stepUsageDetail =>
      'Instagram’ın kapandığını anlamak için hangi uygulamanın açık olduğunu görmemiz gerekir.';

  @override
  String get stepUsageAction => 'Kullanım erişimini aç';

  @override
  String get stepNoPermissionTitle => 'Ek izin gerekmez';

  @override
  String get stepSilencedDetail =>
      'Akşam aralığında telefonun sesini bir kademe kısınca (sesliden titreşime, titreşimden sessize) ya da Rahatsız Etmeyin açılınca Eşik bunu fark eder.';

  @override
  String get stepUnsilencedDetail =>
      'Sabah aralığında telefonun sesini bir kademe açınca (sessizden titreşime, titreşimden sesliye) ya da Rahatsız Etmeyin kapanınca Eşik bunu fark eder.';

  @override
  String get gotIt => 'Anladım';

  @override
  String get stepNotifAccessTitle => 'Bildirim erişimi ver';

  @override
  String get stepNotifAccessDetail =>
      'Uyku modu açıldığında haberimiz olsun diye. Bildirimlerinin içeriği okunmaz.';

  @override
  String get stepNotifAccessAction => 'Erişimi aç';

  @override
  String get stepWifiTitle => 'Mobil veri açık kalsın';

  @override
  String get stepWifiDetail =>
      'Sabah aralığında evin Wi‑Fi’ına bağlıyken Eşik hazırda bekler; bağlantı kopup telefon mobil veriye geçince hatırlatır. Wi‑Fi adı okunmaz, konum izni gerekmez.';

  @override
  String get stepNfcTitle => 'Etiketi hazırla';

  @override
  String get stepNfcDetail =>
      'Boş bir NFC etiketini telefonun arkasına tut; Eşik etikete kendi bağlantısını yazar.';

  @override
  String get stepNfcAction => 'Etiketi yaz';

  @override
  String get stepAlarmTitle => 'Sabah alarmın kurulu olsun';

  @override
  String get stepAlarmDetail =>
      'Ek izin gerekmez. Saat uygulamasındaki alarm çalıp kapandığında Eşik bunu fark eder. Ertelersen son çalışı bekler.';

  @override
  String get stepTestTitle => 'Dene';

  @override
  String get stepTestCharging =>
      'Önce deneme bildirimi. Gerçeği, seçtiğin saat aralığında telefonu şarja taktıktan sonra birkaç dakika içinde gelir.';

  @override
  String get stepTestWifi =>
      'Önce deneme bildirimi. Gerçeği, sabah aralığında Wi‑Fi’ı kapatıp mobil veriye geçince gelir.';

  @override
  String get stepTestAlarm =>
      'Önce deneme bildirimi. Gerçeği, sabah aralığında çalan bir alarmı kapattıktan sonra gelir.';

  @override
  String get stepTestSilenced =>
      'Önce deneme bildirimi. Gerçeği, akşam aralığında telefonun sesini kıstığında birkaç saniye içinde gelir.';

  @override
  String get stepTestUnsilenced =>
      'Önce deneme bildirimi. Gerçeği, sabah aralığında telefonun sesini açtığında birkaç saniye içinde gelir.';

  @override
  String get stepTestNfc =>
      'Uygulamadan çık, kilidi açık telefonu etikete dokundur. Kontrol ekranı açılmalı.';

  @override
  String get stepTestMany =>
      'Deneme bildirimi gönderelim. Gerçeğini, seçtiğin davranışlardan o gün ilk olanı gönderir.';

  @override
  String get stepTestOther =>
      'Deneme bildirimi gönderelim; gerçek tetikleyici de aynı şekilde gelecek.';

  @override
  String get finish => 'Bitir';

  @override
  String get sendTest => 'Deneme bildirimi gönder';

  @override
  String get notifDenied =>
      'Bildirim izni verilmedi. İstersen ayarlardan açabilirsin.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get testNotSent => 'Bildirim gönderilemedi: bildirim izni kapalı.';

  @override
  String get continueLabel => 'Devam';

  @override
  String get openInSettings => 'Ayarlardan aç';

  @override
  String get turnOnNfc => 'NFC’yi aç';

  @override
  String get openClock => 'Saat uygulamasını aç';

  @override
  String get detailNotifOn =>
      'Bildirimler açık. Eşik yalnızca eşik geldiğinde yazar.';

  @override
  String get detailNotifBlocked =>
      'İzin verilmiş ama Eşik bildirimleri telefon ayarlarında kapalı. Açılan sayfada bildirimleri aç.';

  @override
  String get detailBatteryOk =>
      'Eşik pil kısıtlamasından muaf; arka planda uyutulmaz.';

  @override
  String get detailNoAlarm =>
      'Saat uygulamasında kurulu alarm yok. Sabah alarmını kur; çalıp kapandığında Eşik bunu fark eder.';

  @override
  String detailNextAlarm(String when) {
    return 'Sıradaki alarm $when. Çalıp kapandığında Eşik bunu fark eder. Ertelersen son çalışı bekler.';
  }

  @override
  String get noNfc =>
      'Bu telefonda NFC yok. Başka bir sabah tetikleyicisi seç.';

  @override
  String get detailNfcOff =>
      'NFC kapalı. Etiketi yazmak ve okumak için açık olmalı.';

  @override
  String get detailTagWritten =>
      'Etiket yazıldı. İstersen yeni bir etikete yeniden yazabilirsin.';

  @override
  String get tagReady => 'Etiket hazır. Kapının yanına yapıştırabilirsin.';

  @override
  String get nfcOffRetry => 'NFC kapalı. Açıp tekrar dene.';

  @override
  String get tagReadOnly =>
      'Bu etiket kilitli, üzerine yazılamıyor. Boş bir etiket dene.';

  @override
  String get tagIncompatible =>
      'Bu etiket uygun değil. NTAG213 ya da benzeri bir etiket dene.';

  @override
  String get tagError => 'Yazılamadı. Telefonu etikete biraz daha uzun tut.';

  @override
  String get setupTitle => 'Kurulum';

  @override
  String stepOf(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String get holdToTag => 'Etikete yaklaştır';

  @override
  String get holdToTagDetail =>
      'Telefonun arkasını etikete değdir ve titreşimi bekle.';

  @override
  String get skip => 'Atla';

  @override
  String get later => 'Sonra';

  @override
  String get cancel => 'Vazgeç';

  @override
  String stepA11y(int number, String title, String state) {
    return '$number. adım, $title, $state';
  }

  @override
  String get stepStateDone => 'tamamlandı';

  @override
  String get stepStateCurrent => 'şu anki adım';

  @override
  String get stepStateUpcoming => 'sırada';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get startSetup => 'Kuruluma başla';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String pageOf(int current, int total) {
    return 'Sayfa $current / $total';
  }

  @override
  String get introKicker => 'Eşik’e hoş geldin';

  @override
  String get introTitle => 'Yatmadan önce.\nKapıdan çıkmadan önce.';

  @override
  String get introBody =>
      'Günün iki eşiğinde kendi kontrol listen, tam doğru anda önünde.';

  @override
  String get scenarioKicker => 'Örnek senaryo';

  @override
  String get scenarioTitle => 'Saat değil, an.';

  @override
  String get scenarioBody =>
      '22:30 alarmı sen dizideyken çalar. Eşik ise telefonu şarja taktığın an gelir; üç maddeye bakar, rahat uyursun.';

  @override
  String get calloutPlugged => 'Şarja taktın';

  @override
  String get calloutPluggedAt => '22:47 · eşik';

  @override
  String get calloutDoor => 'Kapı';

  @override
  String get calloutLocked => 'Kilitli';

  @override
  String get calloutIron => 'Ütü';

  @override
  String get calloutUnplugged => 'Fiş çekildi';

  @override
  String get notifyKicker => 'Son adım';

  @override
  String get notifyTitle => 'Doğru anda\nhaber verelim.';

  @override
  String get notifyBody =>
      'Sadece eşik geldiğinde yazarız. Günde en fazla iki bildirim, reklam yok.';

  @override
  String get eveningThreshold => 'Akşam eşiği';

  @override
  String get morningThreshold => 'Sabah eşiği';

  @override
  String get now => 'şimdi';

  @override
  String get notifyPreview => 'Şarja taktın. Ütü, yapılacaklar, kapı: 3 madde.';

  @override
  String get tabToday => 'Bugün';

  @override
  String get tabList => 'Liste';

  @override
  String get tabHistory => 'Geçmiş';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String get checkNow => 'Kontrol et';

  @override
  String get evening => 'Akşam';

  @override
  String get morning => 'Sabah';

  @override
  String get startupFailed => 'Eşik başlatılamadı';

  @override
  String get startupTimeout => 'Ayarlar zamanında yüklenemedi.';

  @override
  String get startupHelp =>
      'Aşağıdaki metni kopyalayıp geliştiriciye gönderebilirsin.';

  @override
  String get copyError => 'Hatayı kopyala';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get plusName => 'Eşik Plus';

  @override
  String get plusTagline => 'Eşiklerini tam sana göre kur.';

  @override
  String get plusFeatureMulti => 'Birden fazla tetikleyici';

  @override
  String get plusFeatureWifiNfc => 'Sessiz mod, Wi‑Fi ve NFC etiketi';

  @override
  String get plusFeatureDays => 'Çalışacağı günleri seçme';

  @override
  String get plusFeatureSilent => 'Sessizdeyken titret ya da çal';

  @override
  String get plusFeatureHistory => 'Geçmiş ve istatistikler';

  @override
  String get plusOnce => 'Tek seferlik ödeme, abonelik yok. Reklam yok.';

  @override
  String plusBuy(String price) {
    return 'Ömür boyu · $price';
  }

  @override
  String get plusBuyNoPrice => 'Plus’ı al';

  @override
  String get plusRestore => 'Satın alımı geri yükle';

  @override
  String get plusUnavailable =>
      'Google Play’e şu an ulaşılamıyor. Biraz sonra tekrar dene.';

  @override
  String get plusPending => 'Ödeme bekleniyor…';

  @override
  String get plusThanks => 'Teşekkürler! Plus artık sende.';

  @override
  String get plusOwned => 'Plus sende';

  @override
  String plusTrialLeft(int days) {
    return 'Deneme: $days gün kaldı';
  }

  @override
  String get plusFree => 'Ücretsiz sürüm';

  @override
  String plusTrialNote(int days) {
    return 'İlk $days gün bütün Plus özellikleri açık.';
  }

  @override
  String get plusMultiHint =>
      'Sessiz mod, Wi‑Fi, NFC ve birden fazla tetikleyici Plus ile.';

  @override
  String plusTrialEnding(int days) {
    return 'Plus denemesinin son $days günü';
  }

  @override
  String get plusTrialEndingBody =>
      'Sonra her modda tek tetikleyiciyle devam eder.';

  @override
  String get plusHistoryTitle => 'Geçmiş Plus ile';

  @override
  String get plusHistoryBody =>
      'Hangi akşam ve sabah kontrol yaptığını, saatlerini ve ortalamanı gör.';

  @override
  String get seePlus => 'Plus’a bak';

  @override
  String get oneByOne => 'Tek tek bak';
}
