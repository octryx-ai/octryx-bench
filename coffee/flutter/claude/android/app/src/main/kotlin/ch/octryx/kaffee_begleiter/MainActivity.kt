package ch.octryx.kaffee_begleiter

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Hosts Flutter and offers the system share sheet for the JSON export.
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "shareFile") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val fileName = call.argument<String>("fileName")
                val content = call.argument<String>("content")
                if (fileName == null || content == null) {
                    result.error("bad_args", "fileName and content are required", null)
                    return@setMethodCallHandler
                }
                try {
                    shareFile(fileName, content)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("share_failed", e.message, null)
                }
            }
    }

    private fun shareFile(fileName: String, content: String) {
        val dir = File(cacheDir, "shared").apply { mkdirs() }
        val file = File(dir, fileName)
        file.writeText(content, Charsets.UTF_8)
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "application/json"
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_SUBJECT, fileName)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(send, fileName))
    }

    companion object {
        private const val SHARE_CHANNEL = "ch.octryx.kaffee_begleiter/share"
    }
}
