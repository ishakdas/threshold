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

/// Adımın ana butonunun ne yapacağı.
enum SetupStepKind { notifications, battery, trigger, test }

class SetupStep {
  const SetupStep({
    required this.kind,
    required this.title,
    required this.detail,
    required this.action,
    required this.icon,
  });

  final SetupStepKind kind;
  final String title;
  final String detail;

  /// Ana butonun etiketi.
  final String action;
  final EsikIcon icon;
}

/// Seçilen tetikleyicinin Android'de çalışması için gereken adımlar.
/// Kısayollar'ın olmadığı Android'de iOS'taki kurulum rehberinin karşılığıdır.
List<SetupStep> setupStepsFor(TriggerKind kind) {
  const notifications = SetupStep(
    kind: SetupStepKind.notifications,
    title: 'Bildirimlere izin ver',
    detail: 'Eşik yalnızca eşik geldiğinde yazar. Günde en fazla iki bildirim.',
    action: 'İzin ver',
    icon: EsikIcon.bell,
  );
  const battery = SetupStep(
    kind: SetupStepKind.battery,
    title: 'Arka planda çalışmasına izin ver',
    detail: 'Samsung pil tasarrufu uygulamaları uyutabilir. Eşik’i “Uyku moduna alınmayan uygulamalar” listesine ekle.',
    action: 'Pil ayarını aç',
    icon: EsikIcon.battery,
  );
  final specific = switch (kind) {
    TriggerKind.appClosed => const SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Kullanım erişimi ver',
      detail: 'Instagram’ın kapandığını anlamak için hangi uygulamanın açık olduğunu görmemiz gerekir.',
      action: 'Kullanım erişimini aç',
      icon: EsikIcon.app,
    ),
    TriggerKind.silenced || TriggerKind.unsilenced => SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Ek izin gerekmez',
      detail: kind == TriggerKind.silenced
          ? 'Akşam aralığında telefonun sesini bir kademe kısınca (sesliden titreşime, titreşimden sessize) ya da Rahatsız Etmeyin açılınca Eşik bunu fark eder.'
          : 'Sabah aralığında telefonun sesini bir kademe açınca (sessizden titreşime, titreşimden sesliye) ya da Rahatsız Etmeyin kapanınca Eşik bunu fark eder.',
      action: 'Anladım',
      icon: kind.icon,
    ),
    TriggerKind.sleepMode => const SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Bildirim erişimi ver',
      detail: 'Uyku modu açıldığında haberimiz olsun diye. Bildirimlerinin içeriği okunmaz.',
      action: 'Erişimi aç',
      icon: EsikIcon.bed,
    ),
    TriggerKind.leftHomeWifi => const SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Mobil veri açık kalsın',
      detail: 'Sabah aralığında evin Wi‑Fi’ına bağlıyken Eşik hazırda bekler; bağlantı kopup telefon mobil veriye geçince hatırlatır. Wi‑Fi adı okunmaz, konum izni gerekmez.',
      action: 'Anladım',
      icon: EsikIcon.wifi,
    ),
    TriggerKind.nfcTag => const SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Etiketi hazırla',
      detail: 'Boş bir NFC etiketini telefonun arkasına tut; Eşik etikete kendi bağlantısını yazar.',
      action: 'Etiketi yaz',
      icon: EsikIcon.nfc,
    ),
    TriggerKind.alarmStopped => const SetupStep(
      kind: SetupStepKind.trigger,
      title: 'Sabah alarmın kurulu olsun',
      detail: 'Ek izin gerekmez. Saat uygulamasındaki alarm çalıp kapandığında Eşik bunu fark eder. Ertelersen son çalışı bekler.',
      action: 'Anladım',
      icon: EsikIcon.alarm,
    ),
    _ => null,
  };
  final test = SetupStep(
    kind: SetupStepKind.test,
    title: 'Dene',
    detail: switch (kind) {
      TriggerKind.charging => 'Önce deneme bildirimi. Gerçeği, seçtiğin saat aralığında telefonu şarja taktıktan sonra birkaç dakika içinde gelir.',
      TriggerKind.leftHomeWifi => 'Önce deneme bildirimi. Gerçeği, sabah aralığında Wi‑Fi’ı kapatıp mobil veriye geçince gelir.',
      TriggerKind.alarmStopped => 'Önce deneme bildirimi. Gerçeği, sabah aralığında çalan bir alarmı kapattıktan sonra gelir.',
      TriggerKind.silenced => 'Önce deneme bildirimi. Gerçeği, akşam aralığında telefonun sesini kıstığında birkaç saniye içinde gelir.',
      TriggerKind.unsilenced => 'Önce deneme bildirimi. Gerçeği, sabah aralığında telefonun sesini açtığında birkaç saniye içinde gelir.',
      TriggerKind.nfcTag => 'Uygulamadan çık, kilidi açık telefonu etikete dokundur. Kontrol ekranı açılmalı.',
      _ => 'Deneme bildirimi gönderelim; gerçek tetikleyici de aynı şekilde gelecek.',
    },
    action: kind == TriggerKind.nfcTag ? 'Bitir' : 'Deneme bildirimi gönder',
    icon: kind.icon,
  );
  return [notifications, battery, ?specific, test];
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
    var advance = true;
    switch (step.kind) {
      case SetupStepKind.notifications:
        if (!await bridge.requestNotificationPermission()) {
          _snack(
            'Bildirim izni verilmedi. İstersen ayarlardan açabilirsin.',
            actionLabel: 'Ayarlar',
            onAction: bridge.openNotificationSettings,
          );
        }
      case SetupStepKind.battery:
        await bridge.openBatterySettings();
      case SetupStepKind.trigger:
        if (kind == TriggerKind.nfcTag) advance = await _writeTag(bridge);
      case SetupStepKind.test:
        if (kind == TriggerKind.nfcTag) break;
        if (!await bridge.showTestNotification(mode)) {
          advance = false;
          _snack(
            'Bildirim gönderilemedi: bildirim izni kapalı.',
            actionLabel: 'Ayarlar',
            onAction: bridge.openNotificationSettings,
          );
        }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (advance) _advance(total);
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
        _snack('Etiket hazır. Kapının yanına yapıştırabilirsin.');
        return true;
      case NfcWriteResult.cancelled:
        break;
      case NfcWriteResult.disabled:
        _snack(
          'NFC kapalı. Açıp tekrar dene.',
          actionLabel: 'Ayarlar',
          onAction: bridge.openNfcSettings,
        );
      case NfcWriteResult.unsupported:
        _snack('Bu telefonda NFC yok. Başka bir sabah tetikleyicisi seç.');
      case NfcWriteResult.readOnly:
        _snack('Bu etiket kilitli, üzerine yazılamıyor. Boş bir etiket dene.');
      case NfcWriteResult.tooSmall:
      case NfcWriteResult.incompatible:
        _snack('Bu etiket uygun değil. NTAG213 ya da benzeri bir etiket dene.');
      case NfcWriteResult.error:
        _snack('Yazılamadı. Telefonu etikete biraz daha uzun tut.');
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
    final DayMode mode = widget.mode ?? ref.watch(dayModeProvider);
    final kind = ref.watch(triggerConfigProvider)[mode]!.kind;
    final steps = setupStepsFor(kind);
    final step = steps[_current];
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
                  title: 'Kurulum',
                  onBack: _close,
                  trailing: InfoChip(
                    label: 'Adım ${_current + 1} / ${steps.length}',
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
                          _waitingForTag ? 'Etikete yaklaştır' : step.title,
                          style: t.headlineMedium?.copyWith(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _waitingForTag
                              ? 'Telefonun arkasını etikete değdir ve titreşimi bekle.'
                              : step.detail,
                          style: t.bodyMedium?.copyWith(color: p.textMuted),
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < steps.length; i++)
                        _TimelineRow(
                          index: i,
                          step: steps[i],
                          state: i < _current
                              ? _StepState.done
                              : i == _current
                              ? _StepState.current
                              : _StepState.upcoming,
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
                      child: SecondaryPillButton(
                        label: 'Sonra',
                        icon: EsikIcon.clock,
                        onPressed: () => context.go('/bugun'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 16,
                      child: _waitingForTag
                          ? SecondaryPillButton(
                              label: 'Vazgeç',
                              icon: EsikIcon.nfc,
                              onPressed: () =>
                                  ref.read(nativeBridgeProvider).cancelNfcTag(),
                            )
                          : PrimaryPillButton(
                              label: step.action,
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
      label:
          '${index + 1}. adım, ${step.title}, ${switch (state) {
            _StepState.done => 'tamamlandı',
            _StepState.current => 'şu anki adım',
            _StepState.upcoming => 'sırada',
          }}',
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
