package com.lifebalance.lifebalance

import android.content.Context
import android.content.Intent
import android.appwidget.AppWidgetManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lifebalance.widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val data = call.arguments as? Map<*, *>
                    if (data != null) {
                        updateWidget(data)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Data is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateWidget(data: Map<*, *>) {
        try {
            val intent = Intent(this, LifeBalanceWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(this).getAppWidgetIds(
                android.content.ComponentName(this, LifeBalanceWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                sendBroadcast(intent)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error updating widget", e)
        }
    }
}
