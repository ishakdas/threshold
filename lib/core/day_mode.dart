import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Günün hangi eşiğinde olduğumuzu belirler. Akşam modu 17:00'de başlar,
/// gece 04:00'e kadar sürer; geri kalan saatler sabah modudur.
enum DayMode { evening, morning }

DayMode dayModeFor(DateTime time) {
  final hour = time.hour;
  return (hour >= 17 || hour < 4) ? DayMode.evening : DayMode.morning;
}

/// Testlerde saati sabitlemek için override edilebilir.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class DayModeNotifier extends Notifier<DayMode> {
  @override
  DayMode build() => dayModeFor(ref.watch(clockProvider)());

  /// Kullanıcı modu elle değiştirebilir (ör. tasarım önizlemesi, gece vardiyası).
  void set(DayMode mode) => state = mode;

  void toggle() =>
      state = state == DayMode.evening ? DayMode.morning : DayMode.evening;
}

final dayModeProvider = NotifierProvider<DayModeNotifier, DayMode>(
  DayModeNotifier.new,
);
