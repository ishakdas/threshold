import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_state.dart';
import 'ui/esik_logo.dart';

/// Uygulamanın ilk karesini hemen çizer, kalıcı ayarları arkada yükler.
///
/// Yükleme takılır ya da hata verirse kullanıcı açılış ekranında kalmaz;
/// hatanın metni ekranda gösterilir ve tekrar denenebilir.
class EsikBootstrap extends StatefulWidget {
  const EsikBootstrap({
    super.key,
    this.loadPreferences = SharedPreferences.getInstance,
    this.timeout = const Duration(seconds: 5),
  });

  final Future<SharedPreferences> Function() loadPreferences;
  final Duration timeout;

  @override
  State<EsikBootstrap> createState() => _EsikBootstrapState();
}

class _EsikBootstrapState extends State<EsikBootstrap> {
  SharedPreferences? _prefs;
  Object? _error;
  StackTrace? _stack;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _stack = null;
    });
    try {
      final prefs = await widget.loadPreferences().timeout(widget.timeout);
      if (mounted) setState(() => _prefs = prefs);
    } catch (e, s) {
      if (mounted) {
        setState(() {
          _error = e;
          _stack = s;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs != null) {
      return ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const EsikApp(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
      home: _error == null
          ? const _Splash()
          : StartupErrorScreen(error: _error!, stack: _stack, onRetry: _load),
    );
  }
}

/// Sistem açılış ekranıyla aynı görünüm: lacivert zemin, ortada logo.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF0B1029),
      child: Center(child: EsikLogo(size: 48, archColor: Color(0xFFF5EFE6))),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
    this.stack,
    required this.onRetry,
  });

  final Object error;
  final StackTrace? stack;
  final VoidCallback onRetry;

  String get _report => error is TimeoutException
      ? 'Ayarlar zamanında yüklenemedi.\n$error'
      : '$error\n\n${stack ?? ''}';

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFF5EFE6);
    return Scaffold(
      backgroundColor: const Color(0xFF0B1029),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EsikLogo(size: 32, archColor: text),
              const SizedBox(height: 20),
              const Text(
                'Eşik başlatılamadı',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aşağıdaki metni kopyalayıp geliştiriciye gönderebilirsin.',
                style: TextStyle(fontSize: 14, color: Color(0xB3F5EFE6)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _report,
                      style: const TextStyle(
                        fontSize: 12,
                        color: text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: _report)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        minimumSize: const Size(0, 52),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Hatayı kopyala'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B1029),
                        minimumSize: const Size(0, 52),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Tekrar dene'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
