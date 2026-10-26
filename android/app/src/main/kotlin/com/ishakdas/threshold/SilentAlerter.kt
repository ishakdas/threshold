package com.ishakdas.threshold

import android.content.Context
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Telefon sessizdeyken (sessiz, titreşim ya da Rahatsız Etmeyin) bildirimin
 * kendisi ses çıkarmaz. Kullanıcı istediyse Eşik, alarm uygulamaları gibi
 * alarm kanalından titreşir ya da çalar. Rahatsız Etmeyin alarmları da
 * engelliyorsa sistem buna da izin vermez.
 */
object SilentAlerter {
    private const val RING_MS = 6_000L

    private val alarm: AudioAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ALARM)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
        .build()

    fun alertIfSilent(c: Context) {
        val setting = EsikData.silentAlert(c)
        if (setting == "quiet" || !TriggerScheduler.isSilent(c)) return
        vibrate(c)
        if (setting == "ring") ring(c)
    }

    private fun vibrate(c: Context) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            c.getSystemService(VibratorManager::class.java).defaultVibrator
        } else {
            c.getSystemService(Vibrator::class.java)
        }
        if (!vibrator.hasVibrator()) return
        val effect = VibrationEffect.createWaveform(longArrayOf(0, 400, 200, 400, 200, 400), -1)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            vibrator.vibrate(effect, VibrationAttributes.createForUsage(VibrationAttributes.USAGE_ALARM))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(effect, alarm)
        }
    }

    /** Eşik'in sesi, alarm ses düzeyinde, bir kez. */
    private fun ring(c: Context) {
        val ringtone = RingtoneManager.getRingtone(c, EsikNotifications.chimeUri(c)) ?: return
        ringtone.audioAttributes = alarm
        ringtone.play()
        Handler(Looper.getMainLooper()).postDelayed({ ringtone.stop() }, RING_MS)
    }
}
