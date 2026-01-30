package com.fetch.fetch

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val SCANNER_CHANNEL = "com.fetch.app/scanner"
    private val PROGRESS_CHANNEL = "com.fetch.app/scanner/progress"
    private val FILES_CHANNEL = "com.fetch.app/scanner/files"
    private val STORAGE_CHANNEL = "com.fetch.app/storage"
    private lateinit var scannerPlugin: ScannerPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize scanner plugin
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCANNER_CHANNEL)
        scannerPlugin = ScannerPlugin(this, methodChannel)
        
        methodChannel.setMethodCallHandler { call, result ->
            scannerPlugin.handleMethodCall(call, result)
        }
        
        // Set up event channels for progress and file updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PROGRESS_CHANNEL)
            .setStreamHandler(scannerPlugin.getProgressStreamHandler())
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, FILES_CHANNEL)
            .setStreamHandler(scannerPlugin.getFilesStreamHandler())
        
        // Setup storage detection channel
        val storageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
        storageChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "detectExternalSD" -> {
                    val sdCardInfo = StorageDetector.detectExternalSD(this)
                    result.success(sdCardInfo)
                }
                "isSDCardMounted" -> {
                    val isMounted = StorageDetector.isExternalSDMounted()
                    result.success(isMounted)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::scannerPlugin.isInitialized) {
            scannerPlugin.cleanup()
        }
    }
}
