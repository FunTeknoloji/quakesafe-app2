package com.example.quakesafe.quakesafe

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class StatusWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.status_widget_layout).apply {
                val pendingIntentSafe = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("quakesafe://status?type=safe"))
                setOnClickPendingIntent(R.id.btn_safe, pendingIntentSafe)

                val pendingIntentHelp = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("quakesafe://status?type=help"))
                setOnClickPendingIntent(R.id.btn_help, pendingIntentHelp)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
