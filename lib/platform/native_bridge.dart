import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/day_mode.dart';

/// Android tarafıyla (android/app/src/main/kotlin/.../MainActivity.kt) konuşur:
/// bildirim izni, deneme bildirimi, yedek saat alarmları, bildirimden gelen
/// yönlendirmeler. Kanal yoksa (testler, iOS) çağrılar sessizce boş döner.
class NativeBridge {
  NativeBridge([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('esik/native');

  final MethodChannel _channel;

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('NativeBridge.$method: $e');
      return null;
    }
  }

  /// Android'den gelen olaylar: bildirimden bir ekran açılması ve
  /// bildirimdeki "Hepsi tamam" ile kaydın değişmesi.
  void listen({
    required void Function(String route) onOpenRoute,
    required VoidCallback onDataChanged,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'openRoute':
          if (call.arguments case final String route) onOpenRoute(route);
        case 'dataChanged':
          onDataChanged();
      }
    });
  }

  /// Uygulama bir bildirime dokunularak açıldıysa gidilecek ekran (bir kez).
  Future<String?> takeLaunchRoute() => _call<String>('takeLaunchRoute');

  Future<void> rescheduleBackups() => _call<void>('rescheduleBackups');

  Future<bool> notificationsGranted() async =>
      await _call<bool>('notificationsGranted') ?? false;

  /// Android 13+ izin penceresini açar. İzin verildiyse true.
  Future<bool> requestNotificationPermission() async =>
      await _call<bool>('requestNotificationPermission') ?? false;

  /// Gönderilebildiyse true (izin yoksa false).
  Future<bool> showTestNotification(DayMode mode) async =>
      await _call<bool>('showTestNotification', {'mode': mode.name}) ?? false;

  Future<bool?> isIgnoringBatteryOptimizations() =>
      _call<bool>('isIgnoringBatteryOptimizations');

  Future<void> openBatterySettings() => _call<void>('openBatterySettings');

  Future<void> openNotificationSettings() =>
      _call<void>('openNotificationSettings');
}

final nativeBridgeProvider = Provider<NativeBridge>((ref) => NativeBridge());
