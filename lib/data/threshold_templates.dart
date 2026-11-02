import 'package:flutter/material.dart' show TimeOfDay;

import '../core/day_mode.dart';
import '../l10n/app_localizations.dart';
import 'models.dart';

/// Hazır düzen: iki modun eşiklerini birlikte kurar (girişte ve Eşikler
/// ekranında). Birden fazla eşikli düzenler Plus ister.
class ThresholdTemplate {
  const ThresholdTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thresholds,
  });

  final String id;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) subtitle;
  final Map<DayMode, List<TriggerConfig>> thresholds;

  bool get plusOnly => thresholds.values.any(
    (l) => l.length > 1 || l.any((c) => c.kinds.any((k) => !k.free)),
  );
}

TimeOfDay _t(int h, [int m = 0]) => TimeOfDay(hour: h, minute: m);

final thresholdTemplates = <ThresholdTemplate>[
  ThresholdTemplate(
    id: 'everyday',
    title: (l) => l.ttEverydayTitle,
    subtitle: (l) => l.ttEverydaySubtitle,
    thresholds: {
      DayMode.evening: [
        TriggerConfig(
          kinds: const [TriggerKind.charging],
          windowStart: _t(22),
          windowEnd: _t(2),
          backupTime: _t(22, 30),
        ),
      ],
      DayMode.morning: [
        TriggerConfig(
          kinds: const [TriggerKind.alarmStopped],
          windowStart: _t(6),
          windowEnd: _t(10),
          backupTime: _t(8, 15),
        ),
      ],
    },
  ),
  ThresholdTemplate(
    id: 'workweek',
    title: (l) => l.ttWorkweekTitle,
    subtitle: (l) => l.ttWorkweekSubtitle,
    thresholds: {
      // Akşam eşiği ertesi günün hazırlığı: Cuma ve Cumartesi geceleri hafta sonu.
      DayMode.evening: [
        TriggerConfig(
          kinds: const [TriggerKind.charging],
          days: const {1, 2, 3, 4, 7},
          windowStart: _t(21, 30),
          windowEnd: _t(1),
          backupTime: _t(22, 30),
        ),
        TriggerConfig(
          kinds: const [TriggerKind.charging],
          days: const {5, 6},
          windowStart: _t(22, 30),
          windowEnd: _t(3),
          backupTime: _t(0, 30),
        ),
      ],
      DayMode.morning: [
        TriggerConfig(
          kinds: const [TriggerKind.alarmStopped],
          days: const {1, 2, 3, 4, 5},
          windowStart: _t(6),
          windowEnd: _t(9),
          backupTime: _t(7, 45),
        ),
        TriggerConfig(
          kinds: const [TriggerKind.unplugged],
          days: const {6, 7},
          windowStart: _t(8),
          windowEnd: _t(12),
          backupTime: _t(11),
        ),
      ],
    },
  ),
  ThresholdTemplate(
    id: 'early',
    title: (l) => l.ttEarlyTitle,
    subtitle: (l) => l.ttEarlySubtitle,
    thresholds: {
      DayMode.evening: [
        TriggerConfig(
          kinds: const [TriggerKind.charging],
          windowStart: _t(20, 30),
          windowEnd: _t(0),
          backupTime: _t(21, 30),
        ),
      ],
      DayMode.morning: [
        TriggerConfig(
          kinds: const [TriggerKind.alarmStopped],
          windowStart: _t(4),
          windowEnd: _t(7, 30),
          backupTime: _t(6, 30),
        ),
      ],
    },
  ),
  ThresholdTemplate(
    id: 'home',
    title: (l) => l.ttHomeTitle,
    subtitle: (l) => l.ttHomeSubtitle,
    thresholds: {
      DayMode.evening: [
        TriggerConfig(
          kinds: const [TriggerKind.charging],
          windowStart: _t(22),
          windowEnd: _t(2),
          backupTime: _t(23),
        ),
      ],
      DayMode.morning: [
        TriggerConfig(
          kinds: const [TriggerKind.alarmStopped],
          windowStart: _t(7),
          windowEnd: _t(11),
          windowEnabled: false,
          backupTime: _t(9, 30),
          backupEnabled: false,
        ),
      ],
    },
  ),
];
