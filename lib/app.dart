import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/day_mode.dart';
import 'data/app_state.dart';
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

  @override
  void initState() {
    super.initState();
    _lifecycle;
    _bridge.listen(onOpenRoute: _openRoute, onDataChanged: _reloadData);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_reschedule());
      final route = await _bridge.takeLaunchRoute();
      if (route != null) _openRoute(route);
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _reschedule() async {
    await ref.read(triggerConfigProvider.notifier).saved;
    await _bridge.rescheduleBackups();
    if (mounted) ref.invalidate(backupStatusProvider);
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
    // Yedek saat ya da açık/kapalı değişince, ayar diske yazıldıktan sonra
    // Android alarmlarını yeniden kur.
    ref.listen(triggerConfigProvider, (_, _) => _reschedule());
    final mode = ref.watch(dayModeProvider);
    return MaterialApp.router(
      title: 'Eşik',
      debugShowCheckedModeBanner: false,
      theme: esikTheme(mode),
      themeAnimationDuration: const Duration(milliseconds: 450),
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
