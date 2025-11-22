package com.devlark.cogninote

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "pdf_saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "saveFileToDownloads") {

                    val fileName = call.argument<String>("fileName")
                    val byteList = call.argument<ByteArray>("bytes")
                        ?: call.argument<ByteArray>("bytes")
                        ?: call.argument<ByteArray>("bytes")

                    if (fileName == null || byteList == null) {
                        result.error("INVALID_ARGS", "Missing filename/bytes", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = savePdfToDownloads(fileName, byteList)
                        result.success(uri)
                    } catch (e: Exception) {
                        result.error("ERROR_SAVING", e.toString(), null)
                    }

                } else {
                    result.notImplemented()
                }
            }
    }

    private fun savePdfToDownloads(fileName: String, bytes: ByteArray): String {
    val resolver = applicationContext.contentResolver

    val values = ContentValues().apply {
        put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
        put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/CognitiveJournal/")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
    }

    val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
        ?: throw Exception("MediaStore returned NULL uri (Huawei issue)")

    try {
        resolver.openOutputStream(uri)?.use { out ->
            out.write(bytes)
            out.flush()
        } ?: throw Exception("Cannot open output stream for uri: $uri")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        return uri.toString()

    } catch (e: Exception) {
        resolver.delete(uri, null, null)
        throw e
    }
}
}
