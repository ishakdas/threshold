package com.ishakdas.threshold

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Ana ekran widget'ı: bugünkü akşam ve sabah kontrolünün yapılıp yapılmadığı
 * ve saati. Dokununca kontrol ekranı açılır. Kayıt değişince (Dart'tan
 * updateWidget, bildirimden "Hepsi tamam") ve yarım saatte bir yenilenir.
 */
class EsikWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        render(context, manager, ids)
    }

    companion object {
        fun update(c: Context) {
            val manager = AppWidgetManager.getInstance(c) ?: return
            val ids = manager.getAppWidgetIds(ComponentName(c, EsikWidget::class.java))
            if (ids.isNotEmpty()) render(c, manager, ids)
        }

        /** Android'in "ana ekrana ekle" penceresi. Açılabildiyse true. */
        fun requestPin(c: Context): Boolean {
            val manager = AppWidgetManager.getInstance(c) ?: return false
            if (!manager.isRequestPinAppWidgetSupported) return false
            return manager.requestPinAppWidget(ComponentName(c, EsikWidget::class.java), null, null)
        }

        private fun render(c: Context, manager: AppWidgetManager, ids: IntArray) {
            val res = Lang.context(c).resources
            val day = EsikData.thresholdDay()
            val views = RemoteViews(c.packageName, R.layout.esik_widget)
            fun line(mode: Mode): String {
                val label = res.getString(if (mode == Mode.EVENING) R.string.mode_evening else R.string.mode_morning)
                val at = EsikData.completedAt(c, day, mode)
                val state = at?.let { "$it ✓" } ?: res.getString(R.string.widget_not_done)
                return "$label · $state"
            }
            views.setTextViewText(R.id.widget_evening, line(Mode.EVENING))
            views.setTextViewText(R.id.widget_morning, line(Mode.MORNING))
            val open = PendingIntent.getActivity(
                c,
                71,
                Intent(c, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    putExtra(EsikNotifications.EXTRA_ROUTE, "/kontrol")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                },
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            views.setOnClickPendingIntent(R.id.widget_root, open)
            manager.updateAppWidget(ids, views)
        }
    }
}
