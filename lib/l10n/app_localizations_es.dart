// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get triggerChargingTitle => 'Al cargar';

  @override
  String get triggerChargingSubtitle => 'Junto a la cama';

  @override
  String get triggerChargingWhen => 'Cuando pongas el teléfono a cargar';

  @override
  String get triggerSilencedTitle => 'Al silenciar';

  @override
  String get triggerSilencedSubtitle => 'Bajar el sonido';

  @override
  String get triggerSilencedWhen => 'Cuando silencies el teléfono';

  @override
  String get triggerAppClosedTitle => 'Al cerrar una app';

  @override
  String get triggerAppClosedSubtitle => 'Instagram';

  @override
  String get triggerAppClosedWhen => 'Cuando cierres Instagram';

  @override
  String get triggerSleepModeTitle => 'Modo descanso';

  @override
  String get triggerSleepModeSubtitle => 'Al activarse';

  @override
  String get triggerSleepModeWhen => 'Cuando se active el modo descanso';

  @override
  String get triggerAirplaneModeTitle => 'Modo avión';

  @override
  String get triggerAirplaneModeSubtitle => 'Al activarse';

  @override
  String get triggerAirplaneModeWhen => 'Cuando actives el modo avión';

  @override
  String get triggerAlarmStoppedTitle => 'Al apagar la alarma';

  @override
  String get triggerAlarmStoppedSubtitle => 'Alarma matutina';

  @override
  String get triggerAlarmStoppedWhen => 'Cuando apagues la alarma';

  @override
  String get triggerUnsilencedTitle => 'Al quitar el silencio';

  @override
  String get triggerUnsilencedSubtitle => 'Subir el sonido';

  @override
  String get triggerUnsilencedWhen => 'Cuando vuelvas a activar el sonido';

  @override
  String get triggerUnpluggedTitle => 'Al desconectar';

  @override
  String get triggerUnpluggedSubtitle => 'Al coger el teléfono';

  @override
  String get triggerUnpluggedWhen => 'Cuando desconectes el teléfono';

  @override
  String get triggerLeftHomeWifiTitle => 'Al salir del Wi‑Fi de casa';

  @override
  String get triggerLeftHomeWifiSubtitle => 'Al salir de casa';

  @override
  String get triggerLeftHomeWifiWhen => 'Cuando salgas del Wi‑Fi de casa';

  @override
  String get triggerNfcTagTitle => 'Al tocar la etiqueta';

  @override
  String get triggerNfcTagSubtitle => 'Etiqueta NFC';

  @override
  String get triggerNfcTagWhen => 'Cuando toques la etiqueta de la puerta';

  @override
  String triggersOr(String a, String b) {
    return '$a o $b';
  }

  @override
  String triggersMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String triggersAnyOf(int count) {
    return 'Cuando ocurra cualquiera de tus $count acciones';
  }

  @override
  String get triggersBackupOnly => 'Solo la hora de respaldo';

  @override
  String get silentAlertQuiet => 'Nada';

  @override
  String get silentAlertVibrate => 'Vibrar';

  @override
  String get silentAlertRing => 'Sonar';

  @override
  String get weekdayLetters => 'L,M,X,J,V,S,D';

  @override
  String get today => 'hoy';

  @override
  String get tomorrow => 'mañana';

  @override
  String get yesterday => 'ayer';

  @override
  String dayAndTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get defaultEveningIron => '¿Desenchufé la plancha?';

  @override
  String get defaultEveningTodo => '¿Marqué mi lista de tareas?';

  @override
  String get defaultEveningLock => '¿Cerré la puerta con llave?';

  @override
  String get defaultMorningCharger => '¿Metí el cargador en la mochila?';

  @override
  String get defaultMorningNotes => '¿Revisé las notas de anoche?';

  @override
  String get defaultMorningKeys => '¿Llevo las llaves y la cartera?';

  @override
  String get checkTitleEvening => 'Control nocturno';

  @override
  String get checkTitleMorning => 'Control matutino';

  @override
  String checkProgressA11y(int done, int total) {
    return '$done de $total hechos';
  }

  @override
  String get checkDoneLabel => 'hecho';

  @override
  String get checkTapHint => 'Toca un elemento para marcarlo';

  @override
  String get checkSnooze => 'En 10 min';

  @override
  String get allDone => 'Todo listo';

  @override
  String checkDoneAt(String title, String time) {
    return '$title · $time';
  }

  @override
  String get checkDoneEvening => 'Tranquilo. Buenas noches.';

  @override
  String get checkDoneMorning => 'Listo. Que tengas un buen día.';

  @override
  String get undo => 'Deshacer';

  @override
  String get close => 'Cerrar';

  @override
  String get iconIron => 'Plancha';

  @override
  String get iconPlug => 'Enchufe';

  @override
  String get iconFlame => 'Fogón';

  @override
  String get iconLock => 'Cerradura';

  @override
  String get iconKey => 'Llaves';

  @override
  String get iconBag => 'Mochila';

  @override
  String get iconWallet => 'Cartera';

  @override
  String get iconBulb => 'Lámpara';

  @override
  String get iconPill => 'Medicina';

  @override
  String get iconNotes => 'Notas';

  @override
  String get iconChecklist => 'Lista';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyLast14 => 'Últimos 14 días';

  @override
  String get historyActivity => 'Actividad';

  @override
  String historyRange(int from, int to, String month) {
    return '$from–$to de $month';
  }

  @override
  String get historyEmpty => 'Aún no hay registros';

  @override
  String historyScoreA11y(int total, int done) {
    return '$done de $total umbrales completados';
  }

  @override
  String historyPercent(int percent) {
    return '$percent% hecho';
  }

  @override
  String get historyFirstSoon => 'Tu primer umbral llega pronto';

  @override
  String get historyGreat => 'Cruzaste el umbral';

  @override
  String get historyHalfway => 'Vas por la mitad';

  @override
  String get historyNewDay => 'Cada día es un nuevo umbral';

  @override
  String get historyGridA11y =>
      'Controles de noche y mañana, últimas dos semanas';

  @override
  String get outcomeDone => 'Hecho';

  @override
  String get outcomeViaBackup => 'Con el aviso de respaldo';

  @override
  String get outcomeMissed => 'Omitido';

  @override
  String get outcomeNotTracked => 'Sin registro';

  @override
  String get outcomeOff => 'Día libre';

  @override
  String get historyAverageEvening => 'Umbral medio de la noche';

  @override
  String get historyEveningTrigger => 'Disparador de la noche';

  @override
  String historyEarliest(String time) {
    return 'Lo más temprano $time';
  }

  @override
  String historyLatest(String time) {
    return 'Lo más tarde $time';
  }

  @override
  String get appName => 'Eşik';

  @override
  String todayDoneAt(String time) {
    return 'Hecho · $time';
  }

  @override
  String todayContinue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Continuar · quedan $count',
      one: 'Continuar · queda 1',
    );
    return '$_temp0';
  }

  @override
  String get todayCheckNow => 'Comprobar ahora';

  @override
  String get todayThresholdEvening => 'Tu umbral de esta noche';

  @override
  String get todayThresholdMorning => 'Tu umbral de esta mañana';

  @override
  String get todayOffDay =>
      'Hoy es día libre; Eşik no te avisará. Aun así puedes comprobar si quieres.';

  @override
  String todayCardBody(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$when, aparece tu control de $count elementos.',
      one: '$when, aparece tu control de 1 elemento.',
    );
    return '$_temp0';
  }

  @override
  String todayItemsProgress(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0 · $done/$count';
  }

  @override
  String summaryEveningDoneAt(String time) {
    return 'Hecho esta noche a las $time';
  }

  @override
  String summaryMorningDoneAt(String time) {
    return 'Hecho esta mañana a las $time';
  }

  @override
  String get summaryMorningNotDone => 'No hecho esta mañana';

  @override
  String get summaryMorningPartial => 'A medias esta mañana';

  @override
  String summaryLastNightDoneAt(String time) {
    return 'Hecho anoche a las $time';
  }

  @override
  String get summaryLastNightMissed => 'Omitido anoche';

  @override
  String get summaryLastNightNoRecord => 'Sin registro anoche';

  @override
  String get summaryLastNightOff => 'Anoche fue día libre';

  @override
  String get summaryGoToEvening => 'Ir al umbral de la noche';

  @override
  String get summaryGoToMorning => 'Ir al umbral de la mañana';

  @override
  String summaryEveningLine(String trigger) {
    return 'Umbral de la noche · $trigger';
  }

  @override
  String summaryMorningLine(String trigger) {
    return 'Umbral de la mañana · $trigger';
  }

  @override
  String summaryLast7A11y(int done) {
    return 'Últimos 7 días: $done hechos';
  }

  @override
  String get modeEveningSwitch => 'Modo noche. Cambiar a mañana';

  @override
  String get modeMorningSwitch => 'Modo mañana. Cambiar a noche';

  @override
  String get modeEvening => 'Modo noche';

  @override
  String get modeMorning => 'Modo mañana';

  @override
  String setupCardMore(String issue, int count) {
    return '$issue · faltan $count';
  }

  @override
  String setupCardA11y(String detail) {
    return '$detail. Completar configuración';
  }

  @override
  String get setupFinish => 'Completar configuración';

  @override
  String dayStripA11y(int day, String weekday) {
    return '$weekday $day';
  }

  @override
  String dayStripDoneA11y(int day, String weekday, int count) {
    return '$weekday $day, $count umbrales hechos';
  }

  @override
  String get issueNotifications => 'Notificaciones desactivadas';

  @override
  String get issueBattery => 'Restricción de batería activa';

  @override
  String get issueNfcOff => 'NFC desactivado';

  @override
  String get issueNfcTag => 'Etiqueta aún sin escribir';

  @override
  String get issueNoAlarm => 'No hay alarma';

  @override
  String get windowStartHelp => 'Inicio del intervalo';

  @override
  String get windowEndHelp => 'Fin del intervalo';

  @override
  String get backupTimeHelp => 'Hora del aviso de respaldo';

  @override
  String get settingsTitle => 'Mis umbrales';

  @override
  String get beforeBed => 'Antes de dormir';

  @override
  String get beforeLeaving => 'Antes de salir de casa';

  @override
  String get pickStartTime => 'Elegir hora de inicio';

  @override
  String get pickEndTime => 'Elegir hora de fin';

  @override
  String get anyTime => 'A cualquier hora';

  @override
  String get onlyInWindow => 'Solo en este intervalo';

  @override
  String get windowOff => 'Intervalo desactivado';

  @override
  String get whatTriggers => '¿Cuándo?';

  @override
  String get firstOneWins => 'El que ocurra primero te avisa ese día.';

  @override
  String get pickSeveral =>
      'Puedes elegir varios; el que ocurra primero te avisa.';

  @override
  String get whichDays => '¿Qué días?';

  @override
  String get changeBackupTime => 'Cambiar hora de respaldo';

  @override
  String backupRow(String time) {
    return 'Si no ocurre ninguno, avísame a las $time';
  }

  @override
  String get backupReminder => 'Aviso de respaldo';

  @override
  String get setupCheck => 'Revisar configuración';

  @override
  String setupFinishMissing(int count) {
    return 'Completar configuración · faltan $count';
  }

  @override
  String get autoSaved => 'Los cambios se guardan solos';

  @override
  String timeButtonA11y(String label, String time) {
    return '$label, ahora $time';
  }

  @override
  String tileA11y(String title, String subtitle) {
    return '$title, $subtitle';
  }

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get comingSoonLower => 'próximamente';

  @override
  String get selected => 'Seleccionado';

  @override
  String get whenSilent => 'Con el teléfono en silencio';

  @override
  String get silentQuietHint => 'Los avisos siguen el sonido del teléfono.';

  @override
  String get silentVibrateHint => 'Vibra incluso en silencio o en No molestar.';

  @override
  String get silentMutedHint =>
      'El volumen de alarma está apagado, así que no se oirá. Sube el volumen de alarma.';

  @override
  String get silentRingHint =>
      'Suena al volumen de alarma y vibra, incluso en silencio.';

  @override
  String waitFrom(String when, String text) {
    return 'desde $when: $text';
  }

  @override
  String get waitCharging => 'esperando la carga';

  @override
  String get waitWifi => 'esperando el Wi‑Fi';

  @override
  String get waitLeaving => 'esperando a que salgas del Wi‑Fi';

  @override
  String waitAlarm(String when) {
    return 'próxima alarma $when';
  }

  @override
  String get waitAlarmSettling => 'la alarma sonó, esperando a que se apague';

  @override
  String get waitNoAlarm => 'no hay alarma';

  @override
  String get waitSilence => 'esperando a que bajes el sonido';

  @override
  String get waitAlreadySilent =>
      'el teléfono ya está en silencio total; sube un poco el sonido primero';

  @override
  String get waitUnsilence => 'esperando a que subas el sonido';

  @override
  String get waitNotSilent =>
      'el sonido ya está activado; bájalo por la noche y funcionará por la mañana';

  @override
  String get waitNone => 'no configurado';

  @override
  String statusLine(String text) {
    return 'Estado: $text';
  }

  @override
  String statusLineKind(String kind, String text) {
    return '$kind: $text';
  }

  @override
  String get hintCharging => 'Llega pocos minutos después de enchufarlo.';

  @override
  String get hintAlarm =>
      'Llega cuando la alarma del Reloj suena y se apaga. Si la pospones, espera.';

  @override
  String get hintWifi =>
      'Llega cuando se pierde el Wi‑Fi y el teléfono pasa a datos móviles; mantén los datos activados.';

  @override
  String get hintSilenced =>
      'Llega al bajar un nivel el sonido: de sonido a vibración, de vibración a silencio o al activar No molestar.';

  @override
  String get hintUnsilenced =>
      'Llega al subir un nivel el sonido: de silencio a vibración, de vibración a sonido o al desactivar No molestar.';

  @override
  String get hintNfc => 'Al tocar la etiqueta se abre el control.';

  @override
  String get hintSoon =>
      'Este disparador llegará pronto. Mientras tanto, te avisa la hora de respaldo.';

  @override
  String get backupOff => 'Aviso de respaldo desactivado';

  @override
  String backupNext(String when) {
    return 'Próximo respaldo: $when';
  }

  @override
  String backupLast(String when, String outcome) {
    return 'Último respaldo: $when $outcome';
  }

  @override
  String triggerLast(String when, String outcome) {
    return 'Último disparo: $when $outcome';
  }

  @override
  String triggerLastKind(String kind, String when, String outcome) {
    return 'Último disparo ($kind): $when $outcome';
  }

  @override
  String get outcomeShown => 'enviado';

  @override
  String get outcomeAlreadyDone => 'omitido: ya estaba hecho';

  @override
  String get outcomeAlreadyNotified => 'omitido: ya se avisó ese día';

  @override
  String get outcomeNoPermission => 'no enviado: notificaciones desactivadas';

  @override
  String get outcomeDisabled => 'omitido: respaldo desactivado';

  @override
  String get outcomeOffDay => 'omitido: día libre';

  @override
  String rangeA11y(String start, String end) {
    return 'Intervalo de $start a $end';
  }

  @override
  String itemDeleted(String title) {
    return '“$title” eliminado';
  }

  @override
  String get checklistTitle => 'Mi lista';

  @override
  String get checklistEmpty => 'Aún no hay elementos. Añade uno abajo.';

  @override
  String get delete => 'Eliminar';

  @override
  String get checklistHint =>
      'Mantén y arrastra · desliza a la izquierda para eliminar';

  @override
  String get newItem => 'Nuevo elemento';

  @override
  String get pickIcon => 'Elige un icono';

  @override
  String get dragToReorder => 'Arrastra para ordenar';

  @override
  String get newItemHint => 'Ej. ¿Apagué el fuego?';

  @override
  String get add => 'Añadir';

  @override
  String get stepNotifTitle => 'Permitir notificaciones';

  @override
  String get stepNotifDetail =>
      'Eşik solo escribe cuando llega un umbral. Como mucho dos avisos al día.';

  @override
  String get allow => 'Permitir';

  @override
  String get stepBatteryTitle => 'Permitir que funcione en segundo plano';

  @override
  String get stepBatteryDetail =>
      'El ahorro de batería puede dormir a Eşik. Toca “Permitir” en la ventana que se abre. Si se abren los ajustes, toca Batería y elige “Sin restricciones”.';

  @override
  String get stepUsageTitle => 'Permitir acceso de uso';

  @override
  String get stepUsageDetail =>
      'Para saber cuándo se cierra Instagram, Eşik necesita ver qué app está abierta.';

  @override
  String get stepUsageAction => 'Abrir acceso de uso';

  @override
  String get stepNoPermissionTitle => 'No hace falta otro permiso';

  @override
  String get stepSilencedDetail =>
      'En el intervalo de la noche, Eşik nota cuando bajas un nivel el sonido (de sonido a vibración, de vibración a silencio) o se activa No molestar.';

  @override
  String get stepUnsilencedDetail =>
      'En el intervalo de la mañana, Eşik nota cuando subes un nivel el sonido (de silencio a vibración, de vibración a sonido) o se desactiva No molestar.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get stepNotifAccessTitle => 'Permitir acceso a notificaciones';

  @override
  String get stepNotifAccessDetail =>
      'Para saber cuándo se activa el modo descanso. Tus notificaciones no se leen.';

  @override
  String get stepNotifAccessAction => 'Abrir acceso';

  @override
  String get stepWifiTitle => 'Mantén los datos móviles activados';

  @override
  String get stepWifiDetail =>
      'En el intervalo de la mañana, mientras estás en el Wi‑Fi de casa, Eşik espera; cuando se pierde la conexión y el teléfono pasa a datos móviles, te avisa. No se lee el nombre del Wi‑Fi ni hace falta permiso de ubicación.';

  @override
  String get stepNfcTitle => 'Prepara la etiqueta';

  @override
  String get stepNfcDetail =>
      'Acerca una etiqueta NFC vacía a la parte trasera del teléfono; Eşik escribe su enlace en ella.';

  @override
  String get stepNfcAction => 'Escribir etiqueta';

  @override
  String get stepAlarmTitle => 'Pon tu alarma de la mañana';

  @override
  String get stepAlarmDetail =>
      'No hace falta otro permiso. Eşik nota cuando la alarma del Reloj suena y se apaga. Si la pospones, espera al último aviso.';

  @override
  String get stepTestTitle => 'Pruébalo';

  @override
  String get stepTestCharging =>
      'Primero un aviso de prueba. El real llega pocos minutos después de enchufar el teléfono dentro de tu intervalo.';

  @override
  String get stepTestWifi =>
      'Primero un aviso de prueba. El real llega en el intervalo de la mañana cuando se pierde el Wi‑Fi y pasas a datos móviles.';

  @override
  String get stepTestAlarm =>
      'Primero un aviso de prueba. El real llega después de apagar una alarma en el intervalo de la mañana.';

  @override
  String get stepTestSilenced =>
      'Primero un aviso de prueba. El real llega segundos después de bajar el sonido en el intervalo de la noche.';

  @override
  String get stepTestUnsilenced =>
      'Primero un aviso de prueba. El real llega segundos después de subir el sonido en el intervalo de la mañana.';

  @override
  String get stepTestNfc =>
      'Sal de la app y toca la etiqueta con el teléfono desbloqueado. Debería abrirse el control.';

  @override
  String get stepTestMany =>
      'Enviemos un aviso de prueba. El real lo envía la primera de tus acciones que ocurra ese día.';

  @override
  String get stepTestOther =>
      'Enviemos un aviso de prueba; el real se verá igual.';

  @override
  String get finish => 'Terminar';

  @override
  String get sendTest => 'Enviar aviso de prueba';

  @override
  String get notifDenied =>
      'No se concedió el permiso de notificaciones. Puedes activarlo en ajustes.';

  @override
  String get settings => 'Ajustes';

  @override
  String get testNotSent => 'No se pudo enviar: notificaciones desactivadas.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get openInSettings => 'Activar en ajustes';

  @override
  String get turnOnNfc => 'Activar NFC';

  @override
  String get openClock => 'Abrir Reloj';

  @override
  String get detailNotifOn =>
      'Notificaciones activadas. Eşik solo escribe cuando llega un umbral.';

  @override
  String get detailNotifBlocked =>
      'El permiso está concedido, pero las notificaciones de Eşik están desactivadas en los ajustes. Actívalas en la página que se abre.';

  @override
  String get detailBatteryOk =>
      'Eşik está exento de restricciones de batería y no se dormirá.';

  @override
  String get detailNoAlarm =>
      'No hay alarmas en Reloj. Pon tu alarma de la mañana; Eşik nota cuando suena y se apaga.';

  @override
  String detailNextAlarm(String when) {
    return 'Próxima alarma $when. Eşik nota cuando suena y se apaga. Si la pospones, espera al último aviso.';
  }

  @override
  String get noNfc =>
      'Este teléfono no tiene NFC. Elige otro disparador de la mañana.';

  @override
  String get detailNfcOff =>
      'El NFC está desactivado. Debe estar activado para escribir y leer la etiqueta.';

  @override
  String get detailTagWritten =>
      'La etiqueta está escrita. Puedes escribir otra si quieres.';

  @override
  String get tagReady => 'Etiqueta lista. Pégala junto a la puerta.';

  @override
  String get nfcOffRetry =>
      'El NFC está desactivado. Actívalo e inténtalo de nuevo.';

  @override
  String get tagReadOnly =>
      'Esta etiqueta está bloqueada y no se puede escribir. Prueba una vacía.';

  @override
  String get tagIncompatible =>
      'Esta etiqueta no sirve. Prueba una NTAG213 o similar.';

  @override
  String get tagError =>
      'No se pudo escribir. Mantén el teléfono sobre la etiqueta un poco más.';

  @override
  String get setupTitle => 'Configuración';

  @override
  String stepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get holdToTag => 'Acerca a la etiqueta';

  @override
  String get holdToTagDetail =>
      'Toca la etiqueta con la parte trasera del teléfono y espera la vibración.';

  @override
  String get skip => 'Omitir';

  @override
  String get later => 'Luego';

  @override
  String get cancel => 'Cancelar';

  @override
  String stepA11y(int number, String title, String state) {
    return 'Paso $number, $title, $state';
  }

  @override
  String get stepStateDone => 'hecho';

  @override
  String get stepStateCurrent => 'paso actual';

  @override
  String get stepStateUpcoming => 'siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get startSetup => 'Empezar la configuración';

  @override
  String get notNow => 'Ahora no';

  @override
  String pageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get introKicker => 'Bienvenido a Eşik';

  @override
  String get introTitle => 'Antes de dormir.\nAntes de salir por la puerta.';

  @override
  String get introBody =>
      'Tu propia lista en los dos umbrales del día, justo cuando la necesitas.';

  @override
  String get scenarioKicker => 'Por ejemplo';

  @override
  String get scenarioTitle => 'No una hora. Un momento.';

  @override
  String get scenarioBody =>
      'Una alarma a las 22:30 suena en mitad de la serie. Eşik llega en el momento en que pones el teléfono a cargar; revisas tres cosas y duermes tranquilo.';

  @override
  String get calloutPlugged => 'Enchufado';

  @override
  String get calloutPluggedAt => '22:47 · umbral';

  @override
  String get calloutDoor => 'Puerta';

  @override
  String get calloutLocked => 'Cerrada';

  @override
  String get calloutIron => 'Plancha';

  @override
  String get calloutUnplugged => 'Desenchufada';

  @override
  String get notifyKicker => 'Último paso';

  @override
  String get notifyTitle => 'Te avisamos\nen el momento justo.';

  @override
  String get notifyBody =>
      'Solo escribimos cuando llega un umbral. Como mucho dos avisos al día, sin anuncios.';

  @override
  String get eveningThreshold => 'Umbral de la noche';

  @override
  String get morningThreshold => 'Umbral de la mañana';

  @override
  String get now => 'ahora';

  @override
  String get notifyPreview =>
      'Has enchufado. Plancha, tareas, puerta: 3 elementos.';

  @override
  String get tabToday => 'Hoy';

  @override
  String get tabList => 'Lista';

  @override
  String get tabHistory => 'Historial';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get checkNow => 'Comprobar';

  @override
  String get evening => 'Noche';

  @override
  String get morning => 'Mañana';

  @override
  String get startupFailed => 'Eşik no pudo iniciarse';

  @override
  String get startupTimeout => 'Los ajustes no cargaron a tiempo.';

  @override
  String get startupHelp =>
      'Puedes copiar el texto de abajo y enviárselo al desarrollador.';

  @override
  String get copyError => 'Copiar error';

  @override
  String get retry => 'Reintentar';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get plusName => 'Eşik Plus';

  @override
  String get plusTagline => 'Configura tus umbrales a tu manera.';

  @override
  String get plusFeatureMulti => 'Varios disparadores a la vez';

  @override
  String get plusFeatureWifiNfc => 'Modo silencio, Wi‑Fi y etiqueta NFC';

  @override
  String get plusFeatureDays => 'Elegir qué días funciona';

  @override
  String get plusFeatureSilent => 'Vibrar o sonar en silencio';

  @override
  String get plusFeatureHistory => 'Historial y estadísticas';

  @override
  String get plusOnce => 'Pago único, sin suscripción. Sin anuncios.';

  @override
  String plusBuy(String price) {
    return 'De por vida · $price';
  }

  @override
  String get plusBuyNoPrice => 'Obtener Plus';

  @override
  String get plusRestore => 'Restaurar compra';

  @override
  String get plusUnavailable =>
      'No se puede conectar con Google Play ahora. Inténtalo en un rato.';

  @override
  String get plusPending => 'Esperando el pago…';

  @override
  String get plusThanks => '¡Gracias! Ya tienes Plus.';

  @override
  String get plusOwned => 'Tienes Plus';

  @override
  String plusTrialLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Prueba: quedan $days días',
      one: 'Prueba: queda 1 día',
    );
    return '$_temp0';
  }

  @override
  String get plusFree => 'Versión gratuita';

  @override
  String plusTrialNote(int days) {
    return 'Todas las funciones Plus están activas los primeros $days días.';
  }

  @override
  String get plusMultiHint =>
      'Modo silencio, Wi‑Fi, NFC y varios disparadores vienen con Plus.';

  @override
  String plusTrialEnding(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Últimos $days días de tu prueba Plus',
      one: 'Último día de tu prueba Plus',
    );
    return '$_temp0';
  }

  @override
  String get plusTrialEndingBody =>
      'Después, cada modo sigue con un disparador.';

  @override
  String get plusHistoryTitle => 'El historial viene con Plus';

  @override
  String get plusHistoryBody =>
      'Mira qué noches y mañanas comprobaste, a qué hora y tu media.';

  @override
  String get seePlus => 'Ver Plus';

  @override
  String get oneByOne => 'Uno por uno';
}
