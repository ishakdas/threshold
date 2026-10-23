package com.ishakdas.threshold

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId

/** Bildirimdeki "Hepsi tamam": uygulamayı açmadan kontrolü tamamlar. */
class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != EsikNotifications.ACTION_ALL_DONE) return
        val mode = Mode.of(intent.getStringExtra(EsikNotifications.EXTRA_MODE)) ?: return
        val source = intent.getStringExtra(EsikNotifications.EXTRA_SOURCE) ?: Reason.TRIGGER.source
        // Deneme bildirimindeki buton kaydı değiştirmez.
        if (source != Reason.TEST.source) EsikData.completeAll(context, mode, source)
        EsikNotifications.cancel(context, mode)
        EsikBridge.notifyDataChanged()
    }
}

/**
 * Yedek saat. Hiçbir tetikleyici o gün bildirim göndermediyse ve kontrol
 * yapılmadıysa sabit saatte hatırlatır, sonra ertesi günü kurar.
 */
class BackupReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val mode = Mode.of(intent.getStringExtra(EsikNotifications.EXTRA_MODE))
        if (mode != null) {
            val day = EsikData.thresholdDay()
            val outcome = when {
                !EsikData.config(context, mode).backupEnabled -> BackupOutcome.DISABLED
                EsikData.isComplete(context, day, mode) -> BackupOutcome.ALREADY_DONE
                EsikData.wasNotified(context, day, mode) -> BackupOutcome.ALREADY_NOTIFIED
                EsikNotifications.show(context, mode, Reason.BACKUP) -> BackupOutcome.SHOWN
                else -> BackupOutcome.NO_PERMISSION
            }
            BackupScheduler.recordOutcome(context, mode, outcome)
        }
        BackupScheduler.schedule(context)
    }
}

/** Telefon yeniden başlayınca, uygulama güncellenince ya da saat değişince alarmları yeniden kurar. */
class RescheduleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        BackupScheduler.schedule(context)
    }
}

/** Yedek alarm çaldığında ne oldu. Ayarlar ekranında gösterilir. */
enum class BackupOutcome(val key: String) {
    SHOWN("shown"),
    ALREADY_DONE("alreadyDone"),
    ALREADY_NOTIFIED("alreadyNotified"),
    NO_PERMISSION("noPermission"),
    DISABLED("disabled"),
}

object BackupScheduler {
    private fun state(c: Context) = c.getSharedPreferences("esik_backup", Context.MODE_PRIVATE)

    fun recordOutcome(c: Context, mode: Mode, outcome: BackupOutcome) {
        state(c).edit()
            .putLong("last.${mode.key}.at", System.currentTimeMillis())
            .putString("last.${mode.key}.outcome", outcome.key)
            .apply()
    }

    /** Dart'a: her mod için sıradaki alarm ve son alarmın sonucu. */
    fun status(c: Context): Map<String, Map<String, Any?>> {
        val p = state(c)
        return Mode.entries.associate { mode ->
            val k = mode.key
            mode.key to mapOf(
                "next" to p.getLong("next.$k", 0L).takeIf { it > 0 },
                "lastAt" to p.getLong("last.$k.at", 0L).takeIf { it > 0 },
                "lastOutcome" to p.getString("last.$k.outcome", null),
            )
        }
    }

    private fun pending(c: Context, mode: Mode): PendingIntent = PendingIntent.getBroadcast(
        c,
        if (mode == Mode.EVENING) 31 else 32,
        Intent(c, BackupReceiver::class.java).putExtra(EsikNotifications.EXTRA_MODE, mode.key),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    /** [time]'ın şu andan sonraki ilk gerçekleşmesi. */
    fun nextOccurrence(time: LocalTime, now: LocalDateTime = LocalDateTime.now()): LocalDateTime {
        val today = now.toLocalDate().atTime(time)
        return if (today.isAfter(now)) today else today.plusDays(1)
    }

    fun schedule(c: Context) {
        val am = c.getSystemService(AlarmManager::class.java)
        for (mode in Mode.entries) {
            val pi = pending(c, mode)
            am.cancel(pi)
            val config = EsikData.config(c, mode)
            if (!config.backupEnabled) {
                state(c).edit().remove("next.${mode.key}").apply()
                continue
            }
            val at = nextOccurrence(config.backupTime)
                .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
            state(c).edit().putLong("next.${mode.key}", at).apply()
            // Kesin alarm izni (SCHEDULE_EXACT_ALARM) istemiyoruz: bir hatırlatma
            // için birkaç dakikalık gecikme kabul edilebilir. Bu alarm Doze'da da çalışır.
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
        }
    }
}
