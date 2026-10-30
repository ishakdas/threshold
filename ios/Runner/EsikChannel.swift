import Flutter
import Foundation
import Security
import UIKit
import UserNotifications

/// Dart'taki NativeBridge'in iOS karşılığı (Android'de MainActivity). Aynı
/// kanal adını ve yöntem adlarını kullanır; iOS'ta anlamı olmayanlar
/// (pil, NFC yazma, saat uygulaması) zararsız bir sonuç döner.
final class EsikChannel {
  static let shared = EsikChannel()

  private var channel: FlutterMethodChannel?

  /// Bildirime dokunularak açılınca gidilecek ekran; Dart açılışta bir kez alır.
  private var launchRoute: String?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "esik/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result)
    }
    self.channel = channel
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let core = EsikCore.shared
    let args = call.arguments as? [String: Any]
    func done(_ value: Any?) { DispatchQueue.main.async { result(value) } }
    switch call.method {
    case "takeLaunchRoute":
      result(launchRoute)
      launchRoute = nil
    case "reschedule":
      Task {
        await core.reschedule()
        done(core.status())
      }
    case "backupStatus":
      result(core.status())
    case "notificationsGranted":
      Task { done(await core.notificationsGranted()) }
    case "requestNotificationPermission":
      Task {
        let granted =
          (try? await UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
          ])) ?? false
        if granted { await core.reschedule() }
        done(granted)
      }
    case "showTestNotification":
      let mode = EsikMode(rawValue: args?["mode"] as? String ?? "") ?? .evening
      Task { done(await core.show(mode, reason: .test)) }
    case "setupHealth":
      Task {
        let granted = await core.notificationsGranted()
        done([
          "notificationPermission": granted,
          "notificationsEnabled": granted,
          "battery": true,
          "nfc": "on",
          "nfcTagWritten": true,
          "alarmVolume": 1,
          "shortcutsSeen": core.shortcutsSeen(),
        ] as [String: Any])
      }
    case "syncTrial":
      result(NSNumber(value: TrialAnchor.sync()))
    case "isIgnoringBatteryOptimizations":
      result(true)
    case "openNotificationSettings":
      if #available(iOS 16.0, *) {
        openURL(UIApplication.openNotificationSettingsURLString)
      } else {
        openURL(UIApplication.openSettingsURLString)
      }
      result(nil)
    case "openShortcuts":
      openURL("shortcuts://")
      result(nil)
    case "sendFeedback":
      sendFeedback(
        email: args?["email"] as? String ?? "", subject: args?["subject"] as? String ?? ""
      ) { opened in result(opened) }
    case "writeNfcTag":
      result("unsupported")
    case "cancelNfcTag", "openNfcSettings", "openBatterySettings", "openClock":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func openURL(_ url: String) {
    guard let url = URL(string: url) else { return }
    UIApplication.shared.open(url)
  }

  /// E-posta uygulamasında, sürüm ve cihaz bilgisiyle yeni ileti açar.
  private func sendFeedback(email: String, subject: String, done: @escaping (Bool) -> Void) {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let device = UIDevice.current
    let body = "\n\n\n—\nEşik \(version) · iOS \(device.systemVersion) · \(device.model)"
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = email
    components.queryItems = [
      URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: body),
    ]
    guard let url = components.url else { return done(false) }
    UIApplication.shared.open(url) { opened in done(opened) }
  }

  // MARK: Bildirime dokunuldu

  /// "Hepsi tamam": uygulamayı açmadan kontrolü tamamlar.
  func allDone(mode: EsikMode, source: String) {
    // Deneme bildirimindeki buton kaydı değiştirmez.
    if source != EsikReason.test.rawValue {
      EsikCore.shared.completeAll(mode, source: source)
    }
    EsikCore.shared.clear(mode)
    channel?.invokeMethod("dataChanged", arguments: nil)
  }

  /// Bildirim ya da "Tek tek bak": kontrol ekranını açar. Dart henüz
  /// dinlemiyorsa (soğuk açılış) rota açılışta takeLaunchRoute ile alınır.
  func openRoute(_ route: String) {
    launchRoute = route
    channel?.invokeMethod("openRoute", arguments: route) { [weak self] value in
      if (value as AnyObject?) !== FlutterMethodNotImplemented { self?.launchRoute = nil }
    }
  }
}

/// Plus denemesinin başladığı an, uygulama silinip yeniden kurulsa da
/// unutulmasın diye Anahtar Zinciri'nde de tutulur; en eskisi geçerlidir
/// (Android'deki TrialAnchor, Block Store yerine Anahtar Zinciri).
enum TrialAnchor {
  private static let service = "com.ishakdas.threshold.trial"
  private static let account = "start"

  private static func query() -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
  }

  private static func read() -> Int64? {
    var q = query()
    q[kSecReturnData as String] = true
    q[kSecMatchLimit as String] = kSecMatchLimitOne
    var item: CFTypeRef?
    guard SecItemCopyMatching(q as CFDictionary, &item) == errSecSuccess,
      let data = item as? Data, data.count == 8
    else { return nil }
    var value: Int64 = 0
    _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0) }
    return value
  }

  private static func write(_ value: Int64) {
    let data = withUnsafeBytes(of: value) { Data($0) }
    SecItemDelete(query() as CFDictionary)
    var q = query()
    q[kSecValueData as String] = data
    q[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    SecItemAdd(q as CFDictionary, nil)
  }

  /// Telefondaki kayıtlarla bilinen en eski başlangıç (ms).
  static func earliest() -> Int64 {
    let core = EsikCore.shared
    let now = Int64(Date().timeIntervalSince1970 * 1000)
    return [core.savedTrialStart(), core.installedOn(), read(), now].compactMap { $0 }.min()!
  }

  /// En eskisini uygulamaya ("trial_start") ve Anahtar Zinciri'ne yazar.
  static func sync() -> Int64 {
    let start = earliest()
    EsikCore.shared.setTrialStart(start)
    if read().map({ $0 > start }) ?? true { write(start) }
    return start
  }
}
