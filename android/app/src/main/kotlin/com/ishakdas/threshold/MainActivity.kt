package com.ishakdas.threshold

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EsikNotifications.ensureChannel(this)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "esik/native")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeLaunchRoute" -> {
                    val route = intent?.getStringExtra(EsikNotifications.EXTRA_ROUTE)
                    intent?.removeExtra(EsikNotifications.EXTRA_ROUTE)
                    result.success(route)
                }
                "rescheduleBackups" -> {
                    BackupScheduler.schedule(this)
                    result.success(null)
                }
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
                "openBatterySettings" -> {
                    openSettings(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
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
        val route = intent.getStringExtra(EsikNotifications.EXTRA_ROUTE) ?: return
        intent.removeExtra(EsikNotifications.EXTRA_ROUTE)
        channel?.invokeMethod("openRoute", route)
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

    private fun openSettings(action: String) {
        if (!startActivitySafely(Intent(action))) {
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
