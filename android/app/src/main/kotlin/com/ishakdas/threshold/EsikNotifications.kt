package com.ishakdas.threshold

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.os.Build

/** Bildirimin neden gönderildiği. Kayıtta "source" olarak saklanır. */
enum class Reason(val source: String) {
    TRIGGER("notification"),
    BACKUP("backup"),
    TEST("test"),
}

object EsikNotifications {
    const val CHANNEL_ID = "esik_thresholds"
    const val ACTION_ALL_DONE = "com.ishakdas.threshold.ALL_DONE"
    const val EXTRA_MODE = "mode"
    const val EXTRA_SOURCE = "source"
    const val EXTRA_ROUTE = "route"

    private const val ACCENT = 0xFFEF8636.toInt()

    fun notificationId(mode: Mode): Int = if (mode == Mode.EVENING) 1001 else 1002

    /** Bildirimde maddenin ikonunun kısa adı (lib/ui/esik_icons.dart ile aynı). */
    private val iconLabels = mapOf(
        "iron" to "Ütü", "plug" to "Priz", "flame" to "Ocak", "lock" to "Kilit",
        "key" to "Anahtar", "bag" to "Çanta", "wallet" to "Cüzdan", "bulb" to "Lamba",
        "pill" to "İlaç", "notes" to "Not", "checklist" to "Liste",
    )

    /** Tetikleyicinin geçmiş zamanlı hâli: "Şarja taktın". */
    private val triggerPast = mapOf(
        "charging" to "Şarja taktın",
        "silenced" to "Telefonu sessize aldın",
        "unsilenced" to "Telefonu sessizden çıkardın",
        "appClosed" to "Instagram’ı kapattın",
        "sleepMode" to "Uyku modu açıldı",
        "airplaneMode" to "Uçak modunu açtın",
        "alarmStopped" to "Alarmı durdurdun",
        "unplugged" to "Şarjdan çıkardın",
        "leftHomeWifi" to "Evden çıktın",
        "nfcTag" to "Kapıdaki etikete dokundun",
    )

    fun ensureChannel(c: Context) {
        val nm = c.getSystemService(NotificationManager::class.java)
        if (nm.getNotificationChannel(CHANNEL_ID) != null) return
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Eşik kontrolleri", NotificationManager.IMPORTANCE_HIGH)
                .apply { description = "Akşam ve sabah kontrol listesi hatırlatmaları" },
        )
    }

    fun hasPermission(c: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED

    /** Bildirim gönderilebildiyse true. */
    fun show(c: Context, mode: Mode, reason: Reason): Boolean {
        if (!hasPermission(c)) return false
        ensureChannel(c)
        val items = EsikData.items(c, mode)
        val config = EsikData.config(c, mode)

        val labels = items.mapNotNull { iconLabels[it.icon] }.distinct()
        val summary = when {
            items.isEmpty() -> "Kontrol listen boş. Madde eklemek için dokun."
            labels.isEmpty() -> "${items.size} maddelik kontrolün hazır."
            else -> "${items.size} madde: ${labels.joinToString(", ")}."
        }
        val text = when (reason) {
            Reason.TRIGGER -> "${triggerPast[config.kind] ?: "Eşik geldi"}. $summary"
            Reason.BACKUP -> "Kontrol saati. $summary"
            Reason.TEST -> "Deneme bildirimi. $summary"
        }
        val big = buildString {
            append(text)
            items.forEach { append("\n• ").append(it.title) }
        }

        val source = if (reason == Reason.BACKUP) "yedek" else "bildirim"
        val route = "/kontrol?mod=${mode.routeParam}&kaynak=$source"
        val requestBase = if (mode == Mode.EVENING) 10 else 20

        val open = PendingIntent.getActivity(
            c,
            requestBase + 1,
            Intent(c, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                putExtra(EXTRA_ROUTE, route)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val allDone = PendingIntent.getBroadcast(
            c,
            requestBase + 2,
            Intent(c, NotificationActionReceiver::class.java).apply {
                action = ACTION_ALL_DONE
                putExtra(EXTRA_MODE, mode.key)
                putExtra(EXTRA_SOURCE, reason.source)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val icon = Icon.createWithResource(c, R.drawable.ic_stat_esik)

        val builder = Notification.Builder(c, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_esik)
            .setColor(ACCENT)
            .setContentTitle(mode.title)
            .setContentText(text)
            .setStyle(Notification.BigTextStyle().bigText(big))
            .setCategory(Notification.CATEGORY_REMINDER)
            .setContentIntent(open)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
        if (items.isNotEmpty()) {
            builder.addAction(Notification.Action.Builder(icon, "Hepsi tamam", allDone).build())
        }
        builder.addAction(Notification.Action.Builder(icon, "Tek tek bak", open).build())

        c.getSystemService(NotificationManager::class.java).notify(notificationId(mode), builder.build())
        SilentAlerter.alertIfSilent(c)
        if (reason != Reason.TEST) EsikData.markNotified(c, EsikData.thresholdDay(), mode)
        return true
    }

    fun cancel(c: Context, mode: Mode) {
        c.getSystemService(NotificationManager::class.java).cancel(notificationId(mode))
    }
}
