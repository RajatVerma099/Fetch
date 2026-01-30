package com.fetch.fetch

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.util.Log
import java.io.File
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import android.media.MediaScannerConnection
import kotlin.math.min

/**
 * Native Android plugin for comprehensive storage scanning
 * Performs low-level filesystem traversal and batches results by file category
 */
class ScannerPlugin(
    private val context: Context,
    private val methodChannel: MethodChannel
) {
    private val TAG = "ScannerPlugin"
    
    // Lifecycle states as requested
    private enum class ScanLifecycle {
        IDLE, INITIALIZING, SCANNING, FINALIZING, COMPLETED, ERROR
    }
    
    private var currentLifecycle = ScanLifecycle.IDLE
    
    private var scanJob: Job? = null
    private var scanScope: CoroutineScope? = null
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    
    private val isPaused = AtomicBoolean(false)
    private val isCancelled = AtomicBoolean(false)

    // Ensure completion is emitted exactly once per scan
    private val completionEmitted = AtomicBoolean(false)
    
    private val filesScanned = AtomicInteger(0)
    private val bytesScanned = java.util.concurrent.atomic.AtomicLong(0L)
    private var totalStorageBytes = 0L
    
    private val imagesFound = AtomicInteger(0)
    private val videosFound = AtomicInteger(0)
    private val documentsFound = AtomicInteger(0)
    private val audioFound = AtomicInteger(0)
    private val archivesFound = AtomicInteger(0)
    private val applicationsFound = AtomicInteger(0)
    private val databasesFound = AtomicInteger(0)
    private val codesFound = AtomicInteger(0)
    private val othersFound = AtomicInteger(0)
    
    // Event stream handlers
    private var progressSink: EventChannel.EventSink? = null
    private var filesSink: EventChannel.EventSink? = null
    
    // Stream handlers
    inner class ProgressStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            progressSink = events
        }

        override fun onCancel(arguments: Any?) {
            progressSink = null
        }
    }
    
    inner class FilesStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            filesSink = events
        }

        override fun onCancel(arguments: Any?) {
            filesSink = null
        }
    }
    
    fun getProgressStreamHandler(): EventChannel.StreamHandler {
        return ProgressStreamHandler()
    }
    
    fun getFilesStreamHandler(): EventChannel.StreamHandler {
        return FilesStreamHandler()
    }
    
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScan" -> {
                val paths = call.argument<List<String>>("paths") ?: getDefaultPaths()
                startScan(paths, result)
            }
            "pauseScan" -> {
                pauseScan()
                result.success(null)
            }
            "resumeScan" -> {
                resumeScan()
                result.success(null)
            }
            "cancelScan" -> {
                cancelScan()
                result.success(null)
            }
            "getStorageInfo" -> {
                result.success(getStorageInfo())
            }
            "generateThumbnail" -> {
                val path = call.argument<String>("path") ?: ""
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                val size = call.argument<Int>("size") ?: 256
                scope.launch {
                    val thumbnail = ThumbnailGenerator.generate(context, path, mimeType, size)
                    withContext(Dispatchers.Main) {
                        result.success(thumbnail)
                    }
                }
            }
            "checkAllFilesPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    result.success(Environment.isExternalStorageManager())
                } else {
                    result.success(true) // Not needed for older versions
                }
            }
            "requestAllFilesPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val intent = android.content.Intent(android.provider.Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                    intent.data = android.net.Uri.parse("package:" + context.packageName)
                    context.startActivity(intent)
                    result.success(true)
                } else {
                    result.success(true)
                }
            }
            "extractMetadata" -> {
                val path = call.argument<String>("path") ?: ""
                scope.launch {
                    val metadata = MetadataExtractor.extract(path)
                    withContext(Dispatchers.Main) {
                        result.success(metadata)
                    }
                }
            }
            "recoverFile" -> {
                val path = call.argument<String>("path") ?: ""
                val name = call.argument<String>("name") ?: "recovered_file"
                val category = call.argument<String>("category") ?: "other"
                scope.launch {
                    try {
                        val recoveredPath = recoverFile(path, name, category)
                        withContext(Dispatchers.Main) {
                            if (recoveredPath != null) {
                                result.success(recoveredPath)
                            } else {
                                result.error("RECOVERY_FAILED", "Could not recover file (null result). Check if 'All Files Access' permission is granted.", null)
                            }
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            val errorMessage = when {
                                e is java.io.FileNotFoundException -> "File not found or access denied: ${e.message}"
                                e.message?.contains("Permission denied") == true -> "Permission denied! Please grant 'All Files Access' in settings."
                                else -> e.message ?: "Unknown error"
                            }
                            result.error("RECOVERY_FAILED", errorMessage, e.stackTraceToString())
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private suspend fun recoverFile(sourcePath: String, fileName: String, category: String): String? = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "[RECOVERY] Starting recovery for: $sourcePath (category: $category)")
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) {
                throw java.io.FileNotFoundException("Source file does not exist at: $sourcePath")
            }

            // Determine best public folder based on category
            val typeDir = when (category.lowercase()) {
                "image" -> Environment.DIRECTORY_PICTURES
                "video" -> Environment.DIRECTORY_MOVIES
                "audio" -> Environment.DIRECTORY_MUSIC
                else -> Environment.DIRECTORY_DOCUMENTS
            }
            
            // Create Fetch folder - log every step
            val publicDir = Environment.getExternalStoragePublicDirectory(typeDir)
            Log.d(TAG, "[RECOVERY] Step 1: Target base dir is: ${publicDir.absolutePath}")
            
            val fetchFolder = File(publicDir, "Fetch")
            if (!fetchFolder.exists()) {
                val created = fetchFolder.mkdirs()
                Log.d(TAG, "[RECOVERY] Step 2: Fetch folder missing, recreating: $created at ${fetchFolder.absolutePath}")
                if (!created && !fetchFolder.exists()) {
                    throw Exception("Could not create 'Fetch' folder at ${fetchFolder.absolutePath}. Please check if the app has permission to write to this location.")
                }
            } else if (!fetchFolder.isDirectory) {
                // If there's a file with the same name, delete it and create a folder
                Log.w(TAG, "[RECOVERY] Step 2: Conflict - 'Fetch' exists but is not a directory. Deleting and recreating.")
                if (fetchFolder.delete() && fetchFolder.mkdirs()) {
                    Log.d(TAG, "[RECOVERY] Step 2: Successfully replaced file with directory")
                } else {
                    throw Exception("A file named 'Fetch' exists and could not be replaced by a folder.")
                }
            } else {
                Log.d(TAG, "[RECOVERY] Step 2: Fetch folder exists and is valid")
            }

            // Final target path
            var targetFile = File(fetchFolder, fileName)
            if (targetFile.exists()) {
                val timestamp = System.currentTimeMillis()
                targetFile = File(fetchFolder, "${timestamp}_$fileName")
                Log.d(TAG, "[RECOVERY] Step 3: Filename conflict, using: ${targetFile.name}")
            } else {
                Log.d(TAG, "[RECOVERY] Step 3: Target filename: ${targetFile.name}")
            }

            // Copy file - check readability first
            Log.d(TAG, "[RECOVERY] Step 4: Checking source readability: ${sourceFile.canRead()}")
            if (!sourceFile.canRead()) {
                throw Exception("Cannot read source file (Permission denied). This usually happens for files in /Android/data or protected system folders. Current app permission: ${context.checkSelfPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE)}")
            }

            Log.d(TAG, "[RECOVERY] Step 5: Starting copy to: ${targetFile.absolutePath}")
            FileInputStream(sourceFile).use { input ->
                FileOutputStream(targetFile).use { output ->
                    val copied = input.copyTo(output)
                    Log.d(TAG, "[RECOVERY] Step 6: Bytes copied: $copied")
                }
            }

            // Trigger Media Scanner
            Log.d(TAG, "[RECOVERY] Step 7: Triggering MediaScanner")
            MediaScannerConnection.scanFile(
                context,
                arrayOf(targetFile.absolutePath),
                null
            ) { path, uri ->
                Log.d(TAG, "[RECOVERY] MediaScanner scan complete - Path: $path, Uri: $uri")
            }

            Log.d(TAG, "[RECOVERY] SUCCESS: ${targetFile.absolutePath}")
            targetFile.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "[RECOVERY] FAILED", e)
            throw e // Rethrow to let the handler catch it and send to Flutter
        }
    }
    
    private fun getDefaultPaths(): List<String> {
        return ComprehensiveFileScanner.STORAGE_PATHS
    }
    
    private fun sendLifecycleState(state: ScanLifecycle) {
        currentLifecycle = state
        Log.d(TAG, "[LIFECYCLE] State changed to: $state")
        scope.launch(Dispatchers.Main) {
            methodChannel?.invokeMethod("onStateChanged", mapOf("state" to state.name))
        }
    }
    
    private fun startScan(paths: List<String>, result: MethodChannel.Result) {
        if (currentLifecycle == ScanLifecycle.SCANNING || currentLifecycle == ScanLifecycle.INITIALIZING) {
            Log.w(TAG, "[INIT] Scan already in progress, ignoring start request")
            result.error("SCAN_IN_PROGRESS", "A scan is already running", null)
            return
        }

        Log.d(TAG, "[INIT] startScan invoked")
        sendLifecycleState(ScanLifecycle.INITIALIZING)
        
        // Reset state
        isPaused.set(false)
        isCancelled.set(false)
        filesScanned.set(0)
        bytesScanned.set(0L)
        imagesFound.set(0)
        videosFound.set(0)
        documentsFound.set(0)
        audioFound.set(0)
        archivesFound.set(0)
        applicationsFound.set(0)
        databasesFound.set(0)
        codesFound.set(0)
        othersFound.set(0)
        
        Log.d(TAG, "====== SCAN LIFECYCLE START ======")
        Log.d(TAG, "[INIT] startScan() entry - Initializing resources")
        
        result.success(null)  // Return immediately to unblock Flutter
        
        // Use a dedicated scope for this scan so we can deterministically cancel child work
        scanScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
        completionEmitted.set(false)
        scanJob = scanScope!!.launch {
            try {
                sendLifecycleState(ScanLifecycle.SCANNING)
                Log.d(TAG, "[SCANNING] Starting file scan traversal...")
                val scanner = ComprehensiveFileScanner(context)
                
                // STEP 1: Calculate total readable storage size
                Log.d(TAG, "[CALC_SIZE] Calculating total storage size...")
                totalStorageBytes = scanner.calculateTotalStorageSize(paths)
                Log.d(TAG, "[CALC_SIZE] Total storage size: ${totalStorageBytes / (1024 * 1024 * 1024)} GB (${totalStorageBytes} bytes)")
                
                // Report initial size to Flutter
                withContext(Dispatchers.Main) {
                    progressSink?.success(mapOf(
                        "filesScanned" to 0,
                        "bytesScanned" to 0L,
                        "totalStorageBytes" to totalStorageBytes,
                        "progress" to 0.0,
                        "estimatedProgress" to 0.0,
                        "currentPath" to "Calculating storage size...",
                        "imagesFound" to 0,
                        "videosFound" to 0,
                        "documentsFound" to 0,
                        "audioFound" to 0,
                        "archivesFound" to 0,
                        "applicationsFound" to 0,
                        "databasesFound" to 0,
                        "codesFound" to 0,
                        "othersFound" to 0
                    ))
                }
                
                // STEP 2: Perform comprehensive filesystem scan with byte tracking
                Log.d(TAG, "[SCAN] Starting comprehensive filesystem traversal...")
                val allFiles = scanner.scanAllStorage { filesFound, bytesFound ->
                    if (isCancelled.get()) return@scanAllStorage
                    
                    filesScanned.set(filesFound)
                    bytesScanned.set(bytesFound)
                    // Report progress frequently during scanning
                    if (filesFound % 50 == 0) {
                        scope.launch {
                            reportProgress()
                        }
                    }
                }
                
                if (isCancelled.get()) {
                    Log.d(TAG, "[SCAN] Scan cancelled during traversal, skipping finalization")
                    return@launch
                }

                sendLifecycleState(ScanLifecycle.FINALIZING)
                Log.d(TAG, "[FINALIZE] Traversal complete. Starting deterministic shutdown.")
                Log.d(TAG, "[FINALIZE] Found ${allFiles.size} total files. Last directory: ${if (allFiles.isNotEmpty()) File(allFiles.last().path).parent else "N/A"}")
                
                filesScanned.set(allFiles.size)
                bytesScanned.set(allFiles.sumOf { it.fileSize })
                
                // Batch files by category and send to Flutter
                Log.d(TAG, "[BATCH] Starting batch dispatch...")
                if (allFiles.isNotEmpty()) {
                    batchAndSendFiles(allFiles)
                }
                
                Log.d(TAG, "[FINALIZE] All file batches emitted. Finalizing state.")
                
                // Final progress update - force to 100%
                withContext(Dispatchers.Main) {
                    progressSink?.success(mapOf(
                        "filesScanned" to filesScanned.get(),
                        "bytesScanned" to bytesScanned.get(),
                        "totalStorageBytes" to totalStorageBytes,
                        "progress" to 100.0,
                        "estimatedProgress" to 100.0,
                        "currentPath" to "Finalizing results..."
                    ))
                }
                // Send completion signal - CRITICAL: Exactly once, unblocking navigation
                Log.d(TAG, "[COMPLETE] Preparing to emit onScanCompleted signal")
                if (completionEmitted.compareAndSet(false, true)) {
                    val categoriesSummary = mapOf(
                        "images" to imagesFound.get(),
                        "videos" to videosFound.get(),
                        "documents" to documentsFound.get(),
                        "audio" to audioFound.get(),
                        "archives" to archivesFound.get(),
                        "applications" to applicationsFound.get(),
                        "databases" to databasesFound.get(),
                        "codes" to codesFound.get(),
                        "others" to othersFound.get()
                    )

                    Log.d(TAG, "[COMPLETE] ====== EMITTING onScanCompleted SIGNAL ======")
                    withContext(Dispatchers.Main) {
                        try {
                            methodChannel?.invokeMethod("onScanCompleted", mapOf(
                                "totalFilesFound" to allFiles.size,
                                "totalBytesScanned" to bytesScanned.get(),
                                "categoriesSummary" to categoriesSummary
                            ))
                            sendLifecycleState(ScanLifecycle.COMPLETED)
                            Log.d(TAG, "[COMPLETE] onScanCompleted invoked successfully")
                            Log.d(TAG, "[COMPLETE] Flutter state changed to COMPLETED")
                        } catch (e: Exception) {
                            Log.e(TAG, "[COMPLETE] FAILED to invoke onScanCompleted", e)
                        }
                    }
                } else {
                    Log.w(TAG, "[COMPLETE] onScanCompleted already emitted; skipping duplicate")
                }
                
                Log.d(TAG, "====== SCAN LIFECYCLE COMPLETE ======")
            } catch (e: Exception) {
                sendLifecycleState(ScanLifecycle.ERROR)
                Log.e(TAG, "[ERROR] ====== SCAN FAILED ====== ", e)
                Log.e(TAG, "[ERROR] Message: ${e.message}")
                withContext(Dispatchers.Main) {
                    methodChannel?.invokeMethod("onError", mapOf("error" to e.message))
                }
            } finally {
                Log.d(TAG, "[CLEANUP] Scan job finally block. Initiating deterministic shutdown of scan scope and workers.")
                try {
                    // Cancel dedicated scan scope to stop any lingering child coroutines
                    scanScope?.cancel()
                    Log.d(TAG, "[CLEANUP] scanScope cancelled - worker threads (if any) signalled to stop.")
                } catch (e: Exception) {
                    Log.e(TAG, "[CLEANUP] Error cancelling scanScope: ${e.message}")
                } finally {
                    scanScope = null
                    scanJob = null
                }
            }
        }
    }
    
    private suspend fun batchAndSendFiles(files: List<ScannedFileData>) {
        // Group files by category
        val filesByCategory = files.groupBy { it.fileType }
        
        // Send files in batches of 50 per category
        val batchSize = 50
        
        for ((category, categoryFiles) in filesByCategory) {
            Log.d(TAG, "[BATCH] Processing $category files: ${categoryFiles.size}")
            
            val batches = categoryFiles.chunked(batchSize)
            for ((batchIndex, batch) in batches.withIndex()) {
                if (isCancelled.get()) {
                    Log.d(TAG, "[BATCH] Scan cancelled, stopping file batching")
                    return
                }
                
                // Convert to sendable format
                val filesData = batch.map { file ->
                    mapOf(
                        "path" to file.path,
                        "name" to file.fileName,
                        "size" to file.fileSize,
                        "extension" to file.extension,
                        "category" to file.fileType,
                        "mimeType" to file.mimeType,
                        "lastModified" to file.lastModified,
                        "isHidden" to file.fileName.startsWith(".")
                    )
                }
                
                // Update counters
                for (file in batch) {
                    when (file.fileType) {
                        "image" -> imagesFound.incrementAndGet()
                        "video" -> videosFound.incrementAndGet()
                        "document" -> documentsFound.incrementAndGet()
                        "audio" -> audioFound.incrementAndGet()
                        "archive" -> archivesFound.incrementAndGet()
                        "application" -> applicationsFound.incrementAndGet()
                        "database" -> databasesFound.incrementAndGet()
                        "code" -> codesFound.incrementAndGet()
                        else -> othersFound.incrementAndGet()
                    }
                }
                
                // Send batch to Flutter (must be suspending to ensure proper ordering)
                Log.d(TAG, "[BATCH] Sending $category batch ${batchIndex + 1}/${batches.size} (${batch.size} files)")
                withContext(Dispatchers.Main) {
                    filesSink?.success(mapOf(
                        "category" to category,
                        "files" to filesData,
                        "batch" to batchIndex
                    ))
                }
                
                // Report progress
                reportProgress()
                
                // Small delay to prevent overwhelming the UI
                delay(10)
            }
            
            Log.d(TAG, "[BATCH] Completed sending all batches for $category")
        }
        
        Log.d(TAG, "[BATCH] All file batches sent to Flutter")
    }
    
    private suspend fun reportProgress() {
        val totalFound = imagesFound.get() + videosFound.get() + documentsFound.get() + audioFound.get() + 
                        archivesFound.get() + applicationsFound.get() + databasesFound.get() + codesFound.get() + othersFound.get()
        val scanned = filesScanned.get()
        val bytesCur = bytesScanned.get()
        
        // Calculate progress based on bytes scanned / total storage bytes
        val progressPercentage = if (totalStorageBytes > 0) {
            min(98.0, (bytesCur.toDouble() / totalStorageBytes) * 100.0)  // Cap at 98% during scan
        } else {
            min(98.0, if (scanned > 0) (totalFound.toDouble() / scanned) * 100.0 else 0.0)  // Fallback
        }
        
        val progressData = mapOf(
            "filesScanned" to scanned,
            "bytesScanned" to bytesCur,
            "totalStorageBytes" to totalStorageBytes,
            "imagesFound" to imagesFound.get(),
            "videosFound" to videosFound.get(),
            "documentsFound" to documentsFound.get(),
            "audioFound" to audioFound.get(),
            "archivesFound" to archivesFound.get(),
            "applicationsFound" to applicationsFound.get(),
            "databasesFound" to databasesFound.get(),
            "codesFound" to codesFound.get(),
            "othersFound" to othersFound.get(),
            "progress" to progressPercentage,
            "estimatedProgress" to progressPercentage,
            "currentPath" to "Processing files..."
        )
        
        withContext(Dispatchers.Main) {
            progressSink?.success(progressData)
        }
    }
    
    private fun pauseScan() {
        isPaused.set(true)
    }
    
    private fun resumeScan() {
        isPaused.set(false)
    }
    
    private fun cancelScan() {
        isCancelled.set(true)
        scanJob?.cancel()
    }
    
    private fun getStorageInfo(): Map<String, Long> {
        val path = Environment.getExternalStorageDirectory()
        val stat = StatFs(path.path)
        
        val totalBytes = stat.blockCountLong * stat.blockSizeLong
        val freeBytes = stat.availableBlocksLong * stat.blockSizeLong
        val usedBytes = totalBytes - freeBytes
        
        return mapOf(
            "totalBytes" to totalBytes,
            "usedBytes" to usedBytes,
            "freeBytes" to freeBytes
        )
    }
    
    fun cleanup() {
        scope.cancel()
    }
}
