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
    /** Tetikleyiciden kaç saniye sonra bildirilir; 0: hemen. */
    val delaySeconds: Int = 0,
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
    private const val THRESHOLDS = "triggers.v2"
    private const val LOG = "log.v1"

    private val ALL_DAYS = (1..7).toSet()

    /** Dart'taki TriggerConfig.maxDelay ile aynı. */
    const val MAX_DELAY_SECONDS = 3599

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

    /**
     * O eşik gününün listesi: maddenin günleri ve hava koşulu süzülmüş hâli
     * (Dart'taki todayItemsProvider). Hava bilinmiyorsa koşul sayılmaz.
     */
    fun items(c: Context, mode: Mode, day: LocalDate = thresholdDay()): List<CheckItem> {
        val list = readJson(c, CHECKLIST)?.optJSONArray(mode.key) ?: return emptyList()
        // Sabah o günün, akşam ertesi günün havasına bakılır.
        val forecast = weather(c, if (mode == Mode.MORNING) day else day.plusDays(1))
        return (0 until list.length()).mapNotNull { i ->
            val o = list.optJSONObject(i) ?: return@mapNotNull null
            val id = o.optString("id")
            if (id.isEmpty()) return@mapNotNull null
            val days = o.optJSONArray("days")?.let { a -> (0 until a.length()).map { a.optInt(it) }.toSet() }
            if (days != null && days.isNotEmpty() && day.dayOfWeek.value !in days) return@mapNotNull null
            if (forecast != null && !forecast.matches(o.optString("weather", "always"))) return@mapNotNull null
            CheckItem(id, o.optString("title"), o.optString("icon"))
        }
    }

    /** Dart'ın kaydettiği hava tahmini (lib/data/weather.dart). */
    private class Forecast(val rain: Int, val min: Double, val max: Double) {
        fun matches(need: String): Boolean = when (need) {
            "rain" -> rain >= 50
            "cold" -> min <= 5.0
            "hot" -> max >= 28.0
            else -> true
        }
    }

    private fun weather(c: Context, day: LocalDate): Forecast? {
        val o = readJson(c, "weather.v1")?.optJSONObject("days")?.optJSONObject(day.toString()) ?: return null
        if (!o.has("rain") || !o.has("min") || !o.has("max")) return null
        return Forecast(o.optInt("rain"), o.optDouble("min"), o.optDouble("max"))
    }

    /** Israrcı hatırlatma: toplam bildirim sayısı ve aralık (Dart'taki ReminderSettings). */
    fun reminders(c: Context): Pair<Int, Int> {
        val o = readJson(c, "reminders.v1")
        val max = (o?.optInt("max", 5) ?: 5).coerceIn(1, 5)
        val minutes = o?.optInt("minutes", 10)?.takeIf { it in listOf(5, 10, 15, 30) } ?: 10
        return max to minutes
    }

    /** Bugünkü kontrolün bitiş anı ("HH:mm"); yapılmadıysa null. Widget için. */
    fun completedAt(c: Context, day: LocalDate, mode: Mode): String? {
        val raw = readJson(c, LOG)?.optJSONObject(day.toString())?.optJSONObject(mode.key)
            ?.optString("completedAt", "")?.takeIf { it.isNotEmpty() } ?: return null
        return runCatching { LocalDateTime.parse(raw.take(19)).toLocalTime().toString().take(5) }.getOrNull()
    }

    private fun time(v: String?, fallback: LocalTime): LocalTime = try {
        if (v == null) fallback else LocalTime.parse(v)
    } catch (e: Exception) {
        fallback
    }

    /** Plus olmadan kullanılabilen tetikleyiciler (Dart'taki TriggerKind.free). */
    private val FREE_KINDS = setOf("charging", "alarmStopped")

    /** İlk açılıştan itibaren Plus'ın açık olduğu gün sayısı (Dart'taki plusTrialDays). */
    private const val TRIAL_DAYS = 15L

    /** Eşik Plus açık mı: satın alındı ya da deneme sürüyor (Dart'taki PlusState.active). */
    fun plusActive(c: Context): Boolean {
        if (prefs(c).getBoolean(PREFIX + "plus_owned", false)) return true
        // Test APK'sı: deneme dakikayla ölçülür (Dart'taki trialMinutesOverride).
        if (BuildConfig.TRIAL_MINUTES > 0) {
            return System.currentTimeMillis() < TrialAnchor.earliest(c) + BuildConfig.TRIAL_MINUTES * 60_000L
        }
        // Deneme başlangıcı: uygulamanın kaydı ya da (veriler silindiyse)
        // Android'in kurulum zamanı, hangisi eskiyse (TrialAnchor).
        val start = java.time.Instant.ofEpochMilli(TrialAnchor.earliest(c))
            .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime()
        return thresholdDay() < thresholdDay(start).plusDays(TRIAL_DAYS)
    }

    /**
     * Bir modun geçerli eşikleri (Dart'taki effectiveThresholdsProvider). Her eşik
     * kendi günlerinde geçerli; Plus yoksa yalnızca ilki, tek ve ücretsiz bir
     * tetikleyiciyle, her gün. Kullanıcının asıl seçimi diskte kalır.
     */
    fun thresholds(c: Context, mode: Mode): List<TriggerConfig> {
        val raw = rawThresholds(c, mode)
        if (plusActive(c)) return raw
        val first = raw.first()
        val kind = first.kinds.firstOrNull { it in FREE_KINDS } ?: defaultConfigs.getValue(mode).kinds.first()
        return listOf(first.copy(kinds = listOf(kind), days = ALL_DAYS))
    }

    /**
     * [day] (eşik günü) için geçerli eşik. O gün hiçbir eşiğe ait değilse ilk
     * eşik döner; activeOn(day) false olduğu için izin günü sayılır.
     */
    fun config(c: Context, mode: Mode, day: LocalDate = thresholdDay()): TriggerConfig {
        val list = thresholds(c, mode)
        return list.firstOrNull { it.activeOn(day) } ?: list.first()
    }

    /** Herhangi bir eşikte [kind] seçili mi (işleri kurmak için). */
    fun anyHas(c: Context, mode: Mode, kind: String): Boolean = thresholds(c, mode).any { it.has(kind) }

    /** Eşiklerin herhangi birinde seçili tetikleyiciler, sırasıyla. */
    fun allKinds(c: Context, mode: Mode): List<String> = thresholds(c, mode).flatMap { it.kinds }.distinct()

    /** "triggers.v2" (eşik listesi) ya da eski tek eşikli "triggers.v1". */
    private fun rawThresholds(c: Context, mode: Mode): List<TriggerConfig> {
        val d = defaultConfigs.getValue(mode)
        readJson(c, THRESHOLDS)?.optJSONArray(mode.key)?.let { a ->
            val list = (0 until a.length()).mapNotNull { a.optJSONObject(it)?.let { o -> parse(o, d) } }
            if (list.isNotEmpty()) return list
        }
        val o = readJson(c, TRIGGERS)?.optJSONObject(mode.key) ?: return listOf(d)
        return listOf(parse(o, d))
    }

    private fun parse(o: JSONObject, d: TriggerConfig): TriggerConfig {
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
            delaySeconds = o.optInt("delaySeconds", 0).coerceIn(0, MAX_DELAY_SECONDS),
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
        EsikWidget.update(c)
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
