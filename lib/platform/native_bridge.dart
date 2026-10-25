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

  /// Yedek saat alarmlarını ve tetikleyici işlerini diskteki ayara göre
  /// yeniden kurar, son durumu döner.
  Future<Map<DayMode, ThresholdStatus>?> reschedule() async =>
      ThresholdStatus.parse(await _call<Object?>('reschedule'));

  Future<Map<DayMode, ThresholdStatus>?> status() async =>
      ThresholdStatus.parse(await _call<Object?>('backupStatus'));

  /// Telefon bir etikete yaklaştırılana ya da [cancelNfcTag] çağrılana kadar bekler.
  Future<NfcWriteResult> writeNfcTag() async {
    final name = await _call<String>('writeNfcTag');
    return NfcWriteResult.values.where((r) => r.name == name).firstOrNull ??
        NfcWriteResult.unsupported;
  }

  Future<void> cancelNfcTag() => _call<void>('cancelNfcTag');

  Future<void> openNfcSettings() => _call<void>('openNfcSettings');

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

/// Bir modun yedek alarmı ve tetikleyicisinin durumu (Android'deki
/// BackupScheduler.status).
class ThresholdStatus {
  const ThresholdStatus({
    this.next,
    this.lastAt,
    this.lastOutcome,
    this.triggerAt,
    this.triggerOutcome,
    this.wait,
    this.waitAt,
  });

  /// Sıradaki yedek alarm; yedek kapalıysa null.
  final DateTime? next;

  /// Son yedek alarmın çaldığı an ve sonucu.
  final DateTime? lastAt;
  final NotifyOutcome? lastOutcome;

  /// Tetikleyicinin (şarj, alarm, Wi‑Fi) son çalıştığı an ve sonucu.
  final DateTime? triggerAt;
  final NotifyOutcome? triggerOutcome;

  /// Tetikleyicinin şu an beklediği şey; NFC ve henüz desteklenmeyenlerde null.
  final TriggerWait? wait;

  /// Beklemeyle ilgili an: sıradaki alarm ya da beklemenin başladığı an.
  final DateTime? waitAt;

  static DateTime? _time(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

  static NotifyOutcome? _outcome(Object? name) =>
      NotifyOutcome.values.where((o) => o.name == name).firstOrNull;

  static Map<DayMode, ThresholdStatus>? parse(Object? raw) {
    if (raw is! Map) return null;
    return {
      for (final mode in DayMode.values)
        if (raw[mode.name] case final Map m)
          mode: ThresholdStatus(
            next: _time(m['next']),
            lastAt: _time(m['lastAt']),
            lastOutcome: _outcome(m['lastOutcome']),
            triggerAt: _time(m['triggerAt']),
            triggerOutcome: _outcome(m['triggerOutcome']),
            wait: switch (m['triggerWait']) {
              final Map w =>
                TriggerWait.values
                    .where((v) => v.name == w['wait'])
                    .firstOrNull,
              _ => null,
            },
            waitAt: switch (m['triggerWait']) {
              final Map w => _time(w['at']),
              _ => null,
            },
          ),
    };
  }
}

/// Tetikleyicinin şu an beklediği şey (Android'deki TriggerScheduler.waiting).
enum TriggerWait {
  /// Şarja takılmasını bekliyor ([ThresholdStatus.waitAt]'ten itibaren).
  charging,

  /// Sıradaki alarm [ThresholdStatus.waitAt]'te.
  alarm,

  /// Alarm az önce çaldı; kapatılmasına ya da ertelenmesine bakılacak.
  alarmSettling,
  noAlarm,

  /// Wi‑Fi'a bağlanmayı bekliyor ([ThresholdStatus.waitAt]'ten itibaren).
  wifi,

  /// Wi‑Fi'dan kopup mobil veriye geçmeyi bekliyor.
  leaving,

  /// Sessize alınmayı bekliyor.
  silence,

  /// Telefon zaten sessizde; önce zil açılmalı.
  alreadySilent,

  /// Sessizden çıkarılmayı bekliyor.
  unsilence,

  /// Telefon sessizde değil; önce sessize alınmalı.
  notSilent,

  /// İş kurulu değil; olmaması gerekir.
  none,
}

/// NFC etiketi yazmanın sonucu (Android'deki NfcTagWriter ile aynı adlar).
enum NfcWriteResult {
  written,
  cancelled,
  unsupported,
  disabled,
  readOnly,
  tooSmall,
  incompatible,
  error,
}

/// Android'deki NotifyOutcome ile aynı adlar.
enum NotifyOutcome {
  shown('gönderildi'),
  alreadyDone('atlandı: kontrol zaten yapılmıştı'),
  alreadyNotified('atlandı: o gün bildirim zaten gelmişti'),
  noPermission('gönderilemedi: bildirim izni kapalı'),
  disabled('atlandı: yedek kapalı');

  const NotifyOutcome(this.description);
  final String description;
}

/// Ayarlar ekranındaki durum satırı için. Ön plana dönünce yenilenir;
/// alarmlar yeniden kurulunca app.dart bunu geçersiz kılar.
final thresholdStatusProvider = FutureProvider<Map<DayMode, ThresholdStatus>?>((
  ref,
) {
  ref.watch(clockTickProvider);
  return ref.watch(nativeBridgeProvider).status();
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
