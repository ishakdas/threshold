import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Günün hangi eşiğinde olduğumuzu belirler. Akşam modu 17:00'de başlar,
/// gece 04:00'e kadar sürer; geri kalan saatler sabah modudur.
enum DayMode { evening, morning }

DayMode dayModeFor(DateTime time) {
  final hour = time.hour;
  return (hour >= 17 || hour < 4) ? DayMode.evening : DayMode.morning;
}

/// Bir anın ait olduğu "eşik günü". Gün 04:00'te başlar; böylece gece 00:12'de
/// yapılan akşam kontrolü bir önceki günün akşamına sayılır.
DateTime thresholdDay(DateTime time) {
  final shifted = time.subtract(const Duration(hours: 4));
  return DateTime(shifted.year, shifted.month, shifted.day);
}

/// Kayıt anahtarı: "2026-10-20".
String dayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

DateTime? parseDayKey(String key) {
  final d = DateTime.tryParse(key);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

/// Testlerde saati sabitlemek için override edilebilir.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Uygulama ön plana her döndüğünde artar. Saate bağlı değerler (bugünün
/// kaydı, akşam/sabah modu) bunu izleyerek yeniden hesaplanır.
class ClockTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final clockTickProvider = NotifierProvider<ClockTickNotifier, int>(
  ClockTickNotifier.new,
);

/// Şu anki eşik günü.
final todayProvider = Provider<DateTime>((ref) {
  ref.watch(clockTickProvider);
  return thresholdDay(ref.watch(clockProvider)());
});

class DayModeNotifier extends Notifier<DayMode> {
  late DayMode _computed;

  @override
  DayMode build() {
    _computed = dayModeFor(ref.watch(clockProvider)());
    // Ön plana dönüldüğünde saatin gösterdiği mod değiştiyse ona geç; değişmediyse
    // kullanıcının elle seçtiği mod korunur.
    ref.listen(clockTickProvider, (_, _) {
      final now = dayModeFor(ref.read(clockProvider)());
      if (now != _computed) {
        _computed = now;
        state = now;
      }
    });
    return _computed;
  }

  /// Kullanıcı modu elle değiştirebilir (ör. tasarım önizlemesi, gece vardiyası).
  void set(DayMode mode) => state = mode;

  void toggle() =>
      state = state == DayMode.evening ? DayMode.morning : DayMode.evening;
}

final dayModeProvider = NotifierProvider<DayModeNotifier, DayMode>(
  DayModeNotifier.new,
);
