package com.earkania.rehabtrack

import android.app.Activity
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.OpenableColumns
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.earkania.rehabtrack/notifications"
    private val BACKUP_CHANNEL = "com.earkania.rehabtrack/backup"
    private val CREATE_DOCUMENT_REQUEST = 2001
    private val OPEN_DOCUMENT_REQUEST = 2002

    private var pendingCreateResult: MethodChannel.Result? = null
    private var pendingCreateBytes: ByteArray? = null
    private var pendingOpenResult: MethodChannel.Result? = null

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
                "openImageWithPhotos" -> {
                    openImageWithPhotos(call, result)
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
                "openDocument" -> {
                    openDocument(result)
                }
                "copyDocument" -> {
                    copyDocument(call, result)
                }
                "freeBytes" -> {
                    freeBytes(call, result)
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

    /** Launches the Storage Access Framework document opener (backup selection). */
    private fun openDocument(result: MethodChannel.Result) {
        if (pendingOpenResult != null) {
            result.error("OPERATION_IN_PROGRESS", "a document open is already in progress", null)
            return
        }
        pendingOpenResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/octet-stream", "application/zip"))
        }
        try {
            startActivityForResult(intent, OPEN_DOCUMENT_REQUEST)
        } catch (e: Exception) {
            pendingOpenResult = null
            result.error("OPEN_DOCUMENT_ERROR", e.message, null)
        }
    }

    /** Copies the selected [contentUri] document into [destinationPath] via the content resolver. */
    private fun copyDocument(call: MethodCall, result: MethodChannel.Result) {
        val contentUri = call.argument<String>("contentUri")
        val destinationPath = call.argument<String>("destinationPath")
        if (contentUri == null || destinationPath == null) {
            result.error("INVALID_ARGUMENTS", "contentUri and destinationPath are required", null)
            return
        }
        try {
            val input = contentResolver.openInputStream(android.net.Uri.parse(contentUri))
                ?: throw IllegalStateException("openInputStream returned null")
            input.use { source ->
                java.io.File(destinationPath).apply {
                    parentFile?.mkdirs()
                }.outputStream().use { target ->
                    source.copyTo(target)
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("COPY_ERROR", e.message, null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            CREATE_DOCUMENT_REQUEST -> handleCreateDocumentResult(resultCode, data)
            OPEN_DOCUMENT_REQUEST -> handleOpenDocumentResult(resultCode, data)
        }
    }

    private fun handleCreateDocumentResult(resultCode: Int, data: Intent?) {
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
            val displayName = queryDisplayName(uri)
            val payload = JSONObject()
                .put("uri", uri.toString())
                .put("displayName", displayName ?: JSONObject.NULL)
            result.success(payload.toString())
        } catch (e: Exception) {
            result.error("WRITE_ERROR", e.message, null)
        }
    }

    /** Resolves the document provider's display name for [uri], or null. */
    private fun queryDisplayName(uri: android.net.Uri): String? {
        return try {
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0 && cursor.moveToFirst()) cursor.getString(nameIndex) else null
            }
        } catch (_: Exception) {
            null
        }
    }

    /** Reports the number of free bytes on the filesystem hosting [path]. */
    private fun freeBytes(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null || path.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "path is required", null)
            return
        }
        try {
            val file = File(path)
            val root = if (file.isDirectory) file else file.parentFile
                ?: Environment.getDataDirectory()
            val stat = StatFs(root.absolutePath)
            val bytes = stat.blockSizeLong * stat.availableBlocksLong
            result.success(bytes)
        } catch (e: Exception) {
            result.error("FREE_BYTES_ERROR", e.message, null)
        }
    }

    private fun handleOpenDocumentResult(resultCode: Int, data: Intent?) {
        val result = pendingOpenResult ?: return
        pendingOpenResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            // User dismissed the picker.
            result.success(null)
            return
        }
        result.success(data.data!!.toString())
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

    /** Opens an image file directly in the Google Photos app, falling back to a generic viewer. */
    private fun openImageWithPhotos(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path") ?: run {
            result.error("INVALID_ARGUMENTS", "path is required", null)
            return
        }
        val file = File(path)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "file does not exist", null)
            return
        }
        try {
            val authority = "${applicationContext.packageName}.fileProvider.com.crazecoder.openfile"
            val uri = FileProvider.getUriForFile(applicationContext, authority, file)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "image/*")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                setPackage("com.google.android.apps.photos")
            }
            val photosResolved = intent.resolveActivity(packageManager) != null
            if (photosResolved) {
                startActivity(intent)
            } else {
                val fallback = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "image/*")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivity(Intent.createChooser(fallback, null))
            }
            result.success(photosResolved)
        } catch (e: Exception) {
            result.error("OPEN_IMAGE_ERROR", e.message, null)
        }
    }
}
