import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../../ui/esik_logo.dart';
import '../../ui/threshold_door.dart';

/// İlk açılışta gösterilen üç sayfa: ne yapar, örnek senaryo, bildirim izni.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish(String to) async {
    await ref.read(onboardingSeenProvider.notifier).complete();
    if (mounted) context.go(to);
  }

  void _go(int i) {
    HapticFeedback.selectionClick();
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final last = _index == 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -60,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (_index > 0)
                      IconButton(
                        tooltip: 'Geri',
                        onPressed: () => _go(_index - 1),
                        icon: EsikIconView(EsikIcon.arrowLeft, color: p.text),
                      ),
                    const Spacer(),
                    if (!last)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextButton(
                          onPressed: () => _finish('/bugun'),
                          style: TextButton.styleFrom(
                            foregroundColor: p.text,
                            backgroundColor: p.chip,
                            shape: StadiumBorder(
                              side: BorderSide(color: p.chipBorder),
                            ),
                            minimumSize: const Size(0, 34),
                          ),
                          child: const Text('Atla'),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: const [
                    _IntroPage(),
                    _ScenarioPage(),
                    _NotifyPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                child: last
                    ? Column(
                        children: [
                          _Dots(index: _index),
                          const SizedBox(height: 18),
                          PrimaryPillButton(
                            label: 'Kuruluma başla',
                            icon: EsikIcon.bell,
                            height: 56,
                            expand: true,
                            onPressed: () => _finish('/kurulum'),
                          ),
                          TextButton(
                            onPressed: () => _finish('/bugun'),
                            style: TextButton.styleFrom(
                              foregroundColor: p.textMuted,
                              minimumSize: const Size(0, 44),
                            ),
                            child: Text(
                              'Şimdi değil',
                              style: t.bodyMedium?.copyWith(color: p.textMuted),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _Dots(index: _index),
                          const Spacer(),
                          _SquareButton(
                            icon: EsikIcon.arrowLeft,
                            label: 'Geri',
                            onTap: _index == 0 ? null : () => _go(_index - 1),
                          ),
                          const SizedBox(width: 10),
                          _SquareButton(
                            icon: EsikIcon.arrowRight,
                            label: 'İleri',
                            primary: true,
                            onTap: () => _go(_index + 1),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Sayfa ${index + 1} / 3',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: i == index ? 34 : 18,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i == index ? p.text : p.text.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.primary = false,
  });
  final EsikIcon icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: primary ? p.primaryButton : p.chip.withValues(alpha: 0.35),
            border: primary ? null : Border.all(color: p.chipBorder),
          ),
          child: Center(
            child: EsikIconView(
              icon,
              size: 20,
              strokeWidth: 1.8,
              color: primary
                  ? p.onPrimaryButton
                  : p.text.withValues(alpha: enabled ? 1 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sayfa düzeni: üstte görsel, altta sola yaslı büyük başlık ve açıklama.
class _Page extends StatelessWidget {
  const _Page({
    required this.visual,
    required this.kicker,
    required this.title,
    required this.body,
  });
  final Widget visual;
  final String kicker;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: visual)),
          DotLabel(kicker),
          const SizedBox(height: 10),
          Text(
            title,
            style: t.headlineLarge?.copyWith(fontSize: 40, height: 1.12),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: t.bodyLarge?.copyWith(fontSize: 15, color: p.textMuted),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    return const _Page(
      kicker: 'Eşik’e hoş geldin',
      title: 'Yatmadan önce.\nKapıdan çıkmadan önce.',
      body: 'Günün iki eşiğinde kendi kontrol listen, tam doğru anda önünde.',
      visual: FittedBox(child: ThresholdDoor(doorWidth: 150, doorHeight: 270)),
    );
  }
}

class _ScenarioPage extends StatelessWidget {
  const _ScenarioPage();

  @override
  Widget build(BuildContext context) {
    return const _Page(
      kicker: 'Örnek senaryo',
      title: 'Saat değil, an.',
      body: '22:30 alarmı sen dizideyken çalar. Eşik ise telefonu şarja taktığın an gelir; üç maddeye bakar, rahat uyursun.',
      visual: _GhostWithCallouts(),
    );
  }
}

/// Işıktan bir siluet ve üzerinde anın etiketleri.
class _GhostWithCallouts extends StatelessWidget {
  const _GhostWithCallouts();

  static const _figure =
      'M50 38c-14 0-24 6-27 20l-9 50c-1 5 6 7 8 2l9-38 2 40-4 86h14l7-70 7 70h14l-4-86 2-40 9 38c2 5 9 3 8-2l-9-50c-3-14-13-20-27-20z';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 200"><defs>'
        '<linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" stop-color="#FFF4E4" stop-opacity="0.95"/>'
        '<stop offset="0.55" stop-color="#FFD1A0" stop-opacity="0.7"/>'
        '<stop offset="1" stop-color="#F29A4A" stop-opacity="0.05"/></linearGradient></defs>'
        '<circle cx="50" cy="22" r="13" fill="url(#g)"/><path d="$_figure" fill="url(#g)"/></svg>';

    Widget callout(String title, String sub) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: p.chip.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.chipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: p.text)),
          Text(sub, style: TextStyle(fontSize: 11, color: p.textMuted)),
        ],
      ),
    );

    Widget dot() => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.text.withValues(alpha: 0.8)),
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: p.text, shape: BoxShape.circle),
        ),
      ),
    );

    return ExcludeSemantics(
      child: FittedBox(
        child: SizedBox(
          width: 330,
          height: 360,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 15,
                top: 0,
                width: 300,
                height: 360,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        p.accent.withValues(alpha: 0.4),
                        p.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 70,
                top: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: SvgPicture.string(svg, width: 190, height: 380),
                ),
              ),
              Positioned(left: 172, top: 40, child: dot()),
              Positioned(
                left: 186,
                top: 46,
                child: Container(
                  width: 26,
                  height: 1,
                  color: p.text.withValues(alpha: 0.45),
                ),
              ),
              Positioned(
                left: 212,
                top: 22,
                child: callout('Şarja taktın', '22:47 · eşik'),
              ),
              Positioned(left: 128, top: 128, child: dot()),
              Positioned(
                left: 102,
                top: 134,
                child: Container(
                  width: 26,
                  height: 1,
                  color: p.text.withValues(alpha: 0.45),
                ),
              ),
              Positioned(left: 10, top: 112, child: callout('Kapı', 'Kilitli')),
              Positioned(left: 206, top: 190, child: dot()),
              Positioned(
                left: 220,
                top: 196,
                child: Container(
                  width: 20,
                  height: 1,
                  color: p.text.withValues(alpha: 0.45),
                ),
              ),
              Positioned(
                left: 240,
                top: 174,
                child: callout('Ütü', 'Fiş çekildi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifyPage extends StatelessWidget {
  const _NotifyPage();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _Page(
      kicker: 'Son adım',
      title: 'Doğru anda\nhaber verelim.',
      body: 'Sadece eşik geldiğinde yazarız. Günde en fazla iki bildirim, reklam yok.',
      visual: ExcludeSemantics(
        child: FittedBox(
          child: SizedBox(
            width: 340,
            height: 360,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final r in [340.0, 250.0, 164.0])
                  Container(
                    width: r,
                    height: r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.text.withValues(alpha: 0.02),
                      border: Border.all(
                        color: p.accent.withValues(
                          alpha: 0.12 + (340 - r) / 1400,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 108,
                  height: 108,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.2, -0.3),
                      colors: [
                        Color(0xFFFFE7C2),
                        Color(0xFFFFB262),
                        Color(0xFFE5762C),
                      ],
                      stops: [0, 0.45, 1],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0xB3FFA050), blurRadius: 60),
                    ],
                  ),
                  child: const Center(
                    child: EsikIconView(
                      EsikIcon.bell,
                      size: 42,
                      color: Colors.white,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.glassFill,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: p.glassBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: const Color(0xFF0B1029),
                              ),
                              child: const Center(
                                child: EsikLogo(archColor: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Akşam eşiği',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: p.text,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'şimdi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: p.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Şarja taktın. Ütü, yapılacaklar, kapı: 3 madde.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: p.text.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
