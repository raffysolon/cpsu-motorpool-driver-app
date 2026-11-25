package com.example.cpsumotorpooldriverapp

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "cpsumotorpooldriverapp/notification_sounds"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "play") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val volume = call.argument<Double>("volume")
                    ?.coerceIn(0.0, 1.0)
                    ?: 0.6
                val sound = call.argument<String>("sound").orEmpty()
                val toneType = when (sound) {
                    "unauthorizedMovement" -> ToneGenerator.TONE_PROP_BEEP2
                    "overdueDepartureWarning" -> ToneGenerator.TONE_PROP_NACK
                    "scheduledDepartureReminder" -> ToneGenerator.TONE_PROP_PROMPT
                    else -> ToneGenerator.TONE_PROP_ACK
                }
                val tone = ToneGenerator(
                    AudioManager.STREAM_NOTIFICATION,
                    (volume * 100).toInt()
                )
                val started = tone.startTone(toneType, 220)
                if (!started) {
                    tone.release()
                    result.error("SOUND_UNAVAILABLE", "Unable to play alert tone.", null)
                    return@setMethodCallHandler
                }

                result.success(null)
                Handler(Looper.getMainLooper()).postDelayed({
                    tone.stopTone()
                    tone.release()
                }, 260)
            }
    }
}
