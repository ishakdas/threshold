package com.ishakdas.threshold

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URI
import java.security.MessageDigest
import com.google.android.gms.auth.blockstore.Blockstore
import com.google.android.gms.auth.blockstore.BlockstoreClient
import com.google.android.gms.auth.blockstore.RetrieveBytesRequest
import com.google.android.gms.auth.blockstore.StoreBytesData
import java.nio.ByteBuffer

/**
 * Plus denemesinin başladığı an, uygulama verisi silinse de unutulmasın diye
 * üç yerde tutulur ve en eskisi geçerlidir:
 *
 * - Uygulamanın kaydı ("flutter.trial_start"): veriler silinince gider.
 * - Android'in kurulum zamanı (firstInstallTime): veriler silinince kalır,
 *   uygulama kaldırılınca gider.
 * - Google Block Store: Google yedeklemesi açıksa uygulama kaldırılıp yeniden
 *   kurulsa da kalır.
 * - Eşik sunucusu ([SERVER]): cihaz kimliğinin özetiyle; yedekleme kapalıyken
 *   uygulama yeniden kurulsa da kalır. Adres boşsa atlanır.
 */
object TrialAnchor {
    private const val PREF = "flutter.trial_start"

    /** Sunucunun adresi (server/worker.js). Boşken sunucuya gidilmez. */
    private const val SERVER = ""

    private fun prefs(c: Context) = c.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    private fun firstInstall(c: Context): Long =
        c.packageManager.getPackageInfo(c.packageName, 0).firstInstallTime

    /** Şimdilik bilinen en eski başlangıç (Block Store'u beklemeden). */
    fun earliest(c: Context): Long {
        val saved = prefs(c).getLong(PREF, Long.MAX_VALUE)
        return minOf(saved, firstInstall(c))
    }

    /**
     * Block Store'daki kayıtla birleştirir, en eskisini uygulamaya ve Block
     * Store'a yazar. [done] en eski anla çağrılır (Block Store yoksa da).
     */
    fun sync(c: Context, done: (Long) -> Unit) {
        val local = earliest(c)
        fun finish(remote: Long?) {
            val start = minOf(local, remote ?: Long.MAX_VALUE)
            prefs(c).edit().putLong(PREF, start).apply()
            if (remote == null || remote > start) store(c, start)
            // Sunucu varsa onunla da eşitle; yanıt gelmezse telefondaki geçerli.
            askServer(c, start) { server ->
                val earliest = minOf(start, server ?: Long.MAX_VALUE)
                if (earliest < start) {
                    prefs(c).edit().putLong(PREF, earliest).apply()
                    store(c, earliest)
                }
                done(earliest)
            }
        }
        try {
            val request = RetrieveBytesRequest.Builder()
                .setKeys(listOf(BlockstoreClient.DEFAULT_BYTES_DATA_KEY))
                .build()
            Blockstore.getClient(c).retrieveBytes(request)
                .addOnSuccessListener { response ->
                    val bytes = response.blockstoreDataMap[BlockstoreClient.DEFAULT_BYTES_DATA_KEY]?.bytes
                    finish(bytes?.takeIf { it.size == 8 }?.let { ByteBuffer.wrap(it).long })
                }
                .addOnFailureListener { finish(null) }
        } catch (e: Exception) {
            // Google Play hizmetleri yok: yalnızca telefondaki kayıtlar.
            finish(null)
        }
    }

    /** Uygulamaya özel cihaz kimliğinin (ANDROID_ID) özeti; ham kimlik gönderilmez. */
    private fun deviceHash(c: Context): String? {
        val androidId = Settings.Secure.getString(c.contentResolver, Settings.Secure.ANDROID_ID) ?: return null
        val digest = MessageDigest.getInstance("SHA-256").digest("esik-trial:$androidId".toByteArray())
        return digest.joinToString("") { "%02x".format(it) }
    }

    /** Sunucudaki başlangıç (ms); adres yoksa ya da ulaşılamazsa null. [done] ana iş parçacığında. */
    private fun askServer(c: Context, local: Long, done: (Long?) -> Unit) {
        val main = Handler(Looper.getMainLooper())
        val id = deviceHash(c)
        if (SERVER.isEmpty() || id == null) {
            main.post { done(null) }
            return
        }
        Thread {
            val start = runCatching {
                val conn = URI.create("$SERVER/v1/trial").toURL().openConnection() as HttpURLConnection
                conn.connectTimeout = 5_000
                conn.readTimeout = 5_000
                conn.requestMethod = "POST"
                conn.doOutput = true
                conn.setRequestProperty("content-type", "application/json")
                conn.outputStream.use {
                    it.write(JSONObject().put("id", id).put("localStart", local).toString().toByteArray())
                }
                val body = conn.inputStream.bufferedReader().use { it.readText() }
                conn.disconnect()
                JSONObject(body).optLong("start", 0L).takeIf { it > 0 }
            }.getOrNull()
            main.post { done(start) }
        }.start()
    }

    private fun store(c: Context, start: Long) {
        try {
            val data = StoreBytesData.Builder()
                .setBytes(ByteBuffer.allocate(8).putLong(start).array())
                .build()
            Blockstore.getClient(c).storeBytes(data)
        } catch (e: Exception) {
            // Kaydedilemezse bir sonraki açılışta yeniden denenir.
        }
    }
}
