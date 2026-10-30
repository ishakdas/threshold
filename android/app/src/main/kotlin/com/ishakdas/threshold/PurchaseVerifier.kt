package com.ishakdas.threshold

import android.util.Base64
import org.json.JSONObject
import java.security.KeyFactory
import java.security.Signature
import java.security.spec.X509EncodedKeySpec

/**
 * Google Play satın alma kaydının imzasını Play Console'daki lisans anahtarıyla
 * doğrular. Cihazda taklit edilen "satın alındı" yanıtı bu imzayı taşıyamaz.
 */
object PurchaseVerifier {
    // Play Console → Para kazanma kurulumu → Lisanslama. Ortak anahtar; gizli değil.
    private const val LICENSE_KEY =
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl2t6aJbLqv4oH41bT+cRx7wqHQIk2D1YKule3Gnz9qq0gEwRQHeGdTUx996YBF8FYsMN1jNcfk9A4NSGVS9zqhBh8kTbLbrMfVi+AgZRZQp7P+2xLjWFBtDy6VpatwC/I7j8rKYEuDM5O4qjc1DRwnAh+fsPjp5RbBY4vjWVlhjHTBRTnl4o5GSU6w2DQ5FKTvE0lU9NIs/qqY2K/kgj+hFggCdMj6RVRMpsgyc/pfgzG4MzxK3juKQts4+RNgW3DFcw7dsaS7R1zfn6l5+625N01+0Bq5jWOecX6aX3Xu2OA3rrM4D4ybRfUlz1pFEqYU/LB7Nvlmy1LVbH4YsRAwIDAQAB"

    /** [json] Play'in gönderdiği ham kayıt, [signature] onun Base64 imzası. */
    fun verify(json: String?, signature: String?, packageName: String, productId: String): Boolean {
        if (json.isNullOrEmpty() || signature.isNullOrEmpty()) return false
        return runCatching {
            val key = KeyFactory.getInstance("RSA")
                .generatePublic(X509EncodedKeySpec(Base64.decode(LICENSE_KEY, Base64.DEFAULT)))
            val ok = Signature.getInstance("SHA1withRSA").run {
                initVerify(key)
                update(json.toByteArray(Charsets.UTF_8))
                verify(Base64.decode(signature, Base64.DEFAULT))
            }
            if (!ok) return@runCatching false
            val data = JSONObject(json)
            val products = data.optJSONArray("productIds")
            val hasProduct = data.optString("productId") == productId ||
                (products != null && (0 until products.length()).any { products.optString(it) == productId })
            data.optString("packageName") == packageName && hasProduct
        }.getOrDefault(false)
    }
}
