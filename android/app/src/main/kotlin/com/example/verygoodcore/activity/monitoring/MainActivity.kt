package com.fullstackgenie.activity_monitoring

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app_usage_channel"
    private val TAG = "MainActivityDebug"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "✅ MainActivity started!")

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "🔹 Received method call: ${call.method}")

            if (call.method == "getUsageStats") {
                if (!hasUsageStatsPermission()) {
                    Log.e(TAG, "🚨 Permission not granted. Redirecting user to settings.")
                    openUsageAccessSettings()
                    result.error("PERMISSION_DENIED", "Usage access permission not granted.", null)
                    return@setMethodCallHandler
                }

                val recentApps = getRecentApps()
                Log.d(TAG, "📊 Returning recent apps: $recentApps")
                result.success(recentApps)
            } else {
                Log.d(TAG, "⚠️ Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = appOps.checkOpNoThrow(
            "android:get_usage_stats",
            android.os.Process.myUid(),
            packageName
        )
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun getRecentApps(): List<Map<String, Any>> {
        Log.d(TAG, "🔍 Fetching recent apps...")

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - TimeUnit.DAYS.toMillis(1) // Last 24 hours

        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        val recentApps = stats.sortedByDescending { it.lastTimeUsed }
            .take(10)
            .map {
                mapOf("packageName" to it.packageName, "totalTimeInForeground" to it.totalTimeInForeground)
            }

        Log.d(TAG, "✅ Recent apps retrieved: $recentApps")
        return recentApps
    }
}
