import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'store.dart';

/// Israrcı hatırlatma: kontrol yapılmazsa bildirim [minutes] dakikada bir
/// tekrar gelir, toplam en fazla [max] kez. Android ve iOS tarafı
/// (EsikData.kt, EsikCore.swift) aynı kaydı okur.
class ReminderSettings {
  const ReminderSettings({this.max = 5, this.minutes = 10});

  static const maxLimit = 5;
  static const minuteChoices = [5, 10, 15, 30];

  /// Toplam bildirim sayısı (ilk bildirim dahil); 1: tekrar yok.
  final int max;
  final int minutes;

  Map<String, Object?> toJson() => {'max': max, 'minutes': minutes};

  factory ReminderSettings.fromJson(Map<String, Object?>? json) {
    final max = json?['max'], minutes = json?['minutes'];
    return ReminderSettings(
      max: max is int ? max.clamp(1, maxLimit) : 5,
      minutes: minutes is int && minuteChoices.contains(minutes) ? minutes : 10,
    );
  }
}

class ReminderNotifier extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() => ReminderSettings.fromJson(
    ref.watch(storeProvider).readJson(EsikStore.remindersKey),
  );

  /// Son yazmanın bitişi (alarmlar yeniden kurulmadan önce beklenir).
  Future<void> saved = Future.value();

  void set(ReminderSettings next) {
    saved = ref
        .read(storeProvider)
        .writeJson(EsikStore.remindersKey, next.toJson());
    state = next;
  }
}

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderSettings>(
  ReminderNotifier.new,
);
