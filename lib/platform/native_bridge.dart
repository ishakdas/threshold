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

  /// Yedek saat alarmlarını diskteki ayara göre yeniden kurar ve son durumu döner.
  Future<Map<DayMode, BackupStatus>?> rescheduleBackups() async =>
      BackupStatus.parse(await _call<Object?>('rescheduleBackups'));

  Future<Map<DayMode, BackupStatus>?> backupStatus() async =>
      BackupStatus.parse(await _call<Object?>('backupStatus'));

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

/// Yedek saat alarmının durumu (Android'deki BackupScheduler.status).
class BackupStatus {
  const BackupStatus({this.next, this.lastAt, this.lastOutcome});

  /// Sıradaki alarm; yedek kapalıysa null.
  final DateTime? next;

  /// Son alarmın çaldığı an ve sonucu.
  final DateTime? lastAt;
  final BackupOutcome? lastOutcome;

  static DateTime? _time(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

  static Map<DayMode, BackupStatus>? parse(Object? raw) {
    if (raw is! Map) return null;
    return {
      for (final mode in DayMode.values)
        if (raw[mode.name] case final Map m)
          mode: BackupStatus(
            next: _time(m['next']),
            lastAt: _time(m['lastAt']),
            lastOutcome: BackupOutcome.values
                .where((o) => o.name == m['lastOutcome'])
                .firstOrNull,
          ),
    };
  }
}

/// Android'deki BackupOutcome ile aynı adlar.
enum BackupOutcome {
  shown('gönderildi'),
  alreadyDone('atlandı: kontrol zaten yapılmıştı'),
  alreadyNotified('atlandı: o gün bildirim zaten gelmişti'),
  noPermission('gönderilemedi: bildirim izni kapalı'),
  disabled('atlandı: yedek kapalı');

  const BackupOutcome(this.description);
  final String description;
}

/// Ayarlar ekranındaki "Sıradaki yedek" satırı için. Ön plana dönünce yenilenir;
/// alarmlar yeniden kurulunca app.dart bunu geçersiz kılar.
final backupStatusProvider = FutureProvider<Map<DayMode, BackupStatus>?>((ref) {
  ref.watch(clockTickProvider);
  return ref.watch(nativeBridgeProvider).backupStatus();
});

/// Bildirim izni var mı? Ön plana dönünce yeniden sorulur. Android kanalı
/// yoksa (testler) null.
final notificationsGrantedProvider = FutureProvider<bool?>((ref) async {
  ref.watch(clockTickProvider);
  final bridge = ref.watch(nativeBridgeProvider);
  try {
    return await bridge._channel.invokeMethod<bool>('notificationsGranted');
  } on MissingPluginException {
    return null;
  }
});
