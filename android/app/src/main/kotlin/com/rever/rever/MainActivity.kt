package com.rever.rever

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.rever.rever/app_icon"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAppIcon") {
                val variant = call.argument<String>("variant") ?: ""
                setAppIcon(variant)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setAppIcon(variant: String) {
        val pm = packageManager
        val morning = ComponentName(this, "$packageName.MainActivityMorning")
        val evening = ComponentName(this, "$packageName.MainActivityEvening")

        val enableMorning = when (variant) {
            "morning" -> PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else -> PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }
        val enableEvening = when (variant) {
            "evening" -> PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else -> PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }

        pm.setComponentEnabledSetting(morning, enableMorning, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(evening, enableEvening, PackageManager.DONT_KILL_APP)
    }
}
