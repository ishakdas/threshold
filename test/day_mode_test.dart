import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold/core/day_mode.dart';

void main() {
  group('dayModeFor', () {
    DayMode at(int hour, [int minute = 0]) =>
        dayModeFor(DateTime(2026, 10, 20, hour, minute));

    test('akşam 17:00 ile 03:59 arası', () {
      expect(at(17), DayMode.evening);
      expect(at(22, 14), DayMode.evening);
      expect(at(0), DayMode.evening);
      expect(at(3, 59), DayMode.evening);
    });

    test('sabah 04:00 ile 16:59 arası', () {
      expect(at(4), DayMode.morning);
      expect(at(7, 18), DayMode.morning);
      expect(at(16, 59), DayMode.morning);
    });
  });

  test('mod saatten okunur ve elle değiştirilebilir', () {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 20, 22, 14)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(dayModeProvider), DayMode.evening);
    container.read(dayModeProvider.notifier).toggle();
    expect(container.read(dayModeProvider), DayMode.morning);
  });
}
