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
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build

/** Bildirimin neden gönderildiği. Kayıtta "source" olarak saklanır. */
enum class Reason(val source: String) {
    TRIGGER("notification"),
    BACKUP("backup"),
    TEST("test"),
}

object EsikNotifications {
    /** Kanalın sesi sonradan değişmez; ses değişince kimlik de değişir. */
    const val CHANNEL_ID = "esik_thresholds_v2"
    private val OLD_CHANNELS = listOf("esik_thresholds")
    const val ACTION_ALL_DONE = "com.ishakdas.threshold.ALL_DONE"
    const val EXTRA_MODE = "mode"
    const val EXTRA_SOURCE = "source"
    const val EXTRA_ROUTE = "route"

    private const val ACCENT = 0xFFEF8636.toInt()

    fun notificationId(mode: Mode): Int = if (mode == Mode.EVENING) 1001 else 1002

    /** Bildirimde maddenin ikonunun kısa adı (lib/ui/esik_icons.dart ile aynı). */
    private val iconLabels = mapOf(
        "iron" to R.string.icon_iron, "plug" to R.string.icon_plug, "flame" to R.string.icon_flame,
        "lock" to R.string.icon_lock, "key" to R.string.icon_key, "bag" to R.string.icon_bag,
        "wallet" to R.string.icon_wallet, "bulb" to R.string.icon_bulb, "pill" to R.string.icon_pill,
        "notes" to R.string.icon_notes, "checklist" to R.string.icon_checklist,
    )

    /** Tetikleyicinin geçmiş zamanlı hâli: "Şarja taktın". */
    private val triggerPast = mapOf(
        "charging" to R.string.past_charging,
        "silenced" to R.string.past_silenced,
        "unsilenced" to R.string.past_unsilenced,
        "appClosed" to R.string.past_appClosed,
        "sleepMode" to R.string.past_sleepMode,
        "airplaneMode" to R.string.past_airplaneMode,
        "alarmStopped" to R.string.past_alarmStopped,
        "unplugged" to R.string.past_unplugged,
        "leftHomeWifi" to R.string.past_leftHomeWifi,
        "nfcTag" to R.string.past_nfcTag,
    )

    fun ensureChannel(context: Context) {
        val c = Lang.context(context)
        val nm = c.getSystemService(NotificationManager::class.java)
        val existing = nm.getNotificationChannel(CHANNEL_ID)
        if (existing != null) {
            // Dil değiştiyse kanalın adı da değişsin (ses ve önem değişmez).
            existing.name = c.getString(R.string.channel_name)
            existing.description = c.getString(R.string.channel_description)
            nm.createNotificationChannel(existing)
            return
        }
        OLD_CHANNELS.forEach { nm.deleteNotificationChannel(it) }
        val sound = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, c.getString(R.string.channel_name), NotificationManager.IMPORTANCE_HIGH).apply {
                description = c.getString(R.string.channel_description)
                setSound(chimeUri(c), sound)
            },
        )
    }

    /** Eşik'in kendi sesi (res/raw/esik_chime.ogg, tool/esik_chime.py ile üretilir). */
    fun chimeUri(c: Context): Uri = Uri.parse("android.resource://${c.packageName}/${R.raw.esik_chime}")

    fun hasPermission(c: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED

    /** Bildirim gönderilebildiyse true. */
    /** [kind]: bildirimi gönderen tetikleyici (yalnızca [Reason.TRIGGER] için). */
    fun show(c: Context, mode: Mode, reason: Reason, kind: String? = null): Boolean {
        if (!hasPermission(c)) return false
        ensureChannel(c)
        val items = EsikData.items(c, mode)
        val config = EsikData.config(c, mode)

        val res = Lang.context(c).resources
        val labels = items.mapNotNull { iconLabels[it.icon]?.let(res::getString) }.distinct()
        val summary = when {
            items.isEmpty() -> res.getString(R.string.summary_empty)
            labels.isEmpty() -> res.getQuantityString(R.plurals.summary_ready, items.size, items.size)
            else -> res.getQuantityString(R.plurals.summary_labels, items.size, items.size, labels.joinToString(", "))
        }
        val lead = when (reason) {
            Reason.TRIGGER -> res.getString(triggerPast[kind ?: config.kinds.first()] ?: R.string.past_default)
            Reason.BACKUP -> res.getString(R.string.reason_backup)
            Reason.TEST -> res.getString(R.string.reason_test)
        }
        val text = "$lead. $summary"
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
            .setContentTitle(res.getString(if (mode == Mode.EVENING) R.string.mode_evening else R.string.mode_morning))
            .setContentText(text)
            .setStyle(Notification.BigTextStyle().bigText(big))
            .setCategory(Notification.CATEGORY_REMINDER)
            .setContentIntent(open)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
        if (items.isNotEmpty()) {
            builder.addAction(Notification.Action.Builder(icon, res.getString(R.string.action_all_done), allDone).build())
        }
        builder.addAction(Notification.Action.Builder(icon, res.getString(R.string.action_one_by_one), open).build())

        c.getSystemService(NotificationManager::class.java).notify(notificationId(mode), builder.build())
        SilentAlerter.alertIfSilent(c)
        if (reason != Reason.TEST) EsikData.markNotified(c, EsikData.thresholdDay(), mode)
        return true
    }

    fun cancel(c: Context, mode: Mode) {
        c.getSystemService(NotificationManager::class.java).cancel(notificationId(mode))
    }
}
