import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/day_mode.dart';
import 'router.dart';
import 'theme/esik_theme.dart';

class EsikApp extends ConsumerStatefulWidget {
  const EsikApp({super.key});

  @override
  ConsumerState<EsikApp> createState() => _EsikAppState();
}

class _EsikAppState extends ConsumerState<EsikApp> {
  // Uygulama arka plandan dönünce saati yeniden oku: gün ya da akşam/sabah
  // değişmiş olabilir.
  late final _lifecycle = AppLifecycleListener(
    onResume: () => ref.read(clockTickProvider.notifier).refresh(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
