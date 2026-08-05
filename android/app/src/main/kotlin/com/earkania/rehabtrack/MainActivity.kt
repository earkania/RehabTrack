package com.earkania.rehabtrack

import android.app.Activity
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.earkania.rehabtrack/notifications"
    private val BACKUP_CHANNEL = "com.earkania.rehabtrack/backup"
    private val CREATE_DOCUMENT_REQUEST = 2001

    private var pendingCreateResult: MethodChannel.Result? = null
    private var pendingCreateBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    openNotificationSettings(result)
                }
                "openAlarmSettings" -> {
                    openAlarmSettings(result)
                }
                "hasExactAlarmPermission" -> {
                    result.success(hasExactAlarmPermission())
                }
                "getTimeZone" -> {
                    result.success(TimeZone.getDefault().id)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKUP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createDocument" -> {
                    val fileName = call.argument<String>("fileName") ?: "RehabTrack-Backup.rtb"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("INVALID_ARGUMENTS", "bytes are required", null)
                    } else {
                        createDocument(fileName, bytes, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Launches the Storage Access Framework document creator and writes [bytes] to the chosen destination. */
    private fun createDocument(fileName: String, bytes: ByteArray, result: MethodChannel.Result) {
        if (pendingCreateResult != null) {
            result.error("OPERATION_IN_PROGRESS", "a document creation is already in progress", null)
            return
        }
        pendingCreateResult = result
        pendingCreateBytes = bytes
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        try {
            startActivityForResult(intent, CREATE_DOCUMENT_REQUEST)
        } catch (e: Exception) {
            pendingCreateResult = null
            pendingCreateBytes = null
            result.error("CREATE_DOCUMENT_ERROR", e.message, null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CREATE_DOCUMENT_REQUEST) return
        val result = pendingCreateResult ?: return
        val bytes = pendingCreateBytes
        pendingCreateResult = null
        pendingCreateBytes = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            // User dismissed the picker.
            result.success(null)
            return
        }
        val uri = data.data!!
        try {
            contentResolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes ?: ByteArray(0))
                stream.flush()
            }
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("WRITE_ERROR", e.message, null)
        }
    }

    private fun openNotificationSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_SETTINGS_ERROR", e.message, null)
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun openAlarmSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = android.net.Uri.parse("package:$packageName")
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_ALARM_SETTINGS_ERROR", e.message, null)
        }
    }

    private fun hasExactAlarmPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }
}
