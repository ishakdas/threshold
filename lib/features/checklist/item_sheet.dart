import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/day_mode.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/weather.dart';
import '../../l10n/texts.dart';
import '../../theme/esik_palette.dart';
import '../../ui/components.dart';
import '../../ui/esik_icons.dart';
import '../weather/city_sheet.dart';

/// Bir maddenin ayarları: ad, ikon, günler, hava koşulu, fotoğrafla kontrol.
Future<void> showItemSheet(
  BuildContext context,
  DayMode mode,
  CheckItem item,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _ItemSheet(mode: mode, item: item),
);

class _ItemSheet extends ConsumerStatefulWidget {
  const _ItemSheet({required this.mode, required this.item});
  final DayMode mode;
  final CheckItem item;

  @override
  ConsumerState<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends ConsumerState<_ItemSheet> {
  late final _title = TextEditingController(text: widget.item.title);
  late CheckItem _item = widget.item;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    ref
        .read(checklistProvider.notifier)
        .update(widget.mode, _item.copyWith(title: title));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final place = ref.watch(weatherProvider).place;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
      child: SectionTitle(text),
    );

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.itemEditTitle, style: t.titleLarge),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconCircle(icon: _item.icon, size: 46, active: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      style: t.bodyLarge,
                      cursorColor: p.accent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: checkItemIcons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final icon = checkItemIcons[i];
                    return Semantics(
                      button: true,
                      selected: icon == _item.icon,
                      label: icon.label(l10n),
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _item = _item.copyWith(icon: icon)),
                        child: IconCircle(
                          icon: icon,
                          size: 44,
                          active: icon == _item.icon,
                        ),
                      ),
                    );
                  },
                ),
              ),
              label(l10n.itemDays),
              WeekdayPicker(
                days: _item.days,
                onToggle: (d) {
                  final days = {..._item.days};
                  if (!days.remove(d)) days.add(d);
                  if (days.isEmpty) {
                    HapticFeedback.heavyImpact();
                    return;
                  }
                  HapticFeedback.selectionClick();
                  setState(() => _item = _item.copyWith(days: days));
                },
              ),
              label(l10n.itemWeather),
              ChoicePills<WeatherNeed>(
                values: WeatherNeed.values,
                value: _item.weather,
                label: (w) => w.label(l10n),
                expand: false,
                onChanged: (w) =>
                    setState(() => _item = _item.copyWith(weather: w)),
              ),
              if (_item.weather != WeatherNeed.always) ...[
                const SizedBox(height: 10),
                Text(
                  [
                    _item.weather.hint(l10n),
                    if (widget.mode == DayMode.evening) l10n.weatherHintEvening,
                  ].join(' '),
                  style: t.labelMedium?.copyWith(color: p.textMuted),
                ),
                const SizedBox(height: 8),
                CityRow(place: place),
              ],
              const SizedBox(height: 18),
              SurfaceCard(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                child: Row(
                  children: [
                    EsikIconView(EsikIcon.camera, size: 20, color: p.text),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.itemPhoto, style: t.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            l10n.itemPhotoHint,
                            style: t.labelMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    EsikSwitch(
                      value: _item.photo,
                      semanticLabel: l10n.itemPhoto,
                      onChanged: (v) =>
                          setState(() => _item = _item.copyWith(photo: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PrimaryPillButton(
                label: l10n.saveLabel,
                expand: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
