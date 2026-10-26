package com.ishakdas.threshold

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.nfc.NfcAdapter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.AlarmClock
import android.provider.Settings
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Android tarafından Flutter'a haber vermek için (ör. bildirimden "Hepsi tamam"). */
object EsikBridge {
    @Volatile
    var channel: MethodChannel? = null

    fun notifyDataChanged() {
        val ch = channel ?: return
        Handler(Looper.getMainLooper()).post { ch.invokeMethod("dataChanged", null) }
    }
}

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var permissionResult: MethodChannel.Result? = null
    private var nfcResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EsikNotifications.ensureChannel(this)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "esik/native")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeLaunchRoute" -> result.success(takeRoute(intent))
                "reschedule" -> {
                    BackupScheduler.schedule(this)
                    TriggerScheduler.schedule(this)
                    result.success(BackupScheduler.status(this))
                }
                "backupStatus" -> result.success(BackupScheduler.status(this))
                "notificationsGranted" -> result.success(EsikNotifications.hasPermission(this))
                "requestNotificationPermission" -> requestNotificationPermission(result)
                "showTestNotification" -> {
                    val mode = Mode.of(call.argument<String>("mode")) ?: Mode.EVENING
                    result.success(EsikNotifications.show(this, mode, Reason.TEST))
                }
                "isIgnoringBatteryOptimizations" -> {
                    val pm = getSystemService(PowerManager::class.java)
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "setupHealth" -> result.success(setupHealth())
                "openBatterySettings" -> {
                    openBatterySettings()
                    result.success(null)
                }
                "openClock" -> {
                    startActivitySafely(Intent(AlarmClock.ACTION_SHOW_ALARMS))
                    result.success(null)
                }
                "writeNfcTag" -> writeNfcTag(result)
                "cancelNfcTag" -> {
                    finishNfc("cancelled")
                    result.success(null)
                }
                "openNfcSettings" -> {
                    openSettings(Settings.ACTION_NFC_SETTINGS)
                    result.success(null)
                }
                "openNotificationSettings" -> {
                    startActivitySafely(
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName),
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        channel = ch
        EsikBridge.channel = ch
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = takeRoute(intent) ?: return
        channel?.invokeMethod("openRoute", route)
    }

    /**
     * Açılıştaki yönlendirme, bir kez: bildirimdeki ekran ya da kapıdaki
     * NFC etiketi (esik://kontrol, o anki modun kontrolünü açar).
     */
    private fun takeRoute(intent: Intent?): String? {
        if (intent == null) return null
        intent.getStringExtra(EsikNotifications.EXTRA_ROUTE)?.let {
            intent.removeExtra(EsikNotifications.EXTRA_ROUTE)
            return it
        }
        val data = intent.data
        if (intent.action == NfcAdapter.ACTION_NDEF_DISCOVERED &&
            data?.scheme == NfcTagWriter.SCHEME && data.host == NfcTagWriter.HOST
        ) {
            intent.action = Intent.ACTION_MAIN
            intent.data = null
            return "/kontrol"
        }
        return null
    }

    private fun writeNfcTag(result: MethodChannel.Result) {
        val adapter = NfcAdapter.getDefaultAdapter(this)
        when {
            adapter == null -> result.success("unsupported")
            !adapter.isEnabled -> result.success("disabled")
            else -> {
                finishNfc("cancelled")
                nfcResult = result
                val flags = NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B or
                    NfcAdapter.FLAG_READER_NFC_F or NfcAdapter.FLAG_READER_NFC_V
                adapter.enableReaderMode(this, { tag ->
                    val outcome = NfcTagWriter.write(tag, packageName)
                    runOnUiThread { finishNfc(outcome) }
                }, flags, null)
            }
        }
    }

    private fun finishNfc(outcome: String) {
        val result = nfcResult ?: return
        nfcResult = null
        if (outcome == "written") TriggerScheduler.setNfcTagWritten(this)
        NfcAdapter.getDefaultAdapter(this)?.let { runCatching { it.disableReaderMode(this) } }
        result.success(outcome)
    }

    // Okuyucu modu yalnızca ön plandayken çalışır.
    override fun onPause() {
        finishNfc("cancelled")
        super.onPause()
    }

    override fun onDestroy() {
        if (EsikBridge.channel === channel) EsikBridge.channel = null
        super.onDestroy()
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (EsikNotifications.hasPermission(this)) {
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(false)
            return
        }
        permissionResult?.success(false)
        permissionResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_NOTIFICATIONS) return
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        permissionResult?.success(granted)
        permissionResult = null
    }

    /**
     * Önce Android'in "Arka planda çalışmaya izin verilsin mi?" penceresi: tek
     * dokunuşla Samsung'daki "Kısıtlamasız" ile aynı sonuç. Açılamazsa uygulama
     * bilgileri ve ne yapılacağını söyleyen bir ipucu.
     */
    private fun openBatterySettings() {
        val pm = getSystemService(PowerManager::class.java)
        if (pm.isIgnoringBatteryOptimizations(packageName)) return
        val ask = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:$packageName"))
        if (startActivitySafely(ask)) return
        openSettings(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, withPackage = true)
        Toast.makeText(this, Lang.context(this).getString(R.string.battery_hint), Toast.LENGTH_LONG).show()
    }

    /** Kurulum rehberi için gerçek durum. Adlar Dart'taki SetupHealth.parse ile aynıdır. */
    private fun setupHealth(): Map<String, Any?> {
        val nm = getSystemService(NotificationManager::class.java)
        val channel = nm.getNotificationChannel(EsikNotifications.CHANNEL_ID)
        val audio = getSystemService(AudioManager::class.java)
        val nfc = NfcAdapter.getDefaultAdapter(this)
        return mapOf(
            "notificationPermission" to EsikNotifications.hasPermission(this),
            "notificationsEnabled" to (
                nm.areNotificationsEnabled() &&
                    channel?.importance != NotificationManager.IMPORTANCE_NONE
                ),
            "battery" to getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(packageName),
            "nfc" to when {
                nfc == null -> "unsupported"
                nfc.isEnabled -> "on"
                else -> "off"
            },
            "nfcTagWritten" to TriggerScheduler.nfcTagWritten(this),
            "nextAlarm" to getSystemService(AlarmManager::class.java).nextAlarmClock?.triggerTime,
            "alarmVolume" to audio.getStreamVolume(AudioManager.STREAM_ALARM),
        )
    }

    private fun openSettings(action: String, withPackage: Boolean = false) {
        val intent = Intent(action)
        if (withPackage) intent.data = Uri.parse("package:$packageName")
        if (!startActivitySafely(intent)) {
            startActivitySafely(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")),
            )
        }
    }

    private fun startActivitySafely(intent: Intent): Boolean = try {
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    } catch (e: Exception) {
        false
    }

    private companion object {
        const val REQUEST_NOTIFICATIONS = 41
    }
}
