import Foundation
import UserNotifications

// Android'deki EsikData, EsikNotifications ve BackupScheduler'ın iOS karşılığı.
// Dart'ın shared_preferences ile yazdığı veriyi okur (UserDefaults, "flutter."
// önekiyle). Biçimler lib/data/models.dart ve lib/data/app_state.dart ile aynı
// tutulmalıdır.

/// Akşam ve sabah eşikleri. rawValue, Dart'taki DayMode adıyla aynıdır.
enum EsikMode: String, CaseIterable {
  case evening, morning

  var routeParam: String { self == .evening ? "aksam" : "sabah" }

  /// Tetikleyicinin hangi moda ait olduğu (Dart'taki TriggerKind.mode).
  static func of(kind: String) -> EsikMode {
    ["charging", "silenced", "appClosed", "sleepMode", "airplaneMode"].contains(kind)
      ? .evening : .morning
  }
}

/// Bildirimin neden gönderildiği. Kayıtta "source" olarak saklanır.
enum EsikReason: String {
  case trigger = "notification"
  case backup = "backup"
  case test = "test"
}

/// Dart'taki NotifyOutcome ile aynı adlar.
enum EsikOutcome: String {
  case shown, alreadyDone, alreadyNotified, noPermission, disabled, offDay
}

struct EsikTime {
  let hour: Int
  let minute: Int

  init(_ hour: Int, _ minute: Int) {
    self.hour = hour
    self.minute = minute
  }

  init(_ raw: Any?, fallback: EsikTime) {
    let parts = (raw as? String)?.split(separator: ":").compactMap { Int($0) } ?? []
    if parts.count == 2, (0...23).contains(parts[0]), (0...59).contains(parts[1]) {
      self.init(parts[0], parts[1])
    } else {
      self = fallback
    }
  }

  var minutes: Int { hour * 60 + minute }
}

struct EsikConfig {
  var kinds: [String]
  var days: Set<Int>
  var windowStart: EsikTime
  var windowEnd: EsikTime
  var windowEnabled: Bool
  var backupEnabled: Bool
  var backupTime: EsikTime
  var delaySeconds: Int

  /// Aralık gece yarısını aşabilir; kapalıysa günün tamamı.
  func inWindow(_ date: Date) -> Bool {
    if !windowEnabled { return true }
    let c = Calendar.current.dateComponents([.hour, .minute], from: date)
    let t = (c.hour ?? 0) * 60 + (c.minute ?? 0)
    let s = windowStart.minutes, e = windowEnd.minutes
    if s == e { return true }
    return s < e ? (t >= s && t < e) : (t >= s || t < e)
  }

  /// [day]: eşik günü; 1 = Pazartesi … 7 = Pazar.
  func activeOn(_ day: Date) -> Bool { days.contains(EsikCore.isoWeekday(day)) }
}

final class EsikCore {
  static let shared = EsikCore()

  private let defaults = UserDefaults.standard
  /// Yalnızca iOS tarafının kullandığı durum (Android'deki esik_native, esik_triggers).
  private let native = UserDefaults(suiteName: "esik_native") ?? .standard

  private static let prefix = "flutter."
  private static let freeKinds: Set<String> = ["charging", "alarmStopped"]
  private static let trialDays = 15
  static let maxDelaySeconds = 3599

  private static let fallbacks: [EsikMode: EsikConfig] = [
    .evening: EsikConfig(
      kinds: ["charging"], days: Set(1...7), windowStart: EsikTime(22, 0),
      windowEnd: EsikTime(2, 0), windowEnabled: true, backupEnabled: true,
      backupTime: EsikTime(22, 30), delaySeconds: 0),
    .morning: EsikConfig(
      kinds: ["alarmStopped"], days: Set(1...7), windowStart: EsikTime(6, 0),
      windowEnd: EsikTime(10, 0), windowEnabled: true, backupEnabled: true,
      backupTime: EsikTime(8, 15), delaySeconds: 0),
  ]

  // MARK: Gün

  private static let dayFormat: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd"
    return f
  }()

  private static let isoLocal: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return f
  }()

  /// Gün 04:00'te başlar (Dart'taki thresholdDay ile aynı); günün gece yarısı.
  static func thresholdDay(_ now: Date = Date()) -> Date {
    Calendar.current.startOfDay(for: now.addingTimeInterval(-4 * 3600))
  }

  static func dayKey(_ day: Date) -> String { dayFormat.string(from: day) }

  static func isoWeekday(_ day: Date) -> Int {
    let weekday = Calendar.current.component(.weekday, from: day)  // 1 = Pazar
    return (weekday + 5) % 7 + 1
  }

  // MARK: Okuma

  private func json(_ key: String) -> [String: Any]? {
    guard let raw = defaults.string(forKey: Self.prefix + key),
      let data = raw.data(using: .utf8)
    else { return nil }
    return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
  }

  /// Kontrol listesi: (başlık, ikon adı).
  func items(_ mode: EsikMode) -> [(id: String, title: String, icon: String)] {
    let list = json("checklist.v1")?[mode.rawValue] as? [[String: Any]] ?? []
    return list.compactMap { o in
      guard let id = o["id"] as? String, !id.isEmpty else { return nil }
      return (id, o["title"] as? String ?? "", o["icon"] as? String ?? "")
    }
  }

  private func rawConfig(_ mode: EsikMode) -> EsikConfig {
    let d = Self.fallbacks[mode]!
    guard let o = json("triggers.v1")?[mode.rawValue] as? [String: Any] else { return d }
    // Eski kayıtlarda tek "kind" alanı vardı.
    let kinds =
      (o["kinds"] as? [String]) ?? (o["kind"] as? String).map { [$0] } ?? []
    let days = Set((o["days"] as? [Int] ?? []).filter { (1...7).contains($0) })
    let delay = (o["delaySeconds"] as? Int) ?? 0
    return EsikConfig(
      kinds: kinds.filter { !$0.isEmpty }.isEmpty ? d.kinds : kinds.filter { !$0.isEmpty },
      days: days.isEmpty ? d.days : days,
      windowStart: EsikTime(o["windowStart"], fallback: d.windowStart),
      windowEnd: EsikTime(o["windowEnd"], fallback: d.windowEnd),
      windowEnabled: o["windowEnabled"] as? Bool ?? d.windowEnabled,
      backupEnabled: o["backupEnabled"] as? Bool ?? d.backupEnabled,
      backupTime: EsikTime(o["backupTime"], fallback: d.backupTime),
      delaySeconds: min(max(delay, 0), Self.maxDelaySeconds))
  }

  /// Geçerli ayar. Plus yoksa tek ve ücretsiz bir tetikleyici, her gün
  /// (Dart'taki TriggerConfig.effective).
  func config(_ mode: EsikMode) -> EsikConfig {
    var c = rawConfig(mode)
    if plusActive() { return c }
    c.kinds = [c.kinds.first(where: { Self.freeKinds.contains($0) }) ?? Self.fallbacks[mode]!.kinds[0]]
    c.days = Set(1...7)
    return c
  }

  /// Eşik Plus açık mı: satın alındı ya da deneme sürüyor (Dart'taki PlusState.active).
  func plusActive() -> Bool {
    if defaults.bool(forKey: Self.prefix + "plus_owned") { return true }
    let start = Date(timeIntervalSince1970: Double(TrialAnchor.earliest()) / 1000)
    let end = Calendar.current.date(
      byAdding: .day, value: Self.trialDays, to: Self.thresholdDay(start))!
    return Self.thresholdDay() < end
  }

  /// Dart'ın yazdığı deneme başlangıcı (ms) ve kurulum günü.
  func savedTrialStart() -> Int64? {
    let key = Self.prefix + "trial_start"
    guard defaults.object(forKey: key) != nil else { return nil }
    return Int64(defaults.integer(forKey: key))
  }

  func installedOn() -> Int64? {
    guard let raw = defaults.string(forKey: Self.prefix + "installed_on"),
      let day = Self.dayFormat.date(from: raw)
    else { return nil }
    return Int64(day.timeIntervalSince1970 * 1000)
  }

  func setTrialStart(_ ms: Int64) {
    defaults.set(Int(ms), forKey: Self.prefix + "trial_start")
  }

  func language() -> String { defaults.string(forKey: Self.prefix + "language") ?? "system" }

  // MARK: Kayıt

  func isComplete(_ day: Date, _ mode: EsikMode) -> Bool {
    let entry = (json("log.v1")?[Self.dayKey(day)] as? [String: Any])?[mode.rawValue]
    return (entry as? [String: Any])?["completedAt"] != nil
  }

  /// O eşik gününün kontrolünü tamamlanmış olarak yazar (bildirimdeki Hepsi tamam).
  func completeAll(_ mode: EsikMode, source: String, now: Date = Date()) {
    let day = Self.dayKey(Self.thresholdDay(now))
    var log = json("log.v1") ?? [:]
    var modes = log[day] as? [String: Any] ?? [:]
    modes[mode.rawValue] = [
      "checked": items(mode).map { $0.id },
      "completedAt": Self.isoLocal.string(from: now),
      "source": source,
    ]
    log[day] = modes
    if let data = try? JSONSerialization.data(withJSONObject: log),
      let raw = String(data: data, encoding: .utf8)
    {
      defaults.set(raw, forKey: Self.prefix + "log.v1")
    }
  }

  func wasNotified(_ day: Date, _ mode: EsikMode) -> Bool {
    native.bool(forKey: "notified.\(Self.dayKey(day)).\(mode.rawValue)")
  }

  private func markNotified(_ day: Date, _ mode: EsikMode) {
    let keep = "notified.\(Self.dayKey(day))."
    // Eski günlerin işaretlerini temizle.
    for key in native.dictionaryRepresentation().keys
    where key.hasPrefix("notified.") && !key.hasPrefix(keep) {
      native.removeObject(forKey: key)
    }
    native.set(true, forKey: "notified.\(Self.dayKey(day)).\(mode.rawValue)")
  }

  /// Bugünkü eşik zaten kapandı mı (izin günü, kontrol yapıldı ya da bildirim geldi)?
  func handledToday(_ mode: EsikMode) -> Bool {
    let day = Self.thresholdDay()
    return !config(mode).activeOn(day) || isComplete(day, mode) || wasNotified(day, mode)
  }

  // MARK: Kestirmeler

  /// Kestirmeler otomasyonu çalıştı: [kind] tetikleyicisi oldu.
  @discardableResult
  func fire(kind: String) async -> EsikOutcome? {
    native.set(Date().timeIntervalSince1970, forKey: "seen.\(kind)")
    let mode = EsikMode.of(kind: kind)
    let config = self.config(mode)
    // Uygulamada seçili değilse ya da aralık dışındaysa sessizce geç.
    guard config.kinds.contains(kind), config.inWindow(Date()) else { return nil }
    let day = Self.thresholdDay()
    let outcome: EsikOutcome
    if !config.activeOn(day) {
      outcome = .offDay
    } else if isComplete(day, mode) {
      outcome = .alreadyDone
    } else if wasNotified(day, mode) {
      outcome = .alreadyNotified
    } else if await show(mode, reason: .trigger, kind: kind, delay: config.delaySeconds) {
      outcome = .shown
    } else {
      outcome = .noPermission
    }
    native.set(Date().timeIntervalSince1970 * 1000, forKey: "last.\(mode.rawValue).at")
    native.set(outcome.rawValue, forKey: "last.\(mode.rawValue).outcome")
    native.set(kind, forKey: "last.\(mode.rawValue).kind")
    return outcome
  }

  /// Otomasyonu en az bir kez çalışmış tetikleyiciler (kurulum rehberi için).
  func shortcutsSeen() -> [String] {
    native.dictionaryRepresentation().keys
      .filter { $0.hasPrefix("seen.") }
      .map { String($0.dropFirst("seen.".count)) }
  }

  // MARK: Bildirim

  static let categoryWithItems = "esik.check"
  static let categoryEmpty = "esik.check.empty"
  static let actionAllDone = "esik.allDone"
  static let actionOneByOne = "esik.oneByOne"

  private static func requestId(_ mode: EsikMode) -> String { "esik.\(mode.rawValue)" }
  private static func backupId(_ mode: EsikMode, _ day: Date) -> String {
    "esik.backup.\(mode.rawValue).\(dayKey(day))"
  }

  func registerCategories() {
    let s = EsikStrings(language: language())
    let allDone = UNNotificationAction(
      identifier: Self.actionAllDone, title: s["action_all_done"], options: [])
    let oneByOne = UNNotificationAction(
      identifier: Self.actionOneByOne, title: s["action_one_by_one"], options: [.foreground])
    UNUserNotificationCenter.current().setNotificationCategories([
      UNNotificationCategory(
        identifier: Self.categoryWithItems, actions: [allDone, oneByOne], intentIdentifiers: []),
      UNNotificationCategory(
        identifier: Self.categoryEmpty, actions: [oneByOne], intentIdentifiers: []),
    ])
  }

  func notificationsGranted() async -> Bool {
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    return status == .authorized || status == .provisional || status == .ephemeral
  }

  private func content(_ mode: EsikMode, reason: EsikReason, kind: String?)
    -> UNMutableNotificationContent
  {
    let s = EsikStrings(language: language())
    let items = self.items(mode)
    let labels =
      NSOrderedSet(array: items.compactMap { s.iconLabel($0.icon) }).array as? [String] ?? []
    let summary: String
    if items.isEmpty {
      summary = s["summary_empty"]
    } else if labels.isEmpty {
      summary = s.summaryReady(items.count)
    } else {
      summary = s.summaryLabels(items.count, labels.joined(separator: ", "))
    }
    let lead: String
    switch reason {
    case .trigger: lead = s.triggerPast(kind ?? config(mode).kinds.first ?? "")
    case .backup: lead = s["reason_backup"]
    case .test: lead = s["reason_test"]
    }
    let c = UNMutableNotificationContent()
    c.title = s[mode == .evening ? "mode_evening" : "mode_morning"]
    c.body = ([ "\(lead). \(summary)" ] + items.map { "• \($0.title)" }).joined(separator: "\n")
    c.sound = UNNotificationSound(named: UNNotificationSoundName("esik_chime.caf"))
    c.categoryIdentifier = items.isEmpty ? Self.categoryEmpty : Self.categoryWithItems
    c.threadIdentifier = mode.rawValue
    let source = reason == .backup ? "yedek" : "bildirim"
    c.userInfo = [
      "mode": mode.rawValue,
      "source": reason.rawValue,
      "route": "/kontrol?mod=\(mode.routeParam)&kaynak=\(source)",
    ]
    return c
  }

  /// Bildirimi gönderir ([delay] saniye sonra); izin yoksa false.
  @discardableResult
  func show(_ mode: EsikMode, reason: EsikReason, kind: String? = nil, delay: Int = 0) async
    -> Bool
  {
    guard await notificationsGranted() else { return false }
    registerCategories()
    let trigger =
      delay > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: Double(delay), repeats: false) : nil
    let request = UNNotificationRequest(
      identifier: Self.requestId(mode), content: content(mode, reason: reason, kind: kind),
      trigger: trigger)
    do {
      try await UNUserNotificationCenter.current().add(request)
    } catch {
      return false
    }
    if reason != .test {
      let day = Self.thresholdDay()
      markNotified(day, mode)
      // Bugün bildirim geldi: o günün yedeği gerekmez.
      UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [Self.backupId(mode, day)])
    }
    return true
  }

  /// Kontrol yapıldı: bekleyen ve gösterilen bildirimleri kaldırır.
  func clear(_ mode: EsikMode) {
    let center = UNUserNotificationCenter.current()
    let ids = [Self.requestId(mode), Self.backupId(mode, Self.thresholdDay())]
    center.removePendingNotificationRequests(withIdentifiers: ids)
    center.removeDeliveredNotifications(withIdentifiers: ids)
  }

  // MARK: Yedek saat

  /// Yedek saat bildirimlerini önümüzdeki günler için kurar. iOS bildirimi
  /// gönderilmeden önce uygulamaya sormadığı için, o günün kontrolü yapılınca
  /// ya da bir tetikleyici bildirince o günün yedeği kaldırılır.
  func reschedule() async {
    let center = UNUserNotificationCenter.current()
    let pending = await center.pendingNotificationRequests()
    center.removePendingNotificationRequests(
      withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix("esik.backup.") })
    let granted = await notificationsGranted()
    if granted { registerCategories() }
    let now = Date()
    let today = Self.thresholdDay(now)
    for mode in EsikMode.allCases {
      if isComplete(today, mode) { clear(mode) }
      let config = self.config(mode)
      native.removeObject(forKey: "next.\(mode.rawValue)")
      guard config.backupEnabled, granted else { continue }
      var next: Date?
      for offset in 0..<7 {
        let day = Calendar.current.date(byAdding: .day, value: offset, to: today)!
        guard config.activeOn(day) else { continue }
        if offset == 0, isComplete(day, mode) || wasNotified(day, mode) { continue }
        // 04:00'ten önceki yedek saati ertesi takvim gününe düşer.
        let base =
          config.backupTime.hour < 4
          ? Calendar.current.date(byAdding: .day, value: 1, to: day)! : day
        guard
          let at = Calendar.current.date(
            bySettingHour: config.backupTime.hour, minute: config.backupTime.minute, second: 0,
            of: base), at > now
        else { continue }
        let parts = Calendar.current.dateComponents(
          [.year, .month, .day, .hour, .minute], from: at)
        let request = UNNotificationRequest(
          identifier: Self.backupId(mode, day), content: content(mode, reason: .backup, kind: nil),
          trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false))
        try? await center.add(request)
        next = next ?? at
      }
      if let next { native.set(next.timeIntervalSince1970 * 1000, forKey: "next.\(mode.rawValue)") }
    }
  }

  /// Dart'a: her mod için sıradaki yedek ve son tetikleyicinin sonucu
  /// (Android'deki BackupScheduler.status).
  func status() -> [String: Any] {
    var out: [String: Any] = [:]
    for mode in EsikMode.allCases {
      let k = mode.rawValue
      var m: [String: Any] = [:]
      if let next = native.object(forKey: "next.\(k)") as? Double { m["next"] = Int64(next) }
      if let at = native.object(forKey: "last.\(k).at") as? Double { m["triggerAt"] = Int64(at) }
      m["triggerOutcome"] = native.string(forKey: "last.\(k).outcome")
      m["triggerKind"] = native.string(forKey: "last.\(k).kind")
      out[k] = m
    }
    return out
  }
}

/// Bildirim metinleri (Android'deki res/values*/strings.xml ile aynı).
/// Uygulamada seçilen dil kullanılır; "system" ise telefonunki.
struct EsikStrings {
  private let bundle: Bundle

  init(language: String) {
    let supported = ["tr", "en", "es"]
    let device = Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "en"
    let lang = supported.contains(language) ? language : (supported.contains(device) ? device : "en")
    bundle = Bundle.main.path(forResource: lang, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
  }

  subscript(key: String) -> String {
    bundle.localizedString(forKey: key, value: nil, table: nil)
  }

  func iconLabel(_ icon: String) -> String? {
    let key = "icon_\(icon)"
    let value = self[key]
    return value == key ? nil : value
  }

  func triggerPast(_ kind: String) -> String {
    let value = self["past_\(kind)"]
    return value == "past_\(kind)" ? self["past_default"] : value
  }

  func summaryReady(_ count: Int) -> String {
    String(format: self[count == 1 ? "summary_ready_one" : "summary_ready_other"], count)
  }

  func summaryLabels(_ count: Int, _ labels: String) -> String {
    String(format: self[count == 1 ? "summary_labels_one" : "summary_labels_other"], count, labels)
  }
}
