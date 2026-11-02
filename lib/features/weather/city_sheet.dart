import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/weather.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';

/// Hava durumu için şehir seçimi. Konum izni istenmez.
Future<void> showCitySheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => const _CitySheet(),
);

/// Seçili şehir ve dokununca şehir seçimi; madde ve ayarlar ekranında.
class CityRow extends StatelessWidget {
  const CityRow({super.key, required this.place});
  final WeatherPlace? place;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return SurfaceCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      onTap: () => showCitySheet(context),
      child: Row(
        children: [
          EsikIconView(EsikIcon.cloud, size: 18, color: p.text),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              place?.name ?? l10n.weatherHintNoPlace,
              style: t.labelLarge?.copyWith(
                color: place == null ? p.accent : p.text,
              ),
            ),
          ),
          EsikIconView(EsikIcon.chevronRight, size: 16, color: p.text),
        ],
      ),
    );
  }
}

class _CitySheet extends ConsumerStatefulWidget {
  const _CitySheet();

  @override
  ConsumerState<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends ConsumerState<_CitySheet> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<WeatherPlace> _results = const [];
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await searchPlaces(text, context.l10n.localeName);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = text.trim().length >= 2;
      });
    });
  }

  Future<void> _pick(WeatherPlace? place) async {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
    await ref.read(weatherProvider.notifier).setPlace(place);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final current = ref.watch(weatherProvider).place;
    return Container(
      decoration: BoxDecoration(
        color: p.backgroundGradient.first,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: p.surfaceBorder),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.weatherTitle, style: t.titleLarge),
            const SizedBox(height: 6),
            Text(
              l10n.weatherCityHint,
              style: t.labelMedium?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              style: t.bodyLarge,
              cursorColor: p.accent,
              decoration: InputDecoration(
                hintText: l10n.weatherSearch,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: EsikIconView(EsikIcon.cloud, size: 18, color: p.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final place in _results)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                title: Text(place.name, style: t.bodyMedium),
                onTap: () => _pick(place),
              ),
            if (_searched && _results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  l10n.weatherNoResult,
                  style: t.labelMedium?.copyWith(color: p.textMuted),
                ),
              ),
            if (current != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _pick(null),
                child: Text(l10n.weatherRemove),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.weatherPrivacy,
              style: t.labelSmall?.copyWith(fontSize: 12, color: p.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}
