import AppIntents

// iOS uygulamaların şarja takmayı, alarmın durmasını ya da Wi‑Fi'dan çıkmayı
// görmesine izin vermiyor; Kestirmeler'in otomasyonları görüyor. Kullanıcı
// "Şarj Cihazı → Bağlandı" gibi bir otomasyona aşağıdaki eylemlerden birini
// ekler; eylem uygulamayı açmadan EsikCore.fire ile bildirimi gönderir.
//
// Eylem adları kurulum rehberindeki metinlerle (lib/l10n, shortcut*) aynı
// olmalı; çeviriler Runner/*.lproj/Localizable.strings'te.

@available(iOS 16.0, *)
struct ChargingIntent: AppIntent {
  static var title: LocalizedStringResource = "Plugged in"
  static var description = IntentDescription("Eşik: the phone was plugged in.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "charging")
    return .result()
  }
}

@available(iOS 16.0, *)
struct UnpluggedIntent: AppIntent {
  static var title: LocalizedStringResource = "Unplugged"
  static var description = IntentDescription("Eşik: the phone was unplugged.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "unplugged")
    return .result()
  }
}

@available(iOS 16.0, *)
struct AlarmStoppedIntent: AppIntent {
  static var title: LocalizedStringResource = "Alarm stopped"
  static var description = IntentDescription("Eşik: the alarm was stopped.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "alarmStopped")
    return .result()
  }
}

@available(iOS 16.0, *)
struct LeftHomeIntent: AppIntent {
  static var title: LocalizedStringResource = "Left home"
  static var description = IntentDescription("Eşik: you left your home Wi‑Fi.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "leftHomeWifi")
    return .result()
  }
}

@available(iOS 16.0, *)
struct DoorTagIntent: AppIntent {
  static var title: LocalizedStringResource = "Door tag"
  static var description = IntentDescription("Eşik: you tapped the NFC tag on your door.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "nfcTag")
    return .result()
  }
}

@available(iOS 16.0, *)
struct SleepStartedIntent: AppIntent {
  static var title: LocalizedStringResource = "Sleep started"
  static var description = IntentDescription("Eşik: Sleep Focus started.")
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await EsikCore.shared.fire(kind: "sleepMode")
    return .result()
  }
}
