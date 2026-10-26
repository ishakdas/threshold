package com.ishakdas.threshold

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/**
 * Bildirim metinlerinin dili, uygulamada seçilenle aynı: seçilmemişse
 * telefonun dili, o da desteklenmiyorsa İngilizce (res/values).
 */
object Lang {
    private val supported = setOf("tr", "en", "es")

    fun locale(c: Context): Locale {
        val chosen = EsikData.language(c)
        if (chosen in supported) return Locale.forLanguageTag(chosen)
        val device = Locale.getDefault()
        return if (device.language in supported) device else Locale.ENGLISH
    }

    fun context(c: Context): Context {
        val config = Configuration(c.resources.configuration)
        config.setLocale(locale(c))
        return c.createConfigurationContext(config)
    }
}
