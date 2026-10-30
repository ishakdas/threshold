// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get triggerChargingTitle => 'When charging';

  @override
  String get triggerChargingSubtitle => 'By the bed';

  @override
  String get triggerChargingWhen => 'When you plug in your phone';

  @override
  String get triggerSilencedTitle => 'When silenced';

  @override
  String get triggerSilencedSubtitle => 'Volume down';

  @override
  String get triggerSilencedWhen => 'When you silence your phone';

  @override
  String get triggerAppClosedTitle => 'When an app closes';

  @override
  String get triggerAppClosedSubtitle => 'Instagram';

  @override
  String get triggerAppClosedWhen => 'When you close Instagram';

  @override
  String get triggerSleepModeTitle => 'When sleep starts';

  @override
  String get triggerSleepModeSubtitle => 'Sleep Focus';

  @override
  String get triggerSleepModeWhen => 'When Sleep Focus starts';

  @override
  String get triggerAirplaneModeTitle => 'Airplane mode';

  @override
  String get triggerAirplaneModeSubtitle => 'When it turns on';

  @override
  String get triggerAirplaneModeWhen => 'When you turn on airplane mode';

  @override
  String get triggerAlarmStoppedTitle => 'When the alarm stops';

  @override
  String get triggerAlarmStoppedSubtitle => 'Morning alarm';

  @override
  String get triggerAlarmStoppedWhen => 'When you stop your alarm';

  @override
  String get triggerUnsilencedTitle => 'When unsilenced';

  @override
  String get triggerUnsilencedSubtitle => 'Volume up';

  @override
  String get triggerUnsilencedWhen => 'When you turn the sound back on';

  @override
  String get triggerUnpluggedTitle => 'When unplugged';

  @override
  String get triggerUnpluggedSubtitle => 'Picking up the phone';

  @override
  String get triggerUnpluggedWhen => 'When you unplug your phone';

  @override
  String get triggerLeftHomeWifiTitle => 'When leaving home Wi‑Fi';

  @override
  String get triggerLeftHomeWifiSubtitle => 'Leaving home';

  @override
  String get triggerLeftHomeWifiWhen => 'When you leave your home Wi‑Fi';

  @override
  String get triggerNfcTagTitle => 'When you tap the door tag';

  @override
  String get triggerNfcTagSubtitle => 'NFC tag';

  @override
  String get triggerNfcTagWhen => 'When you tap the tag by the door';

  @override
  String triggersOr(String a, String b) {
    return '$a or $b';
  }

  @override
  String triggersMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String triggersAnyOf(int count) {
    return 'When any of your $count chosen actions happens';
  }

  @override
  String get triggersBackupOnly => 'Backup time only';

  @override
  String get silentAlertQuiet => 'Off';

  @override
  String get silentAlertVibrate => 'Vibrate';

  @override
  String get silentAlertRing => 'Ring';

  @override
  String get weekdayLetters => 'M,T,W,T,F,S,S';

  @override
  String get today => 'today';

  @override
  String get tomorrow => 'tomorrow';

  @override
  String get yesterday => 'yesterday';

  @override
  String dayAndTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get defaultEveningIron => 'Did I unplug the iron?';

  @override
  String get defaultEveningTodo => 'Did I tick off my to-do list?';

  @override
  String get defaultEveningLock => 'Did I lock the door?';

  @override
  String get defaultMorningCharger => 'Is the charger in my bag?';

  @override
  String get defaultMorningNotes => 'Did I check last night’s notes?';

  @override
  String get defaultMorningKeys => 'Do I have my keys and wallet?';

  @override
  String get checkTitleEvening => 'Evening check';

  @override
  String get checkTitleMorning => 'Morning check';

  @override
  String checkProgressA11y(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get checkDoneLabel => 'done';

  @override
  String get checkTapHint => 'Tap an item to tick it';

  @override
  String get checkSnooze => 'In 10 min';

  @override
  String get allDone => 'All done';

  @override
  String checkDoneAt(String title, String time) {
    return '$title · $time';
  }

  @override
  String get checkDoneEvening => 'Rest easy. Good night.';

  @override
  String get checkDoneMorning => 'You’re ready. Have a good day.';

  @override
  String get undo => 'Undo';

  @override
  String get close => 'Close';

  @override
  String get iconIron => 'Iron';

  @override
  String get iconPlug => 'Plug';

  @override
  String get iconFlame => 'Stove';

  @override
  String get iconLock => 'Lock';

  @override
  String get iconKey => 'Keys';

  @override
  String get iconBag => 'Bag';

  @override
  String get iconWallet => 'Wallet';

  @override
  String get iconBulb => 'Lamp';

  @override
  String get iconPill => 'Medicine';

  @override
  String get iconNotes => 'Notes';

  @override
  String get iconChecklist => 'List';

  @override
  String get historyTitle => 'History';

  @override
  String get historyLast14 => 'Last 14 days';

  @override
  String get historyActivity => 'Threshold activity';

  @override
  String historyRange(int from, int to, String month) {
    return '$month $from–$to';
  }

  @override
  String get historyEmpty => 'No records yet';

  @override
  String historyScoreA11y(int total, int done) {
    return '$done of $total thresholds completed';
  }

  @override
  String historyPercent(int percent) {
    return '$percent% done';
  }

  @override
  String get historyFirstSoon => 'Your first threshold is coming';

  @override
  String get historyGreat => 'You crossed the threshold';

  @override
  String get historyHalfway => 'You’re halfway there';

  @override
  String get historyNewDay => 'Every day is a new threshold';

  @override
  String get historyGridA11y => 'Evening and morning checks, last two weeks';

  @override
  String get outcomeDone => 'Done';

  @override
  String get outcomeViaBackup => 'Via backup reminder';

  @override
  String get outcomeMissed => 'Missed';

  @override
  String get outcomeNotTracked => 'No record';

  @override
  String get outcomeOff => 'Day off';

  @override
  String get historyAverageEvening => 'Average evening threshold';

  @override
  String get historyEveningTrigger => 'Evening trigger';

  @override
  String historyEarliest(String time) {
    return 'Earliest $time';
  }

  @override
  String historyLatest(String time) {
    return 'Latest $time';
  }

  @override
  String get appName => 'Eşik';

  @override
  String todayDoneAt(String time) {
    return 'Done · $time';
  }

  @override
  String todayContinue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Continue · $count items left',
      one: 'Continue · 1 item left',
    );
    return '$_temp0';
  }

  @override
  String get todayCheckNow => 'Check now';

  @override
  String get todayThresholdEvening => 'Tonight’s threshold';

  @override
  String get todayThresholdMorning => 'This morning’s threshold';

  @override
  String get todayOffDay =>
      'Today is a day off; Eşik won’t remind you. You can still check if you like.';

  @override
  String todayCardBody(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$when, your $count-item check appears.',
      one: '$when, your 1-item check appears.',
    );
    return '$_temp0';
  }

  @override
  String todayItemsProgress(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $done/$count';
  }

  @override
  String summaryEveningDoneAt(String time) {
    return 'Done tonight at $time';
  }

  @override
  String summaryMorningDoneAt(String time) {
    return 'Done this morning at $time';
  }

  @override
  String get summaryMorningNotDone => 'Not done this morning';

  @override
  String get summaryMorningPartial => 'Half done this morning';

  @override
  String summaryLastNightDoneAt(String time) {
    return 'Done last night at $time';
  }

  @override
  String get summaryLastNightMissed => 'Missed last night';

  @override
  String get summaryLastNightNoRecord => 'No record last night';

  @override
  String get summaryLastNightOff => 'Last night was a day off';

  @override
  String get summaryGoToEvening => 'Go to the evening threshold';

  @override
  String get summaryGoToMorning => 'Go to the morning threshold';

  @override
  String summaryEveningLine(String trigger) {
    return 'Evening threshold · $trigger';
  }

  @override
  String summaryMorningLine(String trigger) {
    return 'Morning threshold · $trigger';
  }

  @override
  String summaryLast7A11y(int done) {
    return 'Last 7 days: $done done';
  }

  @override
  String get modeEveningSwitch => 'Evening mode. Switch to morning';

  @override
  String get modeMorningSwitch => 'Morning mode. Switch to evening';

  @override
  String get modeEvening => 'Evening mode';

  @override
  String get modeMorning => 'Morning mode';

  @override
  String setupCardMore(String issue, int count) {
    return '$issue · $count missing';
  }

  @override
  String setupCardA11y(String detail) {
    return '$detail. Finish setup';
  }

  @override
  String get setupFinish => 'Finish setup';

  @override
  String dayStripA11y(int day, String weekday) {
    return '$weekday $day';
  }

  @override
  String dayStripDoneA11y(int day, String weekday, int count) {
    return '$weekday $day, $count thresholds done';
  }

  @override
  String get issueNotifications => 'Notifications are off';

  @override
  String get issueBattery => 'Battery restriction is on';

  @override
  String get issueNfcOff => 'NFC is off';

  @override
  String get issueNfcTag => 'Tag not written yet';

  @override
  String get issueNoAlarm => 'No alarm set';

  @override
  String get windowStartHelp => 'Window start';

  @override
  String get windowEndHelp => 'Window end';

  @override
  String get backupTimeHelp => 'Backup reminder time';

  @override
  String get settingsTitle => 'My thresholds';

  @override
  String get beforeBed => 'Before bed';

  @override
  String get beforeLeaving => 'Before leaving home';

  @override
  String get pickStartTime => 'Choose start time';

  @override
  String get pickEndTime => 'Choose end time';

  @override
  String get anyTime => 'Any time';

  @override
  String get onlyInWindow => 'Only in this window';

  @override
  String get windowOff => 'Window off';

  @override
  String get whatTriggers => 'When what happens?';

  @override
  String get firstOneWins => 'Whichever happens first reminds you that day.';

  @override
  String get pickSeveral =>
      'You can pick several; whichever happens first reminds you.';

  @override
  String get whichDays => 'Which days?';

  @override
  String get changeBackupTime => 'Change backup time';

  @override
  String backupRow(String time) {
    return 'If none happen, remind me at $time';
  }

  @override
  String get backupReminder => 'Backup reminder';

  @override
  String get setupCheck => 'Check setup';

  @override
  String setupFinishMissing(int count) {
    return 'Finish setup · $count missing';
  }

  @override
  String get autoSaved => 'Changes are saved automatically';

  @override
  String timeButtonA11y(String label, String time) {
    return '$label, currently $time';
  }

  @override
  String tileA11y(String title, String subtitle) {
    return '$title, $subtitle';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonLower => 'coming soon';

  @override
  String get selected => 'Selected';

  @override
  String get whenSilent => 'When the phone is silent';

  @override
  String get silentQuietHint => 'Reminders follow your phone’s sound setting.';

  @override
  String get silentVibrateHint =>
      'Vibrates even when silent or in Do Not Disturb.';

  @override
  String get silentMutedHint =>
      'Alarm volume is off, so it won’t be heard. Turn up the alarm volume.';

  @override
  String get silentRingHint =>
      'Rings at alarm volume and vibrates, even when silent.';

  @override
  String waitFrom(String when, String text) {
    return 'from $when: $text';
  }

  @override
  String get waitCharging => 'waiting for charging';

  @override
  String get waitWifi => 'waiting for Wi‑Fi';

  @override
  String get waitLeaving => 'waiting for you to leave Wi‑Fi';

  @override
  String get waitPluggedIn => 'waiting for the phone to be charging';

  @override
  String get waitUnplug => 'waiting for you to unplug';

  @override
  String waitAlarm(String when) {
    return 'next alarm $when';
  }

  @override
  String get waitAlarmSettling => 'alarm rang, waiting for it to stop';

  @override
  String get waitNoAlarm => 'no alarm set';

  @override
  String get waitSilence => 'waiting for the sound to go down';

  @override
  String get waitAlreadySilent =>
      'phone is already fully silent; turn the sound up a bit first';

  @override
  String get waitUnsilence => 'waiting for the sound to go up';

  @override
  String get waitNotSilent =>
      'sound is already on; turn it down at night and it works in the morning';

  @override
  String get waitNone => 'not set up';

  @override
  String statusLine(String text) {
    return 'Status: $text';
  }

  @override
  String statusLineKind(String kind, String text) {
    return '$kind: $text';
  }

  @override
  String get hintCharging => 'Arrives within a few minutes of plugging in.';

  @override
  String get hintUnplugged =>
      'Arrives within a few minutes of unplugging, if the phone was charging during the morning window.';

  @override
  String get hintAlarm =>
      'Arrives after your Clock alarm rings and stops. Snoozing makes it wait.';

  @override
  String get hintWifi =>
      'Arrives when Wi‑Fi drops and the phone switches to mobile data; keep mobile data on.';

  @override
  String get hintSilenced =>
      'Arrives when the sound goes down a step: sound to vibrate, vibrate to silent, or Do Not Disturb on.';

  @override
  String get hintUnsilenced =>
      'Arrives when the sound goes up a step: silent to vibrate, vibrate to sound, or Do Not Disturb off.';

  @override
  String get hintNfc => 'Tapping the tag opens the check screen.';

  @override
  String get hintSoon =>
      'This trigger is coming soon. Until then the backup time reminds you.';

  @override
  String get backupOff => 'Backup reminder off';

  @override
  String backupNext(String when) {
    return 'Next backup: $when';
  }

  @override
  String backupLast(String when, String outcome) {
    return 'Last backup: $when $outcome';
  }

  @override
  String triggerLast(String when, String outcome) {
    return 'Last trigger: $when $outcome';
  }

  @override
  String triggerLastKind(String kind, String when, String outcome) {
    return 'Last trigger ($kind): $when $outcome';
  }

  @override
  String get outcomeShown => 'sent';

  @override
  String get outcomeAlreadyDone => 'skipped: already checked';

  @override
  String get outcomeAlreadyNotified => 'skipped: already reminded that day';

  @override
  String get outcomeNoPermission => 'not sent: notifications are off';

  @override
  String get outcomeDisabled => 'skipped: backup off';

  @override
  String get outcomeOffDay => 'skipped: day off';

  @override
  String rangeA11y(String start, String end) {
    return 'Time window from $start to $end';
  }

  @override
  String itemDeleted(String title) {
    return '“$title” deleted';
  }

  @override
  String get checklistTitle => 'My checklist';

  @override
  String get checklistEmpty => 'No items yet. Add one below.';

  @override
  String get delete => 'Delete';

  @override
  String get checklistHint => 'Hold and drag · swipe left to delete';

  @override
  String get newItem => 'New item';

  @override
  String get pickIcon => 'Choose an icon';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get newItemHint => 'e.g. Did I turn off the stove?';

  @override
  String get add => 'Add';

  @override
  String get stepNotifTitle => 'Allow notifications';

  @override
  String get stepNotifDetail =>
      'Eşik only writes when a threshold arrives. Two reminders a day at most.';

  @override
  String get allow => 'Allow';

  @override
  String get stepBatteryTitle => 'Let it run in the background';

  @override
  String get stepBatteryDetail =>
      'Battery saving can put Eşik to sleep. Tap “Allow” in the window that opens. If settings open instead, tap Battery and choose “Unrestricted”.';

  @override
  String get stepUsageTitle => 'Allow usage access';

  @override
  String get stepUsageDetail =>
      'To know when Instagram closes, Eşik needs to see which app is open.';

  @override
  String get stepUsageAction => 'Open usage access';

  @override
  String get stepNoPermissionTitle => 'No extra permission needed';

  @override
  String get stepSilencedDetail =>
      'In the evening window, Eşik notices when you turn the sound down a step (sound to vibrate, vibrate to silent) or Do Not Disturb turns on.';

  @override
  String get stepUnsilencedDetail =>
      'In the morning window, Eşik notices when you turn the sound up a step (silent to vibrate, vibrate to sound) or Do Not Disturb turns off.';

  @override
  String get gotIt => 'Got it';

  @override
  String get stepNotifAccessTitle => 'Allow notification access';

  @override
  String get stepNotifAccessDetail =>
      'So Eşik knows when sleep mode turns on. Your notifications are never read.';

  @override
  String get stepNotifAccessAction => 'Open access';

  @override
  String get stepWifiTitle => 'Keep mobile data on';

  @override
  String get stepWifiDetail =>
      'In the morning window, while you’re on home Wi‑Fi, Eşik waits; when the connection drops and the phone switches to mobile data, it reminds you. The Wi‑Fi name isn’t read and no location permission is needed.';

  @override
  String get stepNfcTitle => 'Prepare the tag';

  @override
  String get stepNfcDetail =>
      'Hold a blank NFC tag to the back of the phone; Eşik writes its link to the tag.';

  @override
  String get stepNfcAction => 'Write tag';

  @override
  String get stepAlarmTitle => 'Set your morning alarm';

  @override
  String get stepAlarmDetail =>
      'No extra permission needed. Eşik notices when your Clock alarm rings and stops. If you snooze, it waits for the last ring.';

  @override
  String get stepTestTitle => 'Try it';

  @override
  String get stepTestCharging =>
      'First a test reminder. The real one arrives a few minutes after you plug in during your chosen window.';

  @override
  String get stepTestWifi =>
      'First a test reminder. The real one arrives in the morning window when Wi‑Fi drops and you switch to mobile data.';

  @override
  String get stepTestAlarm =>
      'First a test reminder. The real one arrives after you stop an alarm in the morning window.';

  @override
  String get stepTestSilenced =>
      'First a test reminder. The real one arrives seconds after you turn the sound down in the evening window.';

  @override
  String get stepTestUnsilenced =>
      'First a test reminder. The real one arrives seconds after you turn the sound up in the morning window.';

  @override
  String get stepTestNfc =>
      'Leave the app and tap the unlocked phone on the tag. The check screen should open.';

  @override
  String get stepTestMany =>
      'Let’s send a test reminder. The real one comes from whichever chosen action happens first that day.';

  @override
  String get stepTestOther =>
      'Let’s send a test reminder; the real trigger will look the same.';

  @override
  String get finish => 'Finish';

  @override
  String get sendTest => 'Send a test reminder';

  @override
  String get notifDenied =>
      'Notification permission wasn’t granted. You can turn it on in settings.';

  @override
  String get settings => 'Settings';

  @override
  String get testNotSent => 'Couldn’t send: notifications are off.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get openInSettings => 'Turn on in settings';

  @override
  String get turnOnNfc => 'Turn on NFC';

  @override
  String get openClock => 'Open Clock';

  @override
  String get detailNotifOn =>
      'Notifications are on. Eşik only writes when a threshold arrives.';

  @override
  String get detailNotifBlocked =>
      'Permission is granted, but Eşik notifications are off in phone settings. Turn them on in the page that opens.';

  @override
  String get detailBatteryOk =>
      'Eşik is exempt from battery restrictions and won’t be put to sleep.';

  @override
  String get detailNoAlarm =>
      'There’s no alarm in Clock. Set your morning alarm; Eşik notices when it rings and stops.';

  @override
  String detailNextAlarm(String when) {
    return 'Next alarm $when. Eşik notices when it rings and stops. If you snooze, it waits for the last ring.';
  }

  @override
  String get noNfc => 'This phone has no NFC. Choose another morning trigger.';

  @override
  String get detailNfcOff =>
      'NFC is off. It needs to be on to write and read the tag.';

  @override
  String get detailTagWritten =>
      'The tag is written. You can write another one if you like.';

  @override
  String get tagReady => 'Tag ready. Stick it by the door.';

  @override
  String get nfcOffRetry => 'NFC is off. Turn it on and try again.';

  @override
  String get tagReadOnly =>
      'This tag is locked and can’t be written. Try a blank tag.';

  @override
  String get tagIncompatible =>
      'This tag won’t work. Try an NTAG213 or similar.';

  @override
  String get tagError =>
      'Couldn’t write. Hold the phone on the tag a little longer.';

  @override
  String get setupTitle => 'Setup';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get holdToTag => 'Hold to the tag';

  @override
  String get holdToTagDetail =>
      'Touch the back of the phone to the tag and wait for the vibration.';

  @override
  String get skip => 'Skip';

  @override
  String get later => 'Later';

  @override
  String get cancel => 'Cancel';

  @override
  String stepA11y(int number, String title, String state) {
    return 'Step $number, $title, $state';
  }

  @override
  String get stepStateDone => 'done';

  @override
  String get stepStateCurrent => 'current step';

  @override
  String get stepStateUpcoming => 'up next';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get startSetup => 'Start setup';

  @override
  String get notNow => 'Not now';

  @override
  String pageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get introKicker => 'Welcome to Eşik';

  @override
  String get introTitle => 'Before bed.\nBefore you walk out the door.';

  @override
  String get introBody =>
      'Your own checklist at the day’s two thresholds, right when you need it.';

  @override
  String get scenarioKicker => 'For example';

  @override
  String get scenarioTitle => 'Not a time. A moment.';

  @override
  String get scenarioBody =>
      'A 22:30 alarm goes off mid-episode. Eşik arrives the moment you plug in your phone; you check three things and sleep easy.';

  @override
  String get calloutPlugged => 'Plugged in';

  @override
  String get calloutPluggedAt => '22:47 · threshold';

  @override
  String get calloutDoor => 'Door';

  @override
  String get calloutLocked => 'Locked';

  @override
  String get calloutIron => 'Iron';

  @override
  String get calloutUnplugged => 'Unplugged';

  @override
  String get notifyKicker => 'Last step';

  @override
  String get notifyTitle => 'Let us tell you\nat the right moment.';

  @override
  String get notifyBody =>
      'We only write when a threshold arrives. Two reminders a day at most, no ads.';

  @override
  String get eveningThreshold => 'Evening threshold';

  @override
  String get morningThreshold => 'Morning threshold';

  @override
  String get now => 'now';

  @override
  String get notifyPreview => 'You plugged in. Iron, to-dos, door: 3 items.';

  @override
  String get tabToday => 'Today';

  @override
  String get tabList => 'List';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get checkNow => 'Check';

  @override
  String get evening => 'Evening';

  @override
  String get morning => 'Morning';

  @override
  String get startupFailed => 'Eşik couldn’t start';

  @override
  String get startupTimeout => 'Settings didn’t load in time.';

  @override
  String get startupHelp =>
      'You can copy the text below and send it to the developer.';

  @override
  String get copyError => 'Copy error';

  @override
  String get retry => 'Try again';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get plusName => 'Eşik Plus';

  @override
  String get plusTagline => 'Set up your thresholds exactly your way.';

  @override
  String get plusFeatureMulti => 'Several triggers at once';

  @override
  String get plusFeatureWifiNfc => 'Silent mode, Wi‑Fi and the NFC tag';

  @override
  String get plusFeatureDays => 'Choose which days it works';

  @override
  String get plusFeatureSilent => 'Vibrate or ring when silent';

  @override
  String get plusFeatureHistory => 'History and stats';

  @override
  String get plusOnce => 'One-time payment, no subscription. No ads.';

  @override
  String plusBuy(String price) {
    return 'Lifetime · $price';
  }

  @override
  String get plusBuyNoPrice => 'Get Plus';

  @override
  String get plusRestore => 'Restore purchase';

  @override
  String get plusUnavailable =>
      'Can’t reach Google Play right now. Try again shortly.';

  @override
  String get plusPending => 'Waiting for payment…';

  @override
  String get plusThanks => 'Thank you! Plus is yours.';

  @override
  String get plusOwned => 'You have Plus';

  @override
  String plusTrialLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Trial: $days days left',
      one: 'Trial: 1 day left',
    );
    return '$_temp0';
  }

  @override
  String get plusFree => 'Free version';

  @override
  String plusTrialNote(int days) {
    return 'All Plus features are on for the first $days days.';
  }

  @override
  String get plusMultiHint =>
      'Silent mode, Wi‑Fi, NFC and several triggers come with Plus.';

  @override
  String plusTrialEnding(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Last $days days of your Plus trial',
      one: 'Last day of your Plus trial',
    );
    return '$_temp0';
  }

  @override
  String get plusTrialEndingBody => 'After that, each mode keeps one trigger.';

  @override
  String get plusHistoryTitle => 'History comes with Plus';

  @override
  String get plusHistoryBody =>
      'See which evenings and mornings you checked, when, and your average.';

  @override
  String get seePlus => 'See Plus';

  @override
  String get oneByOne => 'Go one by one';

  @override
  String get delayTitle => 'When should it notify?';

  @override
  String get delayNow => 'Right away';

  @override
  String delaySeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String delayMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String delayMinSec(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String get delayCustom => 'Custom';

  @override
  String get delayHintNow => 'You’re notified as soon as the trigger happens.';

  @override
  String delayHintAfter(String delay) {
    return 'Arrives $delay after the trigger. If you check before then, it won’t come.';
  }

  @override
  String get delayPickerTitle => 'How long after the trigger?';

  @override
  String get delayPickerNote => 'Android may shift it by a few seconds.';

  @override
  String get delayPickerSave => 'Save';

  @override
  String get contactTitle => 'Write to us';

  @override
  String get contactSubtitle =>
      'Send an email with a suggestion, bug or question.';

  @override
  String get contactSubject => 'About Eşik';

  @override
  String contactNoApp(String email) {
    return 'No email app found. Address copied: $email';
  }

  @override
  String get stepShortcutTitle => 'Set up an automation in Shortcuts';

  @override
  String get stepShortcutAction => 'Open Shortcuts';

  @override
  String get shortcutIntro =>
      'iPhone doesn’t let apps see this moment, but Shortcuts can. Set it up once and it runs quietly.';

  @override
  String get shortcutCharging =>
      'Automation → + → Charger → “Is Connected” and “Run Immediately” → Next → search “Eşik” → “Plugged in”.';

  @override
  String get shortcutUnplugged =>
      'Automation → + → Charger → “Is Disconnected” and “Run Immediately” → Next → search “Eşik” → “Unplugged”.';

  @override
  String get shortcutAlarm =>
      'Automation → + → Alarm → “Is Stopped” (pick just your work alarm if you like) and “Run Immediately” → Next → search “Eşik” → “Alarm stopped”.';

  @override
  String get shortcutWifi =>
      'Automation → + → Wi‑Fi → your home network → “Leaves” and “Run Immediately” → Next → search “Eşik” → “Left home”.';

  @override
  String get shortcutNfc =>
      'Automation → + → NFC → “Scan” and hold the door tag to your phone → “Run Immediately” → Next → search “Eşik” → “Door tag”. Any NFC tag works.';

  @override
  String get shortcutSleep =>
      'Automation → + → Sleep (or Focus → Sleep) → “When Starts” and “Run Immediately” → Next → search “Eşik” → “Sleep started”.';

  @override
  String get shortcutWaiting =>
      'This step completes on its own once the automation runs.';

  @override
  String get shortcutSeen => 'The automation is working.';

  @override
  String get issueShortcut => 'The Shortcuts automation hasn’t run yet';

  @override
  String get hintShortcut =>
      'Arrives when your Shortcuts automation runs; the setup guide shows how.';

  @override
  String get plusFeatureTriggersIOS =>
      'Sleep, unplugging, Wi‑Fi and the NFC tag';
}
