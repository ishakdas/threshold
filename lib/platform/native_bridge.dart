import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/day_mode.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

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

  /// iOS: Kestirmeler uygulaması (otomasyon kurmak için).
  Future<void> openShortcuts() => _call<void>('openShortcuts');

  /// Saat uygulamasının alarm listesi.
  Future<void> openClock() => _call<void>('openClock');

  /// Deneme başlangıcını telefondaki kalıcı kayıtlarla eşitler (TrialAnchor);
  /// sonucu "trial_start" olarak diske yazar.
  Future<int?> syncTrial() => _call<int>('syncTrial');

  Future<SetupHealth?> setupHealth() async =>
      SetupHealth.parse(await _call<Object?>('setupHealth'));

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

  /// Telefondaki e-posta uygulamasında [email] adresine yeni ileti açar;
  /// e-posta uygulaması yoksa false.
  Future<bool> sendFeedback({
    required String email,
    required String subject,
  }) async =>
      await _call<bool>('sendFeedback', {'email': email, 'subject': subject}) ??
      false;

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
    this.triggerKind,
    this.waits = const [],
  });

  /// Sıradaki yedek alarm; yedek kapalıysa null.
  final DateTime? next;

  /// Son yedek alarmın çaldığı an ve sonucu.
  final DateTime? lastAt;
  final NotifyOutcome? lastOutcome;

  /// Tetikleyicinin (şarj, alarm, Wi‑Fi) son çalıştığı an ve sonucu.
  final DateTime? triggerAt;
  final NotifyOutcome? triggerOutcome;

  /// Son çalışan tetikleyici.
  final TriggerKind? triggerKind;

  /// Seçili her tetikleyicinin şu an beklediği şey (NFC hariç).
  final List<TriggerWaiting> waits;

  static DateTime? _time(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

  static NotifyOutcome? _outcome(Object? name) =>
      NotifyOutcome.values.where((o) => o.name == name).firstOrNull;

  static List<TriggerWaiting> _waits(Object? raw) => [
    if (raw is List)
      for (final w in raw.whereType<Map>())
        if (TriggerKind.values.where((k) => k.name == w['kind']).firstOrNull
            case final kind?)
          if (TriggerWait.values.where((v) => v.name == w['wait']).firstOrNull
              case final wait?)
            TriggerWaiting(kind, wait, _time(w['at'])),
  ];

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
            triggerKind: TriggerKind.values
                .where((k) => k.name == m['triggerKind'])
                .firstOrNull,
            waits: _waits(m['triggerWaits']),
          ),
    };
  }
}

/// Bir tetikleyicinin beklediği şey ve ilgili an: sıradaki alarm ya da
/// beklemenin başladığı an.
class TriggerWaiting {
  const TriggerWaiting(this.kind, this.wait, this.at);
  final TriggerKind kind;
  final TriggerWait wait;
  final DateTime? at;
}

/// Tetikleyicinin şu an beklediği şey (Android'deki TriggerScheduler.waiting).
enum TriggerWait {
  /// Şarja takılmasını bekliyor ([TriggerWaiting.at]'ten itibaren).
  charging,

  /// Sıradaki alarm [TriggerWaiting.at]'te.
  alarm,

  /// Alarm az önce çaldı; kapatılmasına ya da ertelenmesine bakılacak.
  alarmSettling,
  noAlarm,

  /// Wi‑Fi'a bağlanmayı bekliyor ([TriggerWaiting.at]'ten itibaren).
  wifi,

  /// Wi‑Fi'dan kopup mobil veriye geçmeyi bekliyor.
  leaving,

  /// Aralıkta telefonun şarjda olmasını bekliyor ([TriggerWaiting.at]'ten itibaren).
  pluggedIn,

  /// Telefon şarjda; fişin çekilmesini bekliyor.
  unplug,

  /// Sesin bir kademe kısılmasını bekliyor (sesli → titreşim → sessiz).
  silence,

  /// Telefon zaten en sessiz kademede; daha fazla kısılamaz.
  alreadySilent,

  /// Sesin bir kademe açılmasını bekliyor.
  unsilence,

  /// Zil zaten açık; daha fazla açılamaz.
  notSilent,

  /// İş kurulu değil; olmaması gerekir.
  none,
}

enum NfcState { unsupported, off, on }

/// Kurulumun telefondaki gerçek durumu (MainActivity.setupHealth).
class SetupHealth {
  const SetupHealth({
    this.notificationPermission = true,
    this.notificationsEnabled = true,
    this.battery = true,
    this.nfc = NfcState.on,
    this.nfcTagWritten = false,
    this.nextAlarm,
    this.alarmVolume = 1,
    this.shortcutsSeen = const {},
  });

  final bool notificationPermission;

  /// Uygulamanın ve Eşik kanalının bildirimleri telefon ayarlarında açık mı.
  final bool notificationsEnabled;

  /// Pil optimizasyonundan muaf ("Kısıtlamasız").
  final bool battery;
  final NfcState nfc;
  final bool nfcTagWritten;

  /// Saat uygulamasındaki sıradaki alarm; yoksa null.
  final DateTime? nextAlarm;
  final int alarmVolume;

  /// iOS: Kestirmeler otomasyonu en az bir kez çalışmış tetikleyiciler.
  final Set<TriggerKind> shortcutsSeen;

  bool get notifications => notificationPermission && notificationsEnabled;

  static SetupHealth? parse(Object? raw) {
    if (raw is! Map) return null;
    return SetupHealth(
      notificationPermission: raw['notificationPermission'] == true,
      notificationsEnabled: raw['notificationsEnabled'] == true,
      battery: raw['battery'] == true,
      nfc:
          NfcState.values.where((n) => n.name == raw['nfc']).firstOrNull ??
          NfcState.unsupported,
      nfcTagWritten: raw['nfcTagWritten'] == true,
      nextAlarm: switch (raw['nextAlarm']) {
        final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
        _ => null,
      },
      alarmVolume: switch (raw['alarmVolume']) {
        final int v => v,
        _ => 1,
      },
      shortcutsSeen: {
        if (raw['shortcutsSeen'] case final List seen)
          for (final kind in TriggerKind.values)
            if (seen.contains(kind.name)) kind,
      },
    );
  }
}

/// Kurulum durumu; ön plana dönünce yenilenir. Android kanalı yoksa (testler) null.
final setupHealthProvider = FutureProvider<SetupHealth?>((ref) {
  ref.watch(clockTickProvider);
  return ref.watch(nativeBridgeProvider).setupHealth();
});

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
  shown,
  alreadyDone,
  alreadyNotified,
  noPermission,
  disabled,
  offDay;

  String description(AppLocalizations l) => switch (this) {
    shown => l.outcomeShown,
    alreadyDone => l.outcomeAlreadyDone,
    alreadyNotified => l.outcomeAlreadyNotified,
    noPermission => l.outcomeNoPermission,
    disabled => l.outcomeDisabled,
    offDay => l.outcomeOffDay,
  };
}

/// Ayarlar ekranındaki durum satırı için. Ön plana dönünce yenilenir;
/// alarmlar yeniden kurulunca app.dart bunu geçersiz kılar.
final thresholdStatusProvider = FutureProvider<Map<DayMode, ThresholdStatus>?>((
  ref,
) {
  ref.watch(clockTickProvider);
  return ref.watch(nativeBridgeProvider).status();
});
