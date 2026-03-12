package com.example.quakesafe.quakesafe

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class ToolsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tools_widget_layout).apply {
                setOnClickPendingIntent(R.id.btn_torch, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("quakesafe://tool?type=torch")))
                setOnClickPendingIntent(R.id.btn_sos, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("quakesafe://tool?type=sos")))
                setOnClickPendingIntent(R.id.btn_whistle, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("quakesafe://tool?type=whistle")))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
