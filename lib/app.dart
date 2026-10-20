import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/day_mode.dart';
import 'router.dart';
import 'theme/esik_theme.dart';

class EsikApp extends ConsumerWidget {
  const EsikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
