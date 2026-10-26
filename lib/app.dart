import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/day_mode.dart';
import 'data/app_state.dart';
import 'data/plus.dart';
import 'l10n/app_localizations.dart';
import 'platform/billing.dart';
import 'platform/native_bridge.dart';
import 'router.dart';
import 'theme/esik_theme.dart';

class EsikApp extends ConsumerStatefulWidget {
  const EsikApp({super.key});

  @override
  ConsumerState<EsikApp> createState() => _EsikAppState();
}

class _EsikAppState extends ConsumerState<EsikApp> {
  // Uygulama arka plandan dönünce: Android tarafı kaydı değiştirmiş olabilir
  // (bildirimdeki "Hepsi tamam"), gün ya da akşam/sabah değişmiş olabilir.
  late final _lifecycle = AppLifecycleListener(onResume: _reloadData);

  NativeBridge get _bridge => ref.read(nativeBridgeProvider);

  /// Test APK'sında deneme dakikayla bittiği için ekran her yarım dakikada
  /// bir tazelenir; normal sürümde yok.
  Timer? _testTick;

  @override
  void initState() {
    super.initState();
    _lifecycle;
    _bridge.listen(onOpenRoute: _openRoute, onDataChanged: _reloadData);
    if (trialMinutesOverride > 0) {
      _testTick = Timer.periodic(
        const Duration(seconds: 30),
        (_) => ref.read(clockTickProvider.notifier).refresh(),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_reschedule());
      unawaited(ref.read(plusBillingProvider.notifier).start());
      unawaited(_syncTrial());
      final route = await _bridge.takeLaunchRoute();
      if (route != null) _openRoute(route);
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _testTick?.cancel();
    super.dispose();
  }

  Future<void> _reschedule() async {
    await ref.read(triggerConfigProvider.notifier).saved;
    await _bridge.reschedule();
    if (mounted) ref.invalidate(thresholdStatusProvider);
  }

  /// Android deneme başlangıcını diske yazdıysa yeniden oku.
  Future<void> _syncTrial() async {
    if (await _bridge.syncTrial() == null || !mounted) return;
    await ref.read(sharedPreferencesProvider).reload();
    if (mounted) {
      ref.invalidate(trialStartProvider);
      ref.invalidate(plusProvider);
    }
  }

  void _openRoute(String route) {
    if (!mounted) return;
    ref.read(routerProvider).push(route);
  }

  Future<void> _reloadData() async {
    await ref.read(sharedPreferencesProvider).reload();
    if (!mounted) return;
    ref.invalidate(checkLogProvider);
    ref.read(clockTickProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Eşik ayarı değişince, ayar diske yazıldıktan sonra Android'deki yedek
    // alarmları ve tetikleyici işlerini yeniden kur.
    ref.listen(triggerConfigProvider, (_, _) => _reschedule());
    // Plus açılınca ya da kapanınca Android tetikleyicileri buna göre kurulur.
    ref.listen(plusProvider.select((p) => p.active), (_, _) => _reschedule());
    final mode = ref.watch(dayModeProvider);
    return MaterialApp.router(
      title: 'Eşik',
      debugShowCheckedModeBanner: false,
      theme: esikTheme(mode),
      themeAnimationDuration: const Duration(milliseconds: 450),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
