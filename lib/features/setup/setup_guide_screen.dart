import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../platform/native_bridge.dart';
import '../../l10n/texts.dart';

/// Adımın ana butonunun ne yapacağı.
enum SetupStepKind { notifications, battery, trigger, test }

class SetupStep {
  const SetupStep({
    required this.kind,
    required this.title,
    required this.detail,
    required this.action,
    required this.icon,
    this.trigger,
  });

  final SetupStepKind kind;

  /// Tetikleyiciye özel adımda hangi tetikleyici için olduğu.
  final TriggerKind? trigger;
  final String title;
  final String detail;

  /// Ana butonun etiketi.
  final String action;
  final EsikIcon icon;

  SetupStep _forTrigger(TriggerKind k) => SetupStep(
    kind: kind,
    title: title,
    detail: detail,
    action: action,
    icon: icon,
    trigger: k,
  );
}

/// Seçilen tetikleyicilerin Android'de çalışması için gereken adımlar: ortak
/// izinler, her tetikleyicinin kendi adımı, sonda deneme. Kısayollar'ın
/// olmadığı Android'de iOS'taki kurulum rehberinin karşılığıdır.
List<SetupStep> setupStepsFor(AppLocalizations l, List<TriggerKind> kinds) {
  final notifications = SetupStep(
    kind: SetupStepKind.notifications,
    title: l.stepNotifTitle,
    detail: l.stepNotifDetail,
    action: l.allow,
    icon: EsikIcon.bell,
  );
  final battery = SetupStep(
    kind: SetupStepKind.battery,
    title: l.stepBatteryTitle,
    detail: l.stepBatteryDetail,
    action: l.allow,
    icon: EsikIcon.battery,
  );
  SetupStep? specific(TriggerKind kind) => switch (kind) {
    TriggerKind.appClosed => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepUsageTitle,
      detail: l.stepUsageDetail,
      action: l.stepUsageAction,
      icon: EsikIcon.app,
    ),
    TriggerKind.silenced || TriggerKind.unsilenced => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepNoPermissionTitle,
      detail: kind == TriggerKind.silenced
          ? l.stepSilencedDetail
          : l.stepUnsilencedDetail,
      action: l.gotIt,
      icon: kind.icon,
    ),
    TriggerKind.sleepMode => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepNotifAccessTitle,
      detail: l.stepNotifAccessDetail,
      action: l.stepNotifAccessAction,
      icon: EsikIcon.bed,
    ),
    TriggerKind.leftHomeWifi => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepWifiTitle,
      detail: l.stepWifiDetail,
      action: l.gotIt,
      icon: EsikIcon.wifi,
    ),
    TriggerKind.nfcTag => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepNfcTitle,
      detail: l.stepNfcDetail,
      action: l.stepNfcAction,
      icon: EsikIcon.nfc,
    ),
    TriggerKind.alarmStopped => SetupStep(
      kind: SetupStepKind.trigger,
      title: l.stepAlarmTitle,
      detail: l.stepAlarmDetail,
      action: l.gotIt,
      icon: EsikIcon.alarm,
    ),
    _ => null,
  }?._forTrigger(kind);
  final only = kinds.length == 1 ? kinds.single : null;
  final test = SetupStep(
    kind: SetupStepKind.test,
    title: l.stepTestTitle,
    detail: switch (only) {
      TriggerKind.charging => l.stepTestCharging,
      TriggerKind.leftHomeWifi => l.stepTestWifi,
      TriggerKind.alarmStopped => l.stepTestAlarm,
      TriggerKind.silenced => l.stepTestSilenced,
      TriggerKind.unsilenced => l.stepTestUnsilenced,
      TriggerKind.nfcTag => l.stepTestNfc,
      null => l.stepTestMany,
      _ => l.stepTestOther,
    },
    action: only == TriggerKind.nfcTag ? l.finish : l.sendTest,
    icon: kinds.first.icon,
  );
  return [notifications, battery, for (final k in kinds) ?specific(k), test];
}

/// Adım telefonda gerçekten tamam mı? Denetlenemeyen adımlarda (bilgi,
/// deneme) ya da Android kanalı yoksa null.
bool? stepDone(SetupStep step, SetupHealth? h) {
  if (h == null) return null;
  return switch (step.kind) {
    SetupStepKind.notifications => h.notifications,
    SetupStepKind.battery => h.battery,
    SetupStepKind.trigger => switch (step.trigger) {
      TriggerKind.nfcTag => h.nfc == NfcState.on && h.nfcTagWritten,
      TriggerKind.alarmStopped => h.nextAlarm != null,
      _ => null,
    },
    SetupStepKind.test => null,
  };
}

class SetupGuideScreen extends ConsumerStatefulWidget {
  const SetupGuideScreen({super.key, this.mode});
  final DayMode? mode;

  @override
  ConsumerState<SetupGuideScreen> createState() => _SetupGuideScreenState();
}

class _SetupGuideScreenState extends ConsumerState<SetupGuideScreen> {
  int _current = 0;
  bool _busy = false;

  /// Gerçek durum ilk geldiğinde rehber ilk eksik adıma konumlanır.
  bool _positioned = false;

  /// Ayarlara gönderildi; dönünce adım tamamsa kendiliğinden ilerler.
  bool _awaitingSettings = false;

  /// Bu adımda bir şey denendi ama hâlâ eksik: "Atla" gösterilir.
  final _attempted = <int>{};

  /// Bildirim izni penceresi reddedildi; Android ikinci kez göstermeyebilir.
  bool _permissionDenied = false;

  /// Etiket yazılırken telefonun etikete yaklaştırılması bekleniyor.
  bool _waitingForTag = false;

  @override
  void dispose() {
    if (_waitingForTag) ref.read(nativeBridgeProvider).cancelNfcTag();
    super.dispose();
  }

  /// Adımın işini yapar, sonra bir sonraki adıma geçer.
  Future<void> _run(
    SetupStep step,
    DayMode mode,
    TriggerKind kind,
    int total,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    final bridge = ref.read(nativeBridgeProvider);
    final health = ref.read(setupHealthProvider).value;
    var advance = true;
    final l10n = context.l10n;
    // Ayar sayfasını aç; Android kanalı varsa dönüşte durum denetlenir.
    Future<void> viaSettings(Future<void> Function() open) async {
      await open();
      if (health != null) {
        advance = false;
        _awaitingSettings = true;
        _attempted.add(_current);
      }
    }

    if (stepDone(step, health) == true) {
      // Zaten tamam: yalnızca ilerle.
    } else {
      switch (step.kind) {
        case SetupStepKind.notifications:
          if (_permissionDenied || health?.notificationPermission == true) {
            await viaSettings(bridge.openNotificationSettings);
          } else if (await bridge.requestNotificationPermission()) {
            ref.invalidate(setupHealthProvider);
          } else {
            _permissionDenied = true;
            _attempted.add(_current);
            _snack(
              l10n.notifDenied,
              actionLabel: l10n.settings,
              onAction: bridge.openNotificationSettings,
            );
          }
        case SetupStepKind.battery:
          await viaSettings(bridge.openBatterySettings);
        case SetupStepKind.trigger:
          if (kind == TriggerKind.nfcTag && health?.nfc == NfcState.off) {
            await viaSettings(bridge.openNfcSettings);
          } else if (kind == TriggerKind.nfcTag) {
            advance = await _writeTag(bridge);
            if (advance) ref.invalidate(setupHealthProvider);
          } else if (kind == TriggerKind.alarmStopped && health != null) {
            await viaSettings(bridge.openClock);
          }
        case SetupStepKind.test:
          if (kind == TriggerKind.nfcTag) break;
          if (!await bridge.showTestNotification(mode)) {
            advance = false;
            _snack(
              l10n.testNotSent,
              actionLabel: l10n.settings,
              onAction: bridge.openNotificationSettings,
            );
          }
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (advance) _advance(total);
  }

  /// Durumu bilinen ilk eksik adım; hepsi tamamsa son adım.
  int _firstOpen(List<SetupStep> steps, SetupHealth h) {
    final i = steps.indexWhere((s) => stepDone(s, h) != true);
    return i < 0 ? steps.length - 1 : i;
  }

  /// Ana butonun etiketi: adımın gerçek durumuna göre.
  String _actionLabel(SetupStep step, SetupHealth? h, TriggerKind kind) {
    final l10n = context.l10n;
    if (stepDone(step, h) == true) return l10n.continueLabel;
    return switch (step.kind) {
      SetupStepKind.notifications
          when _permissionDenied || h?.notificationPermission == true =>
        l10n.openInSettings,
      SetupStepKind.trigger
          when kind == TriggerKind.nfcTag && h?.nfc == NfcState.off =>
        l10n.turnOnNfc,
      SetupStepKind.trigger
          when kind == TriggerKind.alarmStopped && h != null =>
        l10n.openClock,
      _ => step.action,
    };
  }

  /// Adımın açıklaması; telefonun durumu biliniyorsa ona göre.
  String _detail(SetupStep step, SetupHealth? h, TriggerKind kind) {
    if (h == null) return step.detail;
    final l10n = context.l10n;
    final now = ref.read(clockProvider)();
    return switch (step.kind) {
      SetupStepKind.notifications when h.notifications => l10n.detailNotifOn,
      SetupStepKind.notifications when h.notificationPermission =>
        l10n.detailNotifBlocked,
      SetupStepKind.battery when h.battery => l10n.detailBatteryOk,
      SetupStepKind.trigger when kind == TriggerKind.alarmStopped =>
        h.nextAlarm == null
            ? l10n.detailNoAlarm
            : l10n.detailNextAlarm(l10n.when(h.nextAlarm!, now)),
      SetupStepKind.trigger
          when kind == TriggerKind.nfcTag && h.nfc == NfcState.unsupported =>
        l10n.noNfc,
      SetupStepKind.trigger
          when kind == TriggerKind.nfcTag && h.nfc == NfcState.off =>
        l10n.detailNfcOff,
      SetupStepKind.trigger
          when kind == TriggerKind.nfcTag && h.nfcTagWritten =>
        l10n.detailTagWritten,
      _ => step.detail,
    };
  }

  /// Etiketi yazar; yazıldıysa true.
  Future<bool> _writeTag(NativeBridge bridge) async {
    setState(() => _waitingForTag = true);
    final result = await bridge.writeNfcTag();
    if (!mounted) return false;
    setState(() => _waitingForTag = false);
    switch (result) {
      case NfcWriteResult.written:
        HapticFeedback.heavyImpact();
        _snack(context.l10n.tagReady);
        return true;
      case NfcWriteResult.cancelled:
        break;
      case NfcWriteResult.disabled:
        _snack(
          context.l10n.nfcOffRetry,
          actionLabel: context.l10n.settings,
          onAction: bridge.openNfcSettings,
        );
      case NfcWriteResult.unsupported:
        _snack(context.l10n.noNfc);
      case NfcWriteResult.readOnly:
        _snack(context.l10n.tagReadOnly);
      case NfcWriteResult.tooSmall:
      case NfcWriteResult.incompatible:
        _snack(context.l10n.tagIncompatible);
      case NfcWriteResult.error:
        _snack(context.l10n.tagError);
    }
    return false;
  }

  void _snack(String text, {String? actionLabel, VoidCallback? onAction}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          content: Text(text),
          action: actionLabel == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction!),
        ),
      );
  }

  void _advance(int total) {
    HapticFeedback.mediumImpact();
    if (_current < total - 1) {
      setState(() => _current++);
    } else {
      context.go('/bugun');
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go('/bugun');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final DayMode mode = widget.mode ?? ref.watch(dayModeProvider);
    final kinds = ref.watch(triggerConfigProvider)[mode]!.kinds;
    final steps = setupStepsFor(l10n, kinds);
    final health = ref.watch(setupHealthProvider).value;
    if (health != null && !_positioned) {
      _positioned = true;
      _current = _firstOpen(steps, health);
    }
    // Ayarlardan dönüldü ve adım artık tamam: kendiliğinden ilerle.
    ref.listen(setupHealthProvider, (_, next) {
      final h = next.value;
      if (h == null || !_awaitingSettings) return;
      if (stepDone(steps[_current], h) == true) {
        _awaitingSettings = false;
        _advance(steps.length);
      }
    });
    // Ayar değişip adım sayısı azaldıysa sınırda kal.
    _current = _current.clamp(0, steps.length - 1);
    final step = steps[_current];
    // Adımın tetikleyicisi; ortak adımlarda ilk seçili tetikleyici.
    final kind = step.trigger ?? kinds.first;
    final done = stepDone(step, health);
    final skippable = _attempted.contains(_current) && done != true;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -420,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: l10n.setupTitle,
                  onBack: _close,
                  trailing: InfoChip(
                    label: l10n.stepOf(_current + 1, steps.length),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 12),
                    children: [
                      _StepVisual(step: step, kind: kind),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _waitingForTag ? l10n.holdToTag : step.title,
                          style: t.headlineMedium?.copyWith(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _waitingForTag
                              ? l10n.holdToTagDetail
                              : _detail(step, health, kind),
                          style: t.bodyMedium?.copyWith(color: p.textMuted),
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < steps.length; i++)
                        _TimelineRow(
                          index: i,
                          step: steps[i],
                          state: i == _current
                              ? _StepState.current
                              : switch (stepDone(steps[i], health)) {
                                  true => _StepState.done,
                                  false => _StepState.upcoming,
                                  null =>
                                    i < _current
                                        ? _StepState.done
                                        : _StepState.upcoming,
                                },
                          isLast: i == steps.length - 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: skippable
                          ? SecondaryPillButton(
                              label: l10n.skip,
                              icon: EsikIcon.arrowRight,
                              onPressed: () {
                                _awaitingSettings = false;
                                _advance(steps.length);
                              },
                            )
                          : SecondaryPillButton(
                              label: l10n.later,
                              icon: EsikIcon.clock,
                              onPressed: () => context.go('/bugun'),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 16,
                      child: _waitingForTag
                          ? SecondaryPillButton(
                              label: l10n.cancel,
                              icon: EsikIcon.nfc,
                              onPressed: () =>
                                  ref.read(nativeBridgeProvider).cancelNfcTag(),
                            )
                          : PrimaryPillButton(
                              label: _actionLabel(step, health, kind),
                              expand: true,
                              onPressed: _busy
                                  ? null
                                  : () => _run(step, mode, kind, steps.length),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepVisual extends StatelessWidget {
  const _StepVisual({required this.step, required this.kind});
  final SetupStep step;
  final TriggerKind kind;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.surfaceBorder),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.surfaceTop, p.surfaceBottom],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 340,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  p.accent.withValues(alpha: 0.45),
                  p.accent.withValues(alpha: 0.12),
                  p.accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          for (final r in [200.0, 150.0, 104.0])
            Container(
              width: r,
              height: r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.18 + (200 - r) / 800),
                ),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, a) => ScaleTransition(
              scale: a,
              child: FadeTransition(opacity: a, child: child),
            ),
            child: Container(
              key: ValueKey(step.title),
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.24, -0.36),
                  colors: [
                    Color(0xFFFFE7C2),
                    Color(0xFFFFB262),
                    Color(0xFFE5762C),
                  ],
                  stops: [0, 0.45, 1],
                ),
                boxShadow: [
                  BoxShadow(color: Color(0xB3FFA050), blurRadius: 50),
                ],
              ),
              child: Center(
                child: EsikIconView(
                  step.icon,
                  size: 34,
                  color: Colors.white,
                  strokeWidth: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.step,
    required this.state,
    required this.isLast,
  });

  final int index;
  final SetupStep step;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    final Widget node = switch (state) {
      _StepState.done => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: p.accentGradient,
          ),
        ),
        child: const Center(
          child: EsikIconView(
            EsikIcon.check,
            size: 12,
            color: Colors.white,
            strokeWidth: 3.2,
          ),
        ),
      ),
      _StepState.current => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.backgroundGradient.last,
          border: Border.all(color: p.accent, width: 2),
          boxShadow: [
            BoxShadow(color: p.accent.withValues(alpha: 0.7), blurRadius: 14),
          ],
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
          ),
        ),
      ),
      _StepState.upcoming => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.text.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(fontSize: 11, color: p.text),
          ),
        ),
      ),
    };

    return Semantics(
      label: l10n.stepA11y(index + 1, step.title, switch (state) {
        _StepState.done => l10n.stepStateDone,
        _StepState.current => l10n.stepStateCurrent,
        _StepState.upcoming => l10n.stepStateUpcoming,
      }),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 22,
              child: Column(
                children: [
                  node,
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: state == _StepState.done
                            ? p.accent.withValues(alpha: 0.8)
                            : p.text.withValues(alpha: 0.14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 22),
                child: Text(
                  step.title,
                  style: t.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: state == _StepState.current
                        ? FontWeight.w500
                        : FontWeight.w300,
                    color: state == _StepState.done ? p.textMuted : p.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
