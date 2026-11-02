import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/plus.dart';
import '../../data/reminders.dart';
import '../../data/weather.dart';
import '../../l10n/texts.dart';
import '../../platform/native_bridge.dart';
import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../plus/plus_sheet.dart';
import '../today/widget_tip.dart';
import '../weather/city_sheet.dart';

/// Uygulamanın geneli: Plus, tekrar hatırlatma, sessizdeyken, hava durumu,
/// widget, dil ve iletişim. Eşiklere özel ayarlar Eşikler sekmesinde.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -420,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              ScreenHeader(
                title: l10n.appSettingsTitle,
                onBack: () =>
                    context.canPop() ? context.pop() : context.go('/ayarlar'),
              ),
              const SizedBox(height: 12),
              const _ReminderCard(),
              const SizedBox(height: 10),
              // iOS'ta bildirim telefonun sessiz ayarını aşamaz.
              if (!isIOS) ...[
                const _SilentAlertCard(),
                const SizedBox(height: 10),
              ],
              const _WeatherCard(),
              const SizedBox(height: 10),
              if (!isIOS) ...[const _WidgetCard(), const SizedBox(height: 10)],
              const _LanguageCard(),
              const SizedBox(height: 10),
              const _ContactCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Geliştiriciye e-posta: telefondaki e-posta uygulamasını açar.
class _ContactCard extends ConsumerWidget {
  const _ContactCard();

  static const email = 'developerishak@gmail.com';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      onTap: () async {
        final opened = await ref
            .read(nativeBridgeProvider)
            .sendFeedback(email: email, subject: l10n.contactSubject);
        if (opened || !context.mounted) return;
        await Clipboard.setData(const ClipboardData(text: email));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.contactNoApp(email))));
      },
      child: Row(
        children: [
          EsikIconView(EsikIcon.mail, size: 18, color: p.text),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.contactTitle, style: t.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  l10n.contactSubtitle,
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          EsikIconView(EsikIcon.chevronRight, size: 16, color: p.text),
        ],
      ),
    );
  }
}

/// Israrcı hatırlatma: kaç bildirim, kaç dakika arayla. İki mod için ortak.
class _ReminderCard extends ConsumerWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final r = ref.watch(reminderProvider);
    final notifier = ref.read(reminderProvider.notifier);
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.bellRing, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.remindTitle, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<int>(
            values: const [1, 2, 3, 4, 5],
            value: r.max,
            label: (n) => '$n',
            onChanged: (n) =>
                notifier.set(ReminderSettings(max: n, minutes: r.minutes)),
          ),
          if (r.max > 1) ...[
            const SizedBox(height: 10),
            ChoicePills<int>(
              values: ReminderSettings.minuteChoices,
              value: r.minutes,
              label: (m) => l10n.remindEvery(m),
              expand: false,
              onChanged: (m) =>
                  notifier.set(ReminderSettings(max: r.max, minutes: m)),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            r.max == 1 ? l10n.remindHintOff : l10n.remindHint(r.minutes, r.max),
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hava durumuna göre çıkan maddeler için şehir.
class _WeatherCard extends ConsumerWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final weather = ref.watch(weatherProvider);
    final today = weather.on(ref.watch(todayProvider));
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      onTap: () => showCitySheet(context),
      child: Row(
        children: [
          EsikIconView(EsikIcon.cloud, size: 18, color: p.text),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.weatherTitle, style: t.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  [
                    weather.place?.name ?? l10n.weatherNoCity,
                    if (today != null)
                      l10n.weatherToday(
                        today.rainChance,
                        today.minTemp.round(),
                        today.maxTemp.round(),
                      ),
                  ].join(' · '),
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          EsikIconView(EsikIcon.chevronRight, size: 16, color: p.text),
        ],
      ),
    );
  }
}

/// Android: ana ekrana Eşik widget'ını ekler.
class _WidgetCard extends ConsumerWidget {
  const _WidgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      onTap: () => addEsikWidget(context, ref),
      child: Row(
        children: [
          EsikIconView(EsikIcon.widget, size: 18, color: p.text),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.widgetTitle, style: t.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  l10n.widgetTipBody,
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          EsikIconView(EsikIcon.plus, size: 18, color: p.accent),
        ],
      ),
    );
  }
}

/// Uygulamanın dili: telefonunki ya da seçilen.
class _LanguageCard extends ConsumerWidget {
  const _LanguageCard();

  /// Diller her zaman kendi adlarıyla yazılır; yalnızca "Sistem" çevrilir.
  static String _name(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => l10n.languageSystem,
        AppLanguage.tr => 'Türkçe',
        AppLanguage.en => 'English',
        AppLanguage.es => 'Español',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.globe, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.language, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<AppLanguage>(
            values: AppLanguage.values,
            value: ref.watch(languageProvider),
            label: (lang) => _name(l10n, lang),
            expand: false,
            onChanged: ref.read(languageProvider.notifier).set,
          ),
        ],
      ),
    );
  }
}

/// Telefon sessizdeyken bildirim titresin ya da çalsın mı? İki mod için ortak.
class _SilentAlertCard extends ConsumerWidget {
  const _SilentAlertCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final value = ref.watch(effectiveSilentAlertProvider);
    final plus = ref.watch(plusProvider).active;
    final muted =
        value == SilentAlert.ring &&
        ref.watch(setupHealthProvider).value?.alarmVolume == 0;
    return SurfaceCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EsikIconView(EsikIcon.vibrate, size: 18, color: p.text),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.whenSilent, style: t.bodyMedium)),
              PlusBadge(owned: plus),
            ],
          ),
          const SizedBox(height: 12),
          ChoicePills<SilentAlert>(
            values: SilentAlert.values,
            value: value,
            label: (a) => a.label(l10n),
            icon: (a) => a.icon,
            onChanged: (v) => !plus && v != SilentAlert.quiet
                ? showPlusSheet(context)
                : ref.read(silentAlertProvider.notifier).set(v),
          ),
          const SizedBox(height: 10),
          Text(
            switch (value) {
              SilentAlert.quiet => l10n.silentQuietHint,
              SilentAlert.vibrate => l10n.silentVibrateHint,
              SilentAlert.ring when muted => l10n.silentMutedHint,
              SilentAlert.ring => l10n.silentRingHint,
            },
            style: t.labelMedium?.copyWith(
              fontWeight: muted ? FontWeight.w400 : FontWeight.w300,
              color: muted ? p.accent : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
