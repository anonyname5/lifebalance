package com.lifebalance.lifebalance

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.NumberFormat
import java.util.Locale

class LifeBalanceWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget enabled
    }

    override fun onDisabled(context: Context) {
        // Widget disabled
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            // Flutter stores data with "flutter." prefix
            val widgetDataString = prefs.getString("flutter.widget_data", null)

            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            if (widgetDataString != null && widgetDataString.isNotEmpty()) {
                try {
                    val widgetData = JSONObject(widgetDataString)
                    
                    // Water intake
                    val waterGlasses = widgetData.optInt("waterGlasses", 0)
                    val waterGoal = widgetData.optInt("waterGoal", 8)
                    
                    views.setTextViewText(R.id.widget_water_glasses, waterGlasses.toString())
                    views.setTextViewText(R.id.widget_water_goal, "/$waterGoal")
                    views.setProgressBar(R.id.widget_water_progress, waterGoal, waterGlasses, false)
                    
                    // Today's spending
                    val todaySpending = widgetData.optDouble("todaySpending", 0.0)
                    val currencySymbol = widgetData.optString("currencySymbol", "RM")
                    val spendingText = "$currencySymbol${String.format(Locale.getDefault(), "%.2f", todaySpending)}"
                    views.setTextViewText(R.id.widget_spending, spendingText)
                    
                    // Meal count
                    val mealCount = widgetData.optInt("mealCount", 0)
                    views.setTextViewText(R.id.widget_meal_count, mealCount.toString())
                    
                    // Month spending
                    val monthSpending = widgetData.optDouble("monthSpending", 0.0)
                    val monthText = "$currencySymbol${String.format(Locale.getDefault(), "%.2f", monthSpending)}"
                    views.setTextViewText(R.id.widget_month_spending, monthText)
                    
                } catch (e: Exception) {
                    // If JSON parsing fails, use default values
                    setDefaultValues(views)
                }
            } else {
                // Default values when no data available
                setDefaultValues(views)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            // Log error but don't crash
            android.util.Log.e("LifeBalanceWidget", "Error updating widget", e)
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_layout)
                setDefaultValues(views)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e2: Exception) {
                android.util.Log.e("LifeBalanceWidget", "Error setting default values", e2)
            }
        }
    }

    private fun setDefaultValues(views: RemoteViews) {
        try {
            views.setTextViewText(R.id.widget_water_glasses, "0")
            views.setTextViewText(R.id.widget_water_goal, "/8")
            views.setProgressBar(R.id.widget_water_progress, 8, 0, false)
            views.setTextViewText(R.id.widget_spending, "RM0.00")
            views.setTextViewText(R.id.widget_meal_count, "0")
            views.setTextViewText(R.id.widget_month_spending, "RM0.00")
        } catch (e: Exception) {
            android.util.Log.e("LifeBalanceWidget", "Error setting default values", e)
        }
    }
}
