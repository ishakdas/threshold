import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/day_mode.dart';
import 'app_state.dart';
import 'models.dart';
import 'store.dart';

/// Play Console'daki tek seferlik ürünün kimliği.
const plusProductId = 'esik_plus';

/// İlk açılıştan itibaren bütün Plus özellikleri bu kadar gün açık.
/// Android tarafı (EsikData.TRIAL_DAYS) aynı süreyi kullanır.
const plusTrialDays = 15;

/// Eşik Plus satın alındı mı? Play'den gelen satın almalar burada saklanır;
/// Android tarafı da bildirimleri buna göre gönderir.
class PlusOwnedNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(EsikStore.plusOwnedKey) ??
      false;

  void set(bool owned) {
    if (owned == state) return;
    state = owned;
    unawaited(
      ref
          .read(sharedPreferencesProvider)
          .setBool(EsikStore.plusOwnedKey, owned),
    );
  }
}

final plusOwnedProvider = NotifierProvider<PlusOwnedNotifier, bool>(
  PlusOwnedNotifier.new,
);

class PlusState {
  const PlusState({required this.owned, required this.trialDaysLeft});

  final bool owned;

  /// Denemenin kalan günü (bugün dahil); bittiyse 0.
  final int trialDaysLeft;

  bool get inTrial => !owned && trialDaysLeft > 0;

  /// Plus özellikleri şu an açık mı?
  bool get active => owned || trialDaysLeft > 0;
}

/// Denemenin başladığı gün. Android tarafı (TrialAnchor) uygulamanın kaydı,
/// kurulum zamanı ve Google Block Store'dan en eskisini "trial_start"a yazar;
/// böylece veriler silinip ya da uygulama yeniden kurulup deneme sıfırlanamaz.
final trialStartProvider = Provider<DateTime>((ref) {
  final installed = ref.watch(installDayProvider);
  final ms = ref
      .watch(sharedPreferencesProvider)
      .getInt(EsikStore.trialStartKey);
  if (ms == null) return installed;
  final anchored = thresholdDay(DateTime.fromMillisecondsSinceEpoch(ms));
  return anchored.isBefore(installed) ? anchored : installed;
});

final plusProvider = Provider<PlusState>((ref) {
  final installed = ref.watch(trialStartProvider);
  final today = ref.watch(todayProvider);
  final used = today.difference(installed).inDays;
  return PlusState(
    owned: ref.watch(plusOwnedProvider),
    trialDaysLeft: (plusTrialDays - used).clamp(0, plusTrialDays),
  );
});

/// Plus yoksa geçerli olan eşik ayarları (bkz. [TriggerConfig.effective]).
/// Bugün, geçmiş ve kurulum bunu kullanır; Ayarlar asıl seçimi gösterir.
final effectiveTriggerConfigProvider = Provider<Map<DayMode, TriggerConfig>>((
  ref,
) {
  final plus = ref.watch(plusProvider).active;
  return {
    for (final e in ref.watch(triggerConfigProvider).entries)
      e.key: e.value.effective(plus: plus),
  };
});

/// Plus yoksa sessizdeyken bildirim telefonun ayarına uyar.
final effectiveSilentAlertProvider = Provider<SilentAlert>(
  (ref) => ref.watch(plusProvider).active
      ? ref.watch(silentAlertProvider)
      : SilentAlert.quiet,
);
