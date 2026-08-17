package com.earkania.rehabtrack

import android.app.Activity
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.StatFs
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import android.provider.Settings
import android.text.format.DateUtils
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.earkania.rehabtrack/notifications"
    private val BACKUP_CHANNEL = "com.earkania.rehabtrack/backup"
    private val CREATE_DOCUMENT_REQUEST = 2001
    private val OPEN_DOCUMENT_REQUEST = 2002
    private val OPEN_DOCUMENTS_REQUEST = 2003
    private val PICK_RINGTONE_REQUEST = 2004

    private var pendingCreateResult: MethodChannel.Result? = null
    private var pendingCreateBytes: ByteArray? = null
    private var pendingOpenResult: MethodChannel.Result? = null
    private var pendingOpenDocsResult: MethodChannel.Result? = null
    private var pendingRingtoneResult: MethodChannel.Result? = null

    /// Looping alarm player for the Alarm-style presentation and its settings
    /// preview. Playback uses USAGE_ALARM so it follows the same alarm volume
    /// and Do Not Disturb policy as the notification channel's own sound.
    private var alarmPlayer: Ringtone? = null
    private var previewPlayer: Ringtone? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val stopPreviewRunnable = Runnable {
        previewPlayer?.stop()
        previewPlayer = null
    }

    /// Max preview length before the sound stops itself (~12 s).
    private val PREVIEW_DURATION_MS = 12_000L

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
                "canUseFullScreenIntent" -> {
                    result.success(canUseFullScreenIntent())
                }
                "getAndroidSdkInt" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                "openFullScreenIntentSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        openFullScreenIntentSettings(result)
                    } else {
                        result.success(false)
                    }
                }
                "getTimeZone" -> {
                    result.success(TimeZone.getDefault().id)
                }
                "getDefaultAlarmSoundUri" -> {
                    result.success(getDefaultAlarmSoundUri())
                }
                "getRingtoneTitle" -> {
                    result.success(ringtoneTitle(call.argument<String>("uri")))
                }
                "pickAlarmSound" -> {
                    pickAlarmSound(call, result)
                }
                "startAlarmSound" -> {
                    playAlarmSound(call, result, isPreview = false)
                }
                "stopAlarmSound" -> {
                    stopAlarmSound()
                    result.success(true)
                }
                "startAlarmSoundPreview" -> {
                    playAlarmSound(call, result, isPreview = true)
                }
                "stopAlarmSoundPreview" -> {
                    stopAlarmSoundPreview()
                    result.success(true)
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
                "openDocuments" -> {
                    openDocuments(result)
                }
                "copyDocument" -> {
                    copyDocument(call, result)
                }
                "freeBytes" -> {
                    freeBytes(call, result)
                }
                "queryDocument" -> {
                    queryDocument(call, result)
                }
                "deleteDocument" -> {
                    deleteDocument(call, result)
                }
                "shareDocument" -> {
                    shareDocument(call, result)
                }
                "persistableUriPermission" -> {
                    persistableUriPermission(call, result)
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

    /** Launches the SAF document opener with multi-select for "Import Existing Backups", persisting
     * read access for every chosen document so they can be listed later without re-picking. */
    private fun openDocuments(result: MethodChannel.Result) {
        if (pendingOpenDocsResult != null) {
            result.error("OPERATION_IN_PROGRESS", "a document open is already in progress", null)
            return
        }
        pendingOpenDocsResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/octet-stream", "application/zip"))
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        }
        try {
            startActivityForResult(intent, OPEN_DOCUMENTS_REQUEST)
        } catch (e: Exception) {
            pendingOpenDocsResult = null
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
            OPEN_DOCUMENTS_REQUEST -> handleOpenDocumentsResult(resultCode, data)
            PICK_RINGTONE_REQUEST -> handlePickRingtoneResult(resultCode, data)
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
            val size = queryDocumentSize(uri)
            val lastModified = queryLastModified(uri)
            // Ask for persistable access so RehabTrack can list, validate,
            // restore, share and delete this backup later without re-picking.
            val persisted = tryTakePersistablePermission(uri)
            val payload = JSONObject()
                .put("uri", uri.toString())
                .put("displayName", displayName ?: JSONObject.NULL)
                .put("size", if (size != null) size else JSONObject.NULL)
                .put("lastModified", if (lastModified != null) lastModified else JSONObject.NULL)
                .put("persisted", persisted)
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

    /** Resolves the document provider's size in bytes for [uri], or null. */
    private fun queryDocumentSize(uri: android.net.Uri): Long? {
        return try {
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (sizeIndex >= 0 && cursor.moveToFirst() && !cursor.isNull(sizeIndex)) {
                    cursor.getLong(sizeIndex)
                } else null
            }
        } catch (_: Exception) {
            null
        }
    }

    /** Resolves the document provider's last-modified epoch millis for [uri], or null. */
    private fun queryLastModified(uri: android.net.Uri): Long? {
        return try {
            contentResolver.query(
                uri,
                arrayOf(DocumentsContract.Document.COLUMN_LAST_MODIFIED),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getLong(0) else null
            }
        } catch (_: Exception) {
            null
        }
    }

    /** Requests persistable access to [uri]; true when the grant was persisted. */
    private fun tryTakePersistablePermission(
        uri: android.net.Uri,
        flags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
    ): Boolean {
        return try {
            contentResolver.takePersistableUriPermission(uri, flags)
            true
        } catch (_: Exception) {
            false
        }
    }

    /** Returns metadata for a previously created backup document, or error when unavailable. */
    private fun queryDocument(call: MethodCall, result: MethodChannel.Result) {
        val contentUri = call.argument<String>("contentUri")
        if (contentUri == null) {
            result.error("INVALID_ARGUMENTS", "contentUri is required", null)
            return
        }
        try {
            val uri = Uri.parse(contentUri)
            val displayName = queryDisplayName(uri)
            val size = queryDocumentSize(uri)
            val lastModified = queryLastModified(uri)
            /// Probe with a live open: some providers return a synthetic query row
            /// (e.g. for `raw:` lookup by path) even when the underlying file no
            /// longer exists, so a cursor row alone is not proof of access.
            /// Opening (and immediately closing) the input stream verifies the
            /// document actually exists and is readable without reading content.
            val accessible = try {
                contentResolver.openInputStream(uri)?.use { true } ?: false
            } catch (_: Exception) {
                false
            }
            val payload = JSONObject()
                .put("displayName", displayName ?: JSONObject.NULL)
                .put("size", if (size != null) size else JSONObject.NULL)
                .put("lastModified", if (lastModified != null) lastModified else JSONObject.NULL)
                .put("accessible", accessible)
            result.success(payload.toString())
        } catch (e: Exception) {
            result.error("QUERY_ERROR", e.message, null)
        }
    }

    /** Deletes the given backup document via DocumentsContract. */
    private fun deleteDocument(call: MethodCall, result: MethodChannel.Result) {
        val contentUri = call.argument<String>("contentUri")
        if (contentUri == null) {
            result.error("INVALID_ARGUMENTS", "contentUri is required", null)
            return
        }
        try {
            val uri = Uri.parse(contentUri)
            val deleted = DocumentsContract.deleteDocument(contentResolver, uri)
            result.success(deleted)
        } catch (e: Exception) {
            result.error("DELETE_ERROR", e.message, null)
        }
    }

    /** Shares the given backup document through the system share sheet. */
    private fun shareDocument(call: MethodCall, result: MethodChannel.Result) {
        val contentUri = call.argument<String>("contentUri")
        val displayName = call.argument<String>("displayName")
        if (contentUri == null) {
            result.error("INVALID_ARGUMENTS", "contentUri is required", null)
            return
        }
        try {
            val uri = Uri.parse(contentUri)
            val share = Intent(Intent.ACTION_SEND).apply {
                type = "application/octet-stream"
                putExtra(Intent.EXTRA_STREAM, uri)
                if (!displayName.isNullOrEmpty()) putExtra(Intent.EXTRA_TITLE, displayName)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(share, null))
            result.success(true)
        } catch (e: Exception) {
            result.error("SHARE_ERROR", e.message, null)
        }
    }

    /** Returns whether the app holds a persisted read/write grant for [contentUri]. */
    private fun persistableUriPermission(call: MethodCall, result: MethodChannel.Result) {
        val contentUri = call.argument<String>("contentUri")
        if (contentUri == null) {
            result.error("INVALID_ARGUMENTS", "contentUri is required", null)
            return
        }
        try {
            val uri = Uri.parse(contentUri)
            val grants = contentResolver.persistedUriPermissions
            val persisted = grants.any { it.uri == uri && it.isReadPermission }
            result.success(persisted)
        } catch (e: Exception) {
            result.error("PERMISSION_QUERY_ERROR", e.message, null)
        }
    }

    /** Reports the free bytes on the filesystem hosting [path]. */
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

    /** Collects every picked document, persists read access where possible, and returns a JSON array
     * of `{ "uri": ..., "displayName": ... }` records. An empty/nil payload means the user dismissed
     * the picker. */
    private fun handleOpenDocumentsResult(resultCode: Int, data: Intent?) {
        val result = pendingOpenDocsResult ?: return
        pendingOpenDocsResult = null
        if (resultCode != Activity.RESULT_OK || data == null ||
            (data.data == null && data.clipData == null)) {
            // User dismissed the picker.
            result.success(null)
            return
        }
        try {
            val uris = mutableListOf<android.net.Uri>()
            val clipData = data.clipData
            if (clipData != null) {
                for (i in 0 until clipData.itemCount) {
                    clipData.getItemAt(i).uri?.let { uris.add(it) }
                }
            }
            data.data?.let { if (uris.isEmpty()) uris.add(it) }
            if (uris.isEmpty()) {
                result.success(null)
                return
            }
            val entries = JSONArray()
            for (uri in uris) {
                // Ask for persistable read access so the imported document can be
                // listed, validated, restored and shared later without re-picking.
                tryTakePersistablePermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                val entry = JSONObject()
                    .put("uri", uri.toString())
                    .put("displayName", queryDisplayName(uri) ?: JSONObject.NULL)
                entries.put(entry)
            }
            result.success(entries.toString())
        } catch (e: Exception) {
            result.error("OPEN_DOCUMENT_ERROR", e.message, null)
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

    /**
     * Whether the app may present full-screen alarms on this device.
     *
     * Full-screen intents are only supported on API 34+ and require either the
     * USE_FULL_SCREEN_INTENT permission or a granted exemption for alarm apps.
     * Below API 34 (or when neither applies) Android degrades the presentation
     * to a heads-up notification, which the Alarm-style fallback handles.
     */
    private fun canUseFullScreenIntent(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            notificationManager.canUseFullScreenIntent()
        } else {
            false
        }
    }

    /** Opens the system "Full screen content" settings page for this app. */
    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private fun openFullScreenIntentSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                data = android.net.Uri.parse("package:$packageName")
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_FULL_SCREEN_SETTINGS_ERROR", e.message, null)
        }
    }

    /** Returns the device's default alarm sound URI (falls back to ringtone/notification). */
    private fun getDefaultAlarmSoundUri(): String? {
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (alarmUri != null) return alarmUri.toString()
        val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (ringtoneUri != null) return ringtoneUri.toString()
        return null
    }

    /** Resolves the human-readable title for a ringtone/alarm URI, or null. */
    private fun ringtoneTitle(uri: String?): String? {
        if (uri.isNullOrEmpty()) return null
        return try {
            RingtoneManager.getRingtone(applicationContext, Uri.parse(uri))
                ?.getTitle(applicationContext)
        } catch (_: Exception) {
            null
        }
    }

    /** Launches the system alarm-sound picker and resolves the chosen URI + title. */
    private fun pickAlarmSound(call: MethodCall, result: MethodChannel.Result) {
        if (pendingRingtoneResult != null) {
            result.error("OPERATION_IN_PROGRESS", "a sound picker is already open", null)
            return
        }
        pendingRingtoneResult = result
        val currentUri = call.argument<String>("currentUri")
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Alarm sound")
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            if (!currentUri.isNullOrEmpty()) {
                putExtra(RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI, Uri.parse(currentUri))
            }
        }
        try {
            startActivityForResult(intent, PICK_RINGTONE_REQUEST)
        } catch (e: Exception) {
            pendingRingtoneResult = null
            result.error("RINGTONE_PICKER_ERROR", e.message, null)
        }
    }

    private fun handlePickRingtoneResult(resultCode: Int, data: Intent?) {
        val result = pendingRingtoneResult ?: return
        pendingRingtoneResult = null
        if (resultCode != Activity.RESULT_OK || data == null) {
            // User dismissed the picker (or chose a null/silent sound).
            result.success(null)
            return
        }
        val pickedUri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        } ?: data.data
        if (pickedUri == null) {
            result.success(null)
            return
        }
        val title = ringtoneTitle(pickedUri.toString())
        val payload = JSONObject()
            .put("uri", pickedUri.toString())
            .put("title", title ?: JSONObject.NULL)
        result.success(payload.toString())
    }

    /** Plays [uri] (or the default alarm sound when null) as an alarm loop. */
    private fun playAlarmSound(call: MethodCall, result: MethodChannel.Result, isPreview: Boolean) {
        val uri = call.argument<String>("uri")
        val source = if (uri.isNullOrEmpty()) getDefaultAlarmSoundUri() else uri
        if (source == null) {
            result.error("NO_ALARM_SOUND", "no alarm sound available", null)
            return
        }
        try {
            val ringtone = RingtoneManager.getRingtone(applicationContext, Uri.parse(source))
                ?: throw IllegalStateException("could not load ringtone")
            ringtone.audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            ringtone.isLooping = true
            if (isPreview) {
                stopAlarmSoundPreview()
                previewPlayer = ringtone
                ringtone.play()
                mainHandler.removeCallbacks(stopPreviewRunnable)
                mainHandler.postDelayed(stopPreviewRunnable, PREVIEW_DURATION_MS)
            } else {
                stopAlarmSoundPreview()
                stopAlarmSound()
                alarmPlayer = ringtone
                ringtone.play()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("PLAY_ERROR", e.message, null)
        }
    }

    /** Stops the looping alarm player immediately. */
    private fun stopAlarmSound() {
        alarmPlayer?.stop()
        alarmPlayer = null
    }

    /** Stops a playing preview immediately and cancels its auto-stop timer. */
    private fun stopAlarmSoundPreview() {
        mainHandler.removeCallbacks(stopPreviewRunnable)
        previewPlayer?.stop()
        previewPlayer = null
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
