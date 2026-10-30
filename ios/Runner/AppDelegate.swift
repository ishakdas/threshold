import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Bildirim eylemleri ("Hepsi tamam", "Tek tek bak") burada karşılanır.
    UNUserNotificationCenter.current().delegate = self
    EsikCore.shared.registerCategories()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "EsikNative") {
      EsikChannel.shared.attach(messenger: registrar.messenger())
    }
  }

  /// Uygulama açıkken de bildirim görünsün.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .list, .sound])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let info = response.notification.request.content.userInfo
    guard let mode = EsikMode(rawValue: info["mode"] as? String ?? "") else {
      super.userNotificationCenter(
        center, didReceive: response, withCompletionHandler: completionHandler)
      return
    }
    switch response.actionIdentifier {
    case EsikCore.actionAllDone:
      EsikChannel.shared.allDone(
        mode: mode, source: info["source"] as? String ?? EsikReason.trigger.rawValue)
      // Bugünün yedeği de kalksın.
      Task {
        await EsikCore.shared.reschedule()
        completionHandler()
      }
      return
    case UNNotificationDismissActionIdentifier:
      break
    default:
      if let route = info["route"] as? String { EsikChannel.shared.openRoute(route) }
    }
    completionHandler()
  }
}
