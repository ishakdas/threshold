package com.ishakdas.threshold

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import java.time.Duration
import java.time.LocalDateTime
import java.time.LocalTime

/** Tetikleyicinin dinlendiği saat aralığı; gece yarısını aşabilir. */
data class Window(val start: LocalTime, val end: LocalTime) {
    fun contains(t: LocalTime): Boolean = when {
        start == end -> true
        start < end -> t >= start && t < end
        else -> t >= start || t < end
    }

    /** Bir sonraki açılışa kalan süre; şu an açıksa ve [skipCurrent] değilse 0. */
    fun delayUntilOpen(now: LocalDateTime, skipCurrent: Boolean = false): Long =
        if (!skipCurrent && contains(now.toLocalTime())) {
            0
        } else {
            Duration.between(now, BackupScheduler.nextOccurrence(start, now)).toMillis()
        }

    companion object {
        /** Aralık kapalıysa ("Her saatte") günün tamamı. */
        fun of(config: TriggerConfig): Window =
            if (config.windowEnabled) Window(config.windowStart, config.windowEnd) else ALL_DAY

        private val ALL_DAY = Window(LocalTime.MIDNIGHT, LocalTime.MIDNIGHT)
    }
}

/** Yedek saat ya da tetikleyici çaldığında ne oldu. Ayarlar ekranında gösterilir. */
enum class NotifyOutcome(val key: String) {
    SHOWN("shown"),
    ALREADY_DONE("alreadyDone"),
    ALREADY_NOTIFIED("alreadyNotified"),
    NO_PERMISSION("noPermission"),
    DISABLED("disabled"),
}

object Thresholds {
    /** O gün kontrol yapılmadıysa ve bildirim gelmediyse bildirim gönderir. */
    fun notifyIfDue(c: Context, mode: Mode, reason: Reason): NotifyOutcome {
        val day = EsikData.thresholdDay()
        return when {
            EsikData.isComplete(c, day, mode) -> NotifyOutcome.ALREADY_DONE
            EsikData.wasNotified(c, day, mode) -> NotifyOutcome.ALREADY_NOTIFIED
            EsikNotifications.show(c, mode, reason) -> NotifyOutcome.SHOWN
            else -> NotifyOutcome.NO_PERMISSION
        }
    }

    /** Bugünkü eşik zaten kapandı mı (kontrol yapıldı ya da bildirim geldi)? */
    fun handledToday(c: Context, mode: Mode): Boolean {
        val day = EsikData.thresholdDay()
        return EsikData.isComplete(c, day, mode) || EsikData.wasNotified(c, day, mode)
    }
}

/**
 * Davranış tetikleyicileri. Arka planda sürekli çalışan bir servis yerine
 * sistemin kendi koşullarını kullanır:
 *
 * - Şarja takınca: JobScheduler'ın "şarjda" koşulu, aralık açılınca devreye girer.
 * - Alarmı durdurunca: sıradaki alarm değişince (ACTION_NEXT_ALARM_CLOCK_CHANGED)
 *   çalan alarm fark edilir; erteleme bitene kadar beklenir.
 * - Ev Wi‑Fi'ından çıkınca: önce Wi‑Fi'a bağlıyken "kurulur", sonra telefon
 *   mobil veriye geçince bildirir. Wi‑Fi adı okunmadığı için konum izni gerekmez.
 * - Sessize alınca / sessizden çıkarınca: zil modu ve Rahatsız Etmeyin ayarı
 *   değişince JobScheduler uyandırır (TriggerContentUri); ek izin gerekmez.
 * - Kapıdaki etiket: etiket uygulamayı doğrudan açar (MainActivity), iş yok.
 */
object TriggerScheduler {
    const val JOB_CHARGING = 41
    const val JOB_ALARM = 42
    const val JOB_WIFI_ARM = 43
    const val JOB_WIFI_LEFT = 44
    const val JOB_SILENCE = 45

    /** Çalan alarmdan bu kadar sonra bakılır: kullanıcı alarmı kapatmış ya da ertelemiş olur. */
    private const val ALARM_SETTLE_MS = 90_000L

    /** Sıradaki alarm bundan yakınsa ertelenmiş sayılır. */
    private const val SNOOZE_MS = 30 * 60_000L

    private fun state(c: Context) = c.getSharedPreferences("esik_triggers", Context.MODE_PRIVATE)

    private fun jobs(c: Context) = c.getSystemService(JobScheduler::class.java)

    private fun job(c: Context, id: Int) =
        JobInfo.Builder(id, ComponentName(c, TriggerJobService::class.java))

    fun recordOutcome(c: Context, mode: Mode, outcome: NotifyOutcome) {
        state(c).edit()
            .putLong("last.${mode.key}.at", System.currentTimeMillis())
            .putString("last.${mode.key}.outcome", outcome.key)
            .apply()
    }

    fun lastAt(c: Context, mode: Mode): Long? =
        state(c).getLong("last.${mode.key}.at", 0L).takeIf { it > 0 }

    fun lastOutcome(c: Context, mode: Mode): String? =
        state(c).getString("last.${mode.key}.outcome", null)

    /** Ayara göre işleri yeniden kurar. Uygulama açılınca ve ayar değişince çağrılır. */
    fun schedule(c: Context) {
        val now = LocalDateTime.now()
        rememberNextAlarm(c)

        val evening = EsikData.config(c, Mode.EVENING)
        if (evening.kind == "charging") {
            val skip = Thresholds.handledToday(c, Mode.EVENING)
            scheduleCharging(c, Window.of(evening).delayUntilOpen(now, skip))
        } else {
            jobs(c).cancel(JOB_CHARGING)
        }

        val morning = EsikData.config(c, Mode.MORNING)
        if (evening.kind == "silenced" || morning.kind == "unsilenced") {
            // İş zaten bekliyorsa son bilinen durum onun; yeniden kurarken ezme.
            if (jobs(c).getPendingJob(JOB_SILENCE) == null) rememberSilent(c, isSilent(c))
            scheduleSilence(c)
        } else {
            jobs(c).cancel(JOB_SILENCE)
        }
        if (morning.kind != "alarmStopped") jobs(c).cancel(JOB_ALARM)
        if (morning.kind == "leftHomeWifi") {
            val window = Window.of(morning)
            val skip = Thresholds.handledToday(c, Mode.MORNING)
            if (!skip && window.contains(now.toLocalTime()) && armedToday(c)) {
                scheduleWifiLeft(c)
            } else {
                scheduleWifiArm(c, window.delayUntilOpen(now, skip))
            }
        } else {
            jobs(c).cancel(JOB_WIFI_ARM)
            jobs(c).cancel(JOB_WIFI_LEFT)
        }
    }

    private fun scheduleCharging(c: Context, delay: Long) {
        rememberFrom(c, JOB_CHARGING, delay)
        jobs(c).schedule(
            job(c, JOB_CHARGING).setRequiresCharging(true).setMinimumLatency(delay).build(),
        )
    }

    private fun scheduleWifiArm(c: Context, delay: Long) {
        rememberFrom(c, JOB_WIFI_ARM, delay)
        jobs(c).cancel(JOB_WIFI_LEFT)
        val b = job(c, JOB_WIFI_ARM).setMinimumLatency(delay)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            b.setRequiredNetwork(network(NetworkCapabilities.TRANSPORT_WIFI))
        } else {
            b.setRequiredNetworkType(JobInfo.NETWORK_TYPE_UNMETERED)
        }
        jobs(c).schedule(b.build())
    }

    private fun scheduleWifiLeft(c: Context) {
        jobs(c).cancel(JOB_WIFI_ARM)
        val b = job(c, JOB_WIFI_LEFT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            b.setRequiredNetwork(network(NetworkCapabilities.TRANSPORT_CELLULAR))
        } else {
            @Suppress("DEPRECATION")
            b.setRequiredNetworkType(JobInfo.NETWORK_TYPE_METERED)
        }
        jobs(c).schedule(b.build())
    }

    /** Zil modu (sessiz/titreşim/normal) ya da Rahatsız Etmeyin değişince çalışır. Tek seferlik. */
    private fun scheduleSilence(c: Context) {
        val b = job(c, JOB_SILENCE)
        for (name in listOf(Settings.Global.MODE_RINGER, "zen_mode")) {
            b.addTriggerContentUri(JobInfo.TriggerContentUri(Settings.Global.getUriFor(name), 0))
        }
        jobs(c).schedule(b.setTriggerContentUpdateDelay(500).setTriggerContentMaxDelay(3_000).build())
    }

    /** Sessiz: zil normal değil (sessiz ya da titreşim) veya Rahatsız Etmeyin açık. */
    fun isSilent(c: Context): Boolean {
        val ringer = c.getSystemService(AudioManager::class.java).ringerMode
        val filter = c.getSystemService(NotificationManager::class.java).currentInterruptionFilter
        return ringer != AudioManager.RINGER_MODE_NORMAL ||
            filter == NotificationManager.INTERRUPTION_FILTER_PRIORITY ||
            filter == NotificationManager.INTERRUPTION_FILTER_ALARMS ||
            filter == NotificationManager.INTERRUPTION_FILTER_NONE
    }

    private fun rememberSilent(c: Context, silent: Boolean) {
        state(c).edit().putBoolean("silent", silent).apply()
    }

    /** Varsayılan ağın bu türden olması koşulu. VPN arkasında da çalışsın diye NOT_VPN kaldırılır. */
    private fun network(transport: Int): NetworkRequest = NetworkRequest.Builder()
        .addTransportType(transport)
        .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        .removeCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        .build()

    /** Bekleyen tetikleyici işinin ne zamandan itibaren devrede olduğu (durum satırı için). */
    private fun rememberFrom(c: Context, job: Int, delay: Long) {
        state(c).edit().putLong("from.$job", System.currentTimeMillis() + delay).apply()
    }

    private fun from(c: Context, job: Int): Long? =
        state(c).getLong("from.$job", 0L).takeIf { it > 0 }

    /**
     * Dart'a: tetikleyici şu an neyi bekliyor. "wait" adları Dart'taki
     * TriggerWait ile aynıdır; "at" o beklemeyle ilgili an (ms).
     */
    fun waiting(c: Context, mode: Mode): Map<String, Any?>? {
        val kind = EsikData.config(c, mode).kind
        val pending = { id: Int -> jobs(c).getPendingJob(id) != null }
        return when {
            mode == Mode.EVENING && kind == "charging" ->
                if (pending(JOB_CHARGING)) mapOf("wait" to "charging", "at" to from(c, JOB_CHARGING)) else mapOf("wait" to "none")
            mode == Mode.MORNING && kind == "alarmStopped" -> {
                val next = nextAlarm(c)
                when {
                    pending(JOB_ALARM) -> mapOf("wait" to "alarmSettling")
                    next > 0 -> mapOf("wait" to "alarm", "at" to next)
                    else -> mapOf("wait" to "noAlarm")
                }
            }
            mode == Mode.EVENING && kind == "silenced" -> when {
                !pending(JOB_SILENCE) -> mapOf("wait" to "none")
                isSilent(c) -> mapOf("wait" to "alreadySilent")
                else -> mapOf("wait" to "silence")
            }
            mode == Mode.MORNING && kind == "unsilenced" -> when {
                !pending(JOB_SILENCE) -> mapOf("wait" to "none")
                isSilent(c) -> mapOf("wait" to "unsilence")
                else -> mapOf("wait" to "notSilent")
            }
            mode == Mode.MORNING && kind == "leftHomeWifi" -> when {
                pending(JOB_WIFI_LEFT) -> mapOf("wait" to "leaving")
                pending(JOB_WIFI_ARM) -> mapOf("wait" to "wifi", "at" to from(c, JOB_WIFI_ARM))
                else -> mapOf("wait" to "none")
            }
            else -> null
        }
    }

    private fun armedToday(c: Context): Boolean =
        state(c).getString("wifi.armed", null) == EsikData.thresholdDay().toString()

    private fun setArmed(c: Context, armed: Boolean) {
        state(c).edit().apply {
            if (armed) putString("wifi.armed", EsikData.thresholdDay().toString()) else remove("wifi.armed")
        }.apply()
    }

    private fun nextAlarm(c: Context): Long =
        c.getSystemService(AlarmManager::class.java).nextAlarmClock?.triggerTime ?: 0L

    private fun rememberNextAlarm(c: Context) {
        state(c).edit().putLong("alarm.next", nextAlarm(c)).apply()
    }

    /** Sıradaki alarm değişti: önceki alarm az önce çaldıysa kısa süre sonra bak. */
    fun onNextAlarmChanged(c: Context) {
        val previous = state(c).getLong("alarm.next", 0L)
        rememberNextAlarm(c)
        if (EsikData.config(c, Mode.MORNING).kind != "alarmStopped") return
        val now = System.currentTimeMillis()
        val rang = previous > 0 && previous <= now + 60_000 && now - previous < 3 * 3_600_000L
        if (!rang) return
        jobs(c).schedule(job(c, JOB_ALARM).setMinimumLatency(ALARM_SETTLE_MS).build())
    }

    /** TriggerJobService'ten çağrılır. */
    fun onJob(c: Context, id: Int) {
        val now = LocalDateTime.now()
        when (id) {
            JOB_CHARGING -> {
                val config = EsikData.config(c, Mode.EVENING)
                val window = Window.of(config)
                if (config.kind == "charging" && window.contains(now.toLocalTime())) {
                    recordOutcome(c, Mode.EVENING, Thresholds.notifyIfDue(c, Mode.EVENING, Reason.TRIGGER))
                }
                // Hâlâ şarjdayken hemen yeniden çalışmasın: bir sonraki aralığı bekle.
                later { if (config.kind == "charging") scheduleCharging(c, window.delayUntilOpen(now, true)) }
            }
            JOB_ALARM -> {
                val config = EsikData.config(c, Mode.MORNING)
                val next = nextAlarm(c)
                val snoozed = next > 0 && next - System.currentTimeMillis() < SNOOZE_MS
                // Ertelendiyse sıradaki çalışta yeniden bakılır.
                if (config.kind == "alarmStopped" && !snoozed &&
                    Window.of(config).contains(now.toLocalTime())
                ) {
                    recordOutcome(c, Mode.MORNING, Thresholds.notifyIfDue(c, Mode.MORNING, Reason.TRIGGER))
                }
            }
            JOB_SILENCE -> {
                val before = state(c).getBoolean("silent", false)
                val silent = isSilent(c)
                rememberSilent(c, silent)
                // Sessize alındı: akşam eşiği. Sessizden çıkarıldı: sabah eşiği.
                val mode = when {
                    !before && silent -> Mode.EVENING
                    before && !silent -> Mode.MORNING
                    else -> null
                }
                val wanted = if (mode == Mode.EVENING) "silenced" else "unsilenced"
                if (mode != null) {
                    val config = EsikData.config(c, mode)
                    if (config.kind == wanted && Window.of(config).contains(now.toLocalTime())) {
                        recordOutcome(c, mode, Thresholds.notifyIfDue(c, mode, Reason.TRIGGER))
                    }
                }
                later { scheduleSilence(c) }
            }
            JOB_WIFI_ARM -> {
                val config = EsikData.config(c, Mode.MORNING)
                val window = Window.of(config)
                if (config.kind != "leftHomeWifi") return
                if (window.contains(now.toLocalTime()) && !Thresholds.handledToday(c, Mode.MORNING)) {
                    setArmed(c, true)
                    later { scheduleWifiLeft(c) }
                } else {
                    later { scheduleWifiArm(c, window.delayUntilOpen(now, true)) }
                }
            }
            JOB_WIFI_LEFT -> {
                val config = EsikData.config(c, Mode.MORNING)
                val window = Window.of(config)
                if (config.kind != "leftHomeWifi") return
                if (window.contains(now.toLocalTime()) && armedToday(c)) {
                    recordOutcome(c, Mode.MORNING, Thresholds.notifyIfDue(c, Mode.MORNING, Reason.TRIGGER))
                }
                setArmed(c, false)
                later { scheduleWifiArm(c, window.delayUntilOpen(now, true)) }
            }
        }
    }

    /** Çalışan işle aynı kimlikle iş kurmak onu durdurur; iş bittikten sonra kur. */
    private fun later(block: () -> Unit) {
        Handler(Looper.getMainLooper()).post(block)
    }
}

class TriggerJobService : JobService() {
    override fun onStartJob(params: JobParameters): Boolean {
        TriggerScheduler.onJob(applicationContext, params.jobId)
        return false
    }

    override fun onStopJob(params: JobParameters): Boolean = false
}

/** Saat uygulamasındaki sıradaki alarm değişti (alarm çaldı, ertelendi ya da düzenlendi). */
class AlarmChangedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != AlarmManager.ACTION_NEXT_ALARM_CLOCK_CHANGED) return
        TriggerScheduler.onNextAlarmChanged(context)
    }
}

/** Kapıdaki NFC etiketine Eşik'in bağlantısını yazar. */
object NfcTagWriter {
    const val SCHEME = "esik"
    const val HOST = "kontrol"

    fun message(packageName: String) = NdefMessage(
        arrayOf(
            NdefRecord.createUri("$SCHEME://$HOST"),
            // Eşik yüklü değilse Play Store'a, yüklüyse doğrudan uygulamaya gider.
            NdefRecord.createApplicationRecord(packageName),
        ),
    )

    /** Sonuç Dart'taki NfcWriteResult adlarıyla aynıdır. */
    fun write(tag: Tag, packageName: String): String {
        val msg = message(packageName)
        Ndef.get(tag)?.let { ndef ->
            return try {
                ndef.connect()
                when {
                    !ndef.isWritable -> "readOnly"
                    ndef.maxSize < msg.byteArrayLength -> "tooSmall"
                    else -> {
                        ndef.writeNdefMessage(msg)
                        "written"
                    }
                }
            } catch (e: Exception) {
                "error"
            } finally {
                runCatching { ndef.close() }
            }
        }
        NdefFormatable.get(tag)?.let { formatable ->
            return try {
                formatable.connect()
                formatable.format(msg)
                "written"
            } catch (e: Exception) {
                "error"
            } finally {
                runCatching { formatable.close() }
            }
        }
        return "incompatible"
    }
}
