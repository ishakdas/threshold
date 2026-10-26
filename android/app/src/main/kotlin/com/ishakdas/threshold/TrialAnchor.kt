package com.ishakdas.threshold

import android.content.Context
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
 */
object TrialAnchor {
    private const val PREF = "flutter.trial_start"

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
            done(start)
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
