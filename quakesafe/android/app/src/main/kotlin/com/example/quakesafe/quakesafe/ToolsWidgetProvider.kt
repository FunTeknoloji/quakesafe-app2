package com.example.quakesafe.quakesafe

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ToolsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tools_widget_layout).apply {
                setOnClickPendingIntent(R.id.btn_torch, HomeWidgetProvider.getPendingIntent(context, Uri.parse("quakesafe://tool?type=torch")))
                setOnClickPendingIntent(R.id.btn_sos, HomeWidgetProvider.getPendingIntent(context, Uri.parse("quakesafe://tool?type=sos")))
                setOnClickPendingIntent(R.id.btn_whistle, HomeWidgetProvider.getPendingIntent(context, Uri.parse("quakesafe://tool?type=whistle")))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
