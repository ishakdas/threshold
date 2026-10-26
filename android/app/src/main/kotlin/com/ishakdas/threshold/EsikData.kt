package com.ishakdas.threshold

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter

/** Akşam ve sabah eşikleri. [key], Dart'taki DayMode adıyla aynıdır. */
enum class Mode(val key: String, val routeParam: String) {
    EVENING("evening", "aksam"),
    MORNING("morning", "sabah");

    companion object {
        fun of(key: String?): Mode? = entries.firstOrNull { it.key == key }
    }
}

data class CheckItem(val id: String, val title: String, val icon: String)

data class TriggerConfig(
    /** Seçili tetikleyiciler (Dart'taki TriggerKind adları). */
    val kinds: List<String>,
    /** Çalıştığı günler: 1 = Pazartesi … 7 = Pazar. */
    val days: Set<Int>,
    val windowStart: LocalTime,
    val windowEnd: LocalTime,
    val windowEnabled: Boolean,
    val backupEnabled: Boolean,
    val backupTime: LocalTime,
) {
    fun has(kind: String): Boolean = kind in kinds

    fun activeOn(day: LocalDate): Boolean = day.dayOfWeek.value in days
}

/**
 * Dart tarafının shared_preferences ile yazdığı veriye Android'den erişim.
 *
 * shared_preferences_android (2.4.x, eski API) her şeyi "FlutterSharedPreferences"
 * dosyasında "flutter." önekiyle saklar. Biçimler lib/data/models.dart ve
 * lib/data/app_state.dart ile aynı tutulmalıdır.
 */
object EsikData {
    private const val FILE = "FlutterSharedPreferences"
    private const val PREFIX = "flutter."
    private const val CHECKLIST = "checklist.v1"
    private const val TRIGGERS = "triggers.v1"
    private const val LOG = "log.v1"

    private val ALL_DAYS = (1..7).toSet()

    private val isoLocal: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")

    private val defaultConfigs = mapOf(
        Mode.EVENING to TriggerConfig(
            listOf("charging"), ALL_DAYS, LocalTime.of(22, 0), LocalTime.of(2, 0), true, true, LocalTime.of(22, 30),
        ),
        Mode.MORNING to TriggerConfig(
            listOf("alarmStopped"), ALL_DAYS, LocalTime.of(6, 0), LocalTime.of(10, 0), true, true, LocalTime.of(8, 15),
        ),
    )

    /** Gün 04:00'te başlar (Dart'taki thresholdDay ile aynı). */
    fun thresholdDay(now: LocalDateTime = LocalDateTime.now()): LocalDate =
        now.minusHours(4).toLocalDate()

    private fun prefs(c: Context): SharedPreferences =
        c.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    private fun readJson(c: Context, key: String): JSONObject? {
        val raw = prefs(c).getString(PREFIX + key, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (e: Exception) {
            null
        }
    }

    fun items(c: Context, mode: Mode): List<CheckItem> {
        val list = readJson(c, CHECKLIST)?.optJSONArray(mode.key) ?: return emptyList()
        return (0 until list.length()).mapNotNull { i ->
            val o = list.optJSONObject(i) ?: return@mapNotNull null
            val id = o.optString("id")
            if (id.isEmpty()) null else CheckItem(id, o.optString("title"), o.optString("icon"))
        }
    }

    private fun time(v: String?, fallback: LocalTime): LocalTime = try {
        if (v == null) fallback else LocalTime.parse(v)
    } catch (e: Exception) {
        fallback
    }

    /** Plus olmadan kullanılabilen tetikleyiciler (Dart'taki TriggerKind.free). */
    private val FREE_KINDS = setOf("charging", "silenced", "alarmStopped", "unsilenced")

    /** İlk açılıştan itibaren Plus'ın açık olduğu gün sayısı (Dart'taki plusTrialDays). */
    private const val TRIAL_DAYS = 15L

    /** Eşik Plus açık mı: satın alındı ya da deneme sürüyor (Dart'taki PlusState.active). */
    fun plusActive(c: Context): Boolean {
        if (prefs(c).getBoolean(PREFIX + "plus_owned", false)) return true
        // Deneme başlangıcı: uygulamanın kaydı ya da (veriler silindiyse)
        // Android'in kurulum zamanı, hangisi eskiyse (TrialAnchor).
        val start = java.time.Instant.ofEpochMilli(TrialAnchor.earliest(c))
            .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime()
        return thresholdDay() < thresholdDay(start).plusDays(TRIAL_DAYS)
    }

    /**
     * Geçerli eşik ayarı. Plus yoksa tek ve ücretsiz bir tetikleyici, her gün
     * (Dart'taki TriggerConfig.effective); kullanıcının asıl seçimi diskte kalır.
     */
    fun config(c: Context, mode: Mode): TriggerConfig {
        val raw = rawConfig(c, mode)
        if (plusActive(c)) return raw
        val kind = raw.kinds.firstOrNull { it in FREE_KINDS } ?: defaultConfigs.getValue(mode).kinds.first()
        return raw.copy(kinds = listOf(kind), days = ALL_DAYS)
    }

    private fun rawConfig(c: Context, mode: Mode): TriggerConfig {
        val d = defaultConfigs.getValue(mode)
        val o = readJson(c, TRIGGERS)?.optJSONObject(mode.key) ?: return d
        // Eski kayıtlarda tek "kind" alanı vardı.
        val kinds = o.optJSONArray("kinds")?.let { a -> (0 until a.length()).map { a.optString(it) } }
            ?: o.optString("kind", "").takeIf { it.isNotEmpty() }?.let { listOf(it) }
        val days = o.optJSONArray("days")?.let { a -> (0 until a.length()).map { a.optInt(it) }.filter { it in 1..7 }.toSet() }
        return TriggerConfig(
            kinds = kinds?.filter { it.isNotEmpty() }?.takeIf { it.isNotEmpty() } ?: d.kinds,
            days = days?.takeIf { it.isNotEmpty() } ?: d.days,
            windowStart = time(o.optString("windowStart", ""), d.windowStart),
            windowEnd = time(o.optString("windowEnd", ""), d.windowEnd),
            windowEnabled = o.optBoolean("windowEnabled", d.windowEnabled),
            backupEnabled = o.optBoolean("backupEnabled", d.backupEnabled),
            backupTime = time(o.optString("backupTime", ""), d.backupTime),
        )
    }

    /** Uygulamanın dili: "system", "tr", "en" ya da "es" (Dart'taki AppLanguage). */
    fun language(c: Context): String = prefs(c).getString(PREFIX + "language", null) ?: "system"

    /** Sessizdeyken bildirim: "quiet", "vibrate" ya da "ring" (Dart'taki SilentAlert). */
    fun silentAlert(c: Context): String =
        if (plusActive(c)) prefs(c).getString(PREFIX + "silent_alert", null) ?: "quiet" else "quiet"

    fun isComplete(c: Context, day: LocalDate, mode: Mode): Boolean =
        readJson(c, LOG)?.optJSONObject(day.toString())?.optJSONObject(mode.key)
            ?.has("completedAt") == true

    /**
     * O eşik gününün kontrolünü tamamlanmış olarak yazar. [source]:
     * "notification" (bildirimdeki Hepsi tamam) ya da "backup" (yedek saatteki bildirim).
     */
    @Synchronized
    fun completeAll(c: Context, mode: Mode, source: String, now: LocalDateTime = LocalDateTime.now()) {
        val day = thresholdDay(now).toString()
        val log = readJson(c, LOG) ?: JSONObject()
        val modes = log.optJSONObject(day) ?: JSONObject()
        modes.put(
            mode.key,
            JSONObject()
                .put("checked", JSONArray(items(c, mode).map { it.id }))
                .put("completedAt", now.format(isoLocal))
                .put("source", source),
        )
        log.put(day, modes)
        prefs(c).edit().putString(PREFIX + LOG, log.toString()).commit()
    }

    // Bildirim gönderildi mi? Yalnızca Android tarafı kullanır; ayrı dosyada durur.
    private fun native(c: Context) = c.getSharedPreferences("esik_native", Context.MODE_PRIVATE)

    fun wasNotified(c: Context, day: LocalDate, mode: Mode): Boolean =
        native(c).getBoolean("notified.$day.${mode.key}", false)

    fun markNotified(c: Context, day: LocalDate, mode: Mode) {
        val p = native(c)
        val keep = "notified.$day."
        p.edit().apply {
            // Eski günlerin işaretlerini temizle.
            p.all.keys.filter { it.startsWith("notified.") && !it.startsWith(keep) }.forEach { remove(it) }
            putBoolean("notified.$day.${mode.key}", true)
        }.apply()
    }
}
