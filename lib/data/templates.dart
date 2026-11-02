import '../core/day_mode.dart';
import '../l10n/app_localizations.dart';
import '../ui/esik_icons.dart';
import 'models.dart';

/// Hazır şablon: birlikte eklenen birkaç madde. Maddeler uygulamanın dilinde
/// eklenir; kimlikleri eklenirken verilir.
class ChecklistTemplate {
  const ChecklistTemplate({
    required this.icon,
    required this.title,
    required this.items,
  });

  final EsikIcon icon;
  final String Function(AppLocalizations) title;
  final List<TemplateItem> items;

  /// Moda göre eklenecek maddeler.
  Map<DayMode, List<CheckItem>> build(AppLocalizations l) => {
    for (final mode in DayMode.values)
      mode: [
        for (final i in items)
          if (i.mode == mode)
            CheckItem(
              id: '',
              title: i.title(l),
              icon: i.icon,
              days: i.days,
              weather: i.weather,
              photo: i.photo,
            ),
      ],
  };
}

class TemplateItem {
  const TemplateItem(
    this.mode,
    this.title,
    this.icon, {
    this.days = allWeekdays,
    this.weather = WeatherNeed.always,
    this.photo = false,
  });

  final DayMode mode;
  final String Function(AppLocalizations) title;
  final EsikIcon icon;
  final Set<int> days;
  final WeatherNeed weather;
  final bool photo;
}

const _weekdays = {1, 2, 3, 4, 5};

final checklistTemplates = <ChecklistTemplate>[
  ChecklistTemplate(
    icon: EsikIcon.lock,
    title: (l) => l.tplHome,
    items: [
      TemplateItem(DayMode.evening, (l) => l.tplStove, EsikIcon.flame),
      TemplateItem(DayMode.evening, (l) => l.tplIron, EsikIcon.iron),
      TemplateItem(DayMode.evening, (l) => l.tplWindows, EsikIcon.checklist),
      TemplateItem(DayMode.evening, (l) => l.tplLights, EsikIcon.bulb),
      TemplateItem(DayMode.morning, (l) => l.tplStove, EsikIcon.flame),
      TemplateItem(
        DayMode.morning,
        (l) => l.tplDoor,
        EsikIcon.lock,
        photo: true,
      ),
    ],
  ),
  ChecklistTemplate(
    icon: EsikIcon.key,
    title: (l) => l.tplLeaving,
    items: [
      TemplateItem(DayMode.morning, (l) => l.tplKeys, EsikIcon.key),
      TemplateItem(DayMode.morning, (l) => l.tplWallet, EsikIcon.wallet),
      TemplateItem(DayMode.morning, (l) => l.tplCharger, EsikIcon.plug),
      TemplateItem(
        DayMode.morning,
        (l) => l.tplBadge,
        EsikIcon.bag,
        days: _weekdays,
      ),
    ],
  ),
  ChecklistTemplate(
    icon: EsikIcon.umbrella,
    title: (l) => l.tplWeather,
    items: [
      TemplateItem(
        DayMode.morning,
        (l) => l.tplUmbrella,
        EsikIcon.umbrella,
        weather: WeatherNeed.rain,
      ),
      TemplateItem(
        DayMode.morning,
        (l) => l.tplCoat,
        EsikIcon.coat,
        weather: WeatherNeed.cold,
      ),
      TemplateItem(
        DayMode.morning,
        (l) => l.tplWater,
        EsikIcon.drop,
        weather: WeatherNeed.hot,
      ),
    ],
  ),
  ChecklistTemplate(
    icon: EsikIcon.pill,
    title: (l) => l.tplHealth,
    items: [
      TemplateItem(DayMode.morning, (l) => l.tplPillMorning, EsikIcon.pill),
      TemplateItem(DayMode.evening, (l) => l.tplPillEvening, EsikIcon.pill),
    ],
  ),
  ChecklistTemplate(
    icon: EsikIcon.paw,
    title: (l) => l.tplPet,
    items: [
      TemplateItem(DayMode.evening, (l) => l.tplPetFood, EsikIcon.paw),
      TemplateItem(DayMode.morning, (l) => l.tplPetInside, EsikIcon.paw),
    ],
  ),
  ChecklistTemplate(
    icon: EsikIcon.bag,
    title: (l) => l.tplSport,
    items: [
      TemplateItem(
        DayMode.morning,
        (l) => l.tplGymBag,
        EsikIcon.bag,
        days: {2, 4},
      ),
    ],
  ),
];
