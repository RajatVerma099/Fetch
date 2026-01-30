package com.fetch.fetch

import java.io.File
import android.os.Build
import android.os.Environment
import android.content.Context
import android.util.Log

// Data class for scanned files
data class ScannedFileData(
    val path: String,
    val fileName: String,
    val fileSize: Long,
    val extension: String,
    val mimeType: String,
    val fileType: String,
    val lastModified: Long
)

/**
 * Comprehensive low-level file scanner with recursive traversal
 * Scans ALL readable filesystem paths including hidden files and directories
 * Does NOT rely on MediaStore - performs direct filesystem traversal
 */
class ComprehensiveFileScanner(private val context: Context) {
    
    companion object {
        private const val TAG = "ComprehensiveFileScanner"
        private const val MAX_DEPTH = 20 // Prevent infinite recursion
        
        // Storage paths to scan - COMPREHENSIVE COVERAGE
        // Root paths + ALL subdirectories under /storage/emulated/0
        val STORAGE_PATHS = listOf(
            // Primary internal storage
            "/storage/emulated/0",
            "/storage/self/primary",
            "/sdcard",
            
            // Standard Android directories
            "/storage/emulated/0/Download",
            "/storage/emulated/0/Downloads",
            "/storage/emulated/0/Documents",
            "/storage/emulated/0/DCIM",
            "/storage/emulated/0/DCIM/Camera",
            "/storage/emulated/0/Pictures",
            "/storage/emulated/0/Movies",
            "/storage/emulated/0/Music",
            "/storage/emulated/0/Audio",
            "/storage/emulated/0/Video",
            "/storage/emulated/0/Recordings",
            "/storage/emulated/0/Camera",
            "/storage/emulated/0/Bluetooth",
            
            // Hidden folders with thumbnails and caches
            "/storage/emulated/0/.thumbnails",
            "/storage/emulated/0/.thumbnail",
            "/storage/emulated/0/.crop",
            "/storage/emulated/0/.cache",
            "/storage/emulated/0/.temp",
            "/storage/emulated/0/.statuses",
            "/storage/emulated/0/.links",
            "/storage/emulated/0/.nomedia",
            "/storage/emulated/0/.app_icon_back",
            "/storage/emulated/0/.images",
            "/storage/emulated/0/.videos",
            "/storage/emulated/0/.trash",
            "/storage/emulated/0/.backup",
            
            // Recovery app folders
            "/storage/emulated/0/0",
            "/storage/emulated/0/0(1)",
            
            // WhatsApp
            "/storage/emulated/0/WhatsApp",
            "/storage/emulated/0/WhatsApp/Media",
            "/storage/emulated/0/WhatsApp/Media/WhatsApp Images",
            "/storage/emulated/0/WhatsApp/Media/WhatsApp Video",
            "/storage/emulated/0/WhatsApp/Media/WhatsApp Documents",
            "/storage/emulated/0/WhatsApp/Media/.Statuses",
            "/storage/emulated/0/Android/media/com.whatsapp",
            "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp Images",
            "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp Video",
            "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp Documents",
            "/storage/emulated/0/Android/media/com.whatsapp/.Statuses",
            
            // Telegram
            "/storage/emulated/0/Telegram",
            "/storage/emulated/0/Telegram Images",
            "/storage/emulated/0/Telegram Video",
            "/storage/emulated/0/Telegram Documents",
            "/storage/emulated/0/Telegram Audio",
            "/storage/emulated/0/Android/media/org.telegram.messenger",
            "/storage/emulated/0/Android/data/org.telegram.messenger/files",
            
            // Instagram
            "/storage/emulated/0/Instagram",
            "/storage/emulated/0/Instagram Images",
            "/storage/emulated/0/Instagram Video",
            "/storage/emulated/0/DCIM/Instagram",
            
            // Social media apps
            "/storage/emulated/0/Snapchat",
            "/storage/emulated/0/Facebook",
            "/storage/emulated/0/DCIM/Facebook",
            
            // Screen recording and video editors
            "/storage/emulated/0/ScreenRecorder",
            "/storage/emulated/0/ScreenRecords",
            "/storage/emulated/0/VideoEditor",
            "/storage/emulated/0/Duo",
            
            // Voice recorders and podcasts
            "/storage/emulated/0/VoiceRecorder",
            "/storage/emulated/0/CallRecordings",
            "/storage/emulated/0/Sounds",
            "/storage/emulated/0/Podcasts",
            
            // Office apps
            "/storage/emulated/0/Office",
            "/storage/emulated/0/WPS",
            "/storage/emulated/0/PolarisOffice",
            "/storage/emulated/0/Adobe",
            
            // File sharing
            "/storage/emulated/0/Xender",
            "/storage/emulated/0/ShareIt",
            
            // Backup folders
            "/storage/emulated/0/Backups",
            "/storage/emulated/0/Trash",
            "/storage/emulated/0/RecycleBin",
            
            // Android app-specific media
            "/storage/emulated/0/Android/media",
            "/storage/emulated/0/Android/.trash",
            
            // External SD card patterns (will scan if they exist)
            "/storage/XXXX-XXXX",
            "/mnt/media_rw/XXXX-XXXX",
            "/storage/extSdCard",
            "/storage/external_SD",
            "/storage/sdcard1",
        )
        
        // ALL image extensions (must include hidden formats)
        val IMAGE_EXTENSIONS = setOf(
            "jpg", "jpeg", "png", "webp", "heic", "heif",
            "bmp", "gif", "tif", "tiff", "ico",
            "raw", "arw", "cr2", "nef", "dng", "orf", "rw2",
            "svg", "psd", "ai", "eps"
        )
        
        // ALL video extensions
        val VIDEO_EXTENSIONS = setOf(
            "mp4", "mkv", "avi", "mov", "webm", "flv",
            "3gp", "3gpp", "m4v", "mpg", "mpeg",
            "wmv", "asf", "ts", "mts", "m2ts",
            "vob", "ogv", "rm", "rmvb", "divx"
        )
        
        // ALL audio extensions
        val AUDIO_EXTENSIONS = setOf(
            "mp3", "wav", "aac", "ogg", "opus",
            "flac", "alac", "m4a", "wma",
            "amr", "aiff", "mid", "midi",
            "ra", "rm"
        )
        
        // ALL document extensions (MUST include - this fixes Documents = 0)
        val DOCUMENT_EXTENSIONS = setOf(
            "pdf",
            "doc", "docx", "dot", "docm",
            "xls", "xlsx", "xlsm", "xlt", "xltx",
            "ppt", "pptx", "pptm", "pot", "potx",
            "txt", "rtf", "csv",
            "odt", "ods", "odp",
            "md", "markdown",
            "log", "tex",
            "epub", "mobi", "azw", "azw3",
            "pages", "numbers", "key"
        )
        
        // ALL archive extensions
        val ARCHIVE_EXTENSIONS = setOf(
            "zip", "rar", "7z", "tar", "gz", "bz2",
            "xz", "lz", "lzma", "iso", "dmg",
            "cab", "arj", "z", "deb", "rpm"
        )
        
        // APK and app extensions
        val APP_EXTENSIONS = setOf(
            "apk", "xapk", "apkm", "aab",
            "exe", "dll", "so", "bin",
            "dat", "img", "vhd", "vhdx"
        )
        
        // Database extensions
        val DATABASE_EXTENSIONS = setOf(
            "db", "sqlite", "sqlite3",
            "bak", "backup", "old",
            "dump", "sql",
            "realm", "leveldb"
        )
        
        // Code extensions
        val CODE_EXTENSIONS = setOf(
            "json", "xml", "yaml", "yml",
            "ini", "cfg", "conf",
            "env", "properties",
            "js", "ts", "dart", "java", "kt",
            "py", "c", "cpp", "h", "cs",
            "php", "go", "rs", "swift"
        )
        
        // Folders to SKIP (system folders only)
        val SKIP_FOLDERS = setOf(
            "system32",
            "windows",
            "proc",
            "sys",
            "dev",
            "boot",
            ".git"
        )
    }
    
    /**
     * Calculate total readable storage size (non-blocking estimate)
     * Used for progress calculations
     */
    fun calculateTotalStorageSize(paths: List<String>): Long {
        var totalBytes = 0L
        val scannedPaths = mutableSetOf<String>()
        
        for (path in paths) {
            try {
                val file = File(path)
                if (file.exists() && file.isDirectory && file.canRead()) {
                    scannedPaths.add(file.absolutePath)
                    totalBytes += calculateDirectorySize(file, scannedPaths, depth = 0)
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error calculating size for $path: ${e.message}")
            }
        }
        
        Log.d(TAG, "Total readable storage size: ${totalBytes / (1024 * 1024)} MB")
        return totalBytes
    }
    
    /**
     * Recursively calculate directory size quickly
     * Returns total bytes in directory and subdirectories
     */
    private fun calculateDirectorySize(dir: File, visited: MutableSet<String>, depth: Int): Long {
        if (depth > MAX_DEPTH || !dir.canRead()) return 0L
        
        var size = 0L
        try {
            val files = dir.listFiles() ?: return 0L
            for (file in files) {
                try {
                    if (!file.canRead()) continue
                    val path = file.absolutePath
                    if (visited.contains(path)) continue // Prevent loops
                    
                    if (file.isDirectory) {
                        visited.add(path)
                        size += calculateDirectorySize(file, visited, depth + 1)
                    } else {
                        size += file.length()
                    }
                } catch (e: Exception) {
                    // Skip files we can't read
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error calculating size: ${e.message}")
        }
        return size
    }
    
    /**
     * Scan ALL accessible storage and return complete file list
     * This traverses recursively including all hidden files and folders
     * onProgress callback now receives (filesFound, bytesScanned)
     */
    fun scanAllStorage(onProgress: (filesFound: Int, bytesScanned: Long) -> Unit = { _, _ -> }): List<ScannedFileData> {
        val files = mutableListOf<ScannedFileData>()
        val scannedPaths = mutableSetOf<String>()
        
        Log.d(TAG, "Starting comprehensive filesystem scan...")
        
        // Get unique storage paths that exist
        val pathsToScan = STORAGE_PATHS
            .filter { it.isNotEmpty() }
            .distinct()
            .mapNotNull { path ->
                val file = File(path)
                if (file.exists() && file.isDirectory && !scannedPaths.contains(file.absolutePath)) {
                    scannedPaths.add(file.absolutePath)
                    file.absolutePath
                } else null
            }
        
        Log.d(TAG, "Scanning ${pathsToScan.size} root paths: $pathsToScan")
        
        // Scan each root path recursively
        for (startPath in pathsToScan) {
            try {
                scanDirectoryRecursive(
                    currentDir = startPath,
                    files = files,
                    scannedPaths = scannedPaths,
                    depth = 0,
                    onProgress = onProgress
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error scanning path $startPath: ${e.message}")
            }
        }
        
        Log.d(TAG, "Scan complete. Found ${files.size} total files")
        
        // Log breakdown by type
        val breakdown = files.groupBy { it.fileType }
        for ((type, typeFiles) in breakdown) {
            Log.d(TAG, "Found ${typeFiles.size} $type files")
        }
        
        // Return all files
        return files.distinctBy { it.path }
    }
    
    /**
     * Recursively scan directories at low level
     * Includes hidden files and folders - DOES NOT SKIP THEM
     * Tracks bytes and files for progress
     */
    private fun scanDirectoryRecursive(
        currentDir: String,
        files: MutableList<ScannedFileData>,
        scannedPaths: MutableSet<String>,
        depth: Int,
        onProgress: (filesFound: Int, bytesScanned: Long) -> Unit
    ) {
        if (depth > MAX_DEPTH) {
            Log.w(TAG, "Max depth reached at $currentDir")
            return
        }
        
        try {
            val directory = File(currentDir)
            
            // Must be readable directory
            if (!directory.exists() || !directory.isDirectory || !directory.canRead()) {
                return
            }
            
            val listFiles = directory.listFiles() ?: return
            var bytesInThisDir = 0L
            
            for (file in listFiles) {
                try {
                    // Skip only if we can't read it at all
                    if (!file.canRead()) continue
                    
                    val absolutePath = file.absolutePath
                    val fileName = file.name
                    
                    // Avoid circular symlinks
                    if (scannedPaths.contains(absolutePath)) continue
                    
                    if (file.isDirectory) {
                        // Add directory to scanned set
                        scannedPaths.add(absolutePath)
                        
                        // Skip ONLY system folders (not hidden folders with . prefix)
                        if (!shouldSkipFolder(fileName)) {
                            // Recursively scan subdirectories
                            scanDirectoryRecursive(
                                currentDir = absolutePath,
                                files = files,
                                scannedPaths = scannedPaths,
                                depth = depth + 1,
                                onProgress = onProgress
                            )
                        }
                    } else {
                        // This is a file - ADD IT REGARDLESS OF SIZE
                        // Even if it has no extension, even if it's hidden
                        val extension = file.extension.lowercase()
                        val fileSize = file.length()
                        val fileData = ScannedFileData(
                            path = absolutePath,
                            fileName = fileName,
                            fileSize = fileSize,
                            extension = extension,
                            mimeType = getMimeType(extension),
                            fileType = getFileType(extension),
                            lastModified = file.lastModified()
                        )
                        files.add(fileData)
                        bytesInThisDir += fileSize
                        
                        // Report progress every 100-300 files or every 5MB
                        if (files.size % 200 == 0 || bytesInThisDir > 5 * 1024 * 1024) {
                            onProgress(files.size, files.sumOf { it.fileSize })
                            bytesInThisDir = 0L
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing file ${file.absolutePath}: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error scanning directory $currentDir: ${e.message}")
        }
    }
    
    private fun getFileType(extension: String): String {
        return when (extension) {
            in IMAGE_EXTENSIONS -> "image"
            in VIDEO_EXTENSIONS -> "video"
            in AUDIO_EXTENSIONS -> "audio"
            in DOCUMENT_EXTENSIONS -> "document"
            in ARCHIVE_EXTENSIONS -> "archive"
            in APP_EXTENSIONS -> "application"
            in DATABASE_EXTENSIONS -> "database"
            in CODE_EXTENSIONS -> "code"
            else -> "other"
        }
    }
    
    private fun getMimeType(extension: String): String {
        return when (extension) {
            // Images
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "webp" -> "image/webp"
            "heic", "heif" -> "image/heic"
            "bmp" -> "image/bmp"
            "gif" -> "image/gif"
            "tif", "tiff" -> "image/tiff"
            "ico" -> "image/x-icon"
            "svg" -> "image/svg+xml"
            "psd" -> "image/vnd.adobe.photoshop"
            
            // Videos
            "mp4" -> "video/mp4"
            "mkv" -> "video/x-matroska"
            "avi" -> "video/x-msvideo"
            "mov" -> "video/quicktime"
            "webm" -> "video/webm"
            "flv" -> "video/x-flv"
            "3gp", "3gpp" -> "video/3gpp"
            "m4v" -> "video/x-m4v"
            "mpg", "mpeg" -> "video/mpeg"
            "wmv", "asf" -> "video/x-ms-wmv"
            "ts", "mts", "m2ts" -> "video/mp2t"
            "vob" -> "video/x-vob"
            "ogv" -> "video/ogg"
            "rm", "rmvb" -> "video/x-pn-realvideo"
            "divx" -> "video/x-divx"
            
            // Audio
            "mp3" -> "audio/mpeg"
            "wav" -> "audio/wav"
            "aac" -> "audio/aac"
            "ogg" -> "audio/ogg"
            "opus" -> "audio/opus"
            "flac" -> "audio/flac"
            "alac" -> "audio/mp4"
            "m4a" -> "audio/mp4"
            "wma" -> "audio/x-ms-wma"
            "amr" -> "audio/amr"
            "aiff" -> "audio/aiff"
            "mid", "midi" -> "audio/midi"
            "ra", "rm" -> "audio/x-realaudio"
            
            // Documents
            "pdf" -> "application/pdf"
            "doc" -> "application/msword"
            "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "dot" -> "application/msword"
            "xls" -> "application/vnd.ms-excel"
            "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "xlsm" -> "application/vnd.ms-excel.sheet.macroEnabled.12"
            "ppt" -> "application/vnd.ms-powerpoint"
            "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            "pptm" -> "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
            "txt" -> "text/plain"
            "rtf" -> "application/rtf"
            "csv" -> "text/csv"
            "odt" -> "application/vnd.oasis.opendocument.text"
            "ods" -> "application/vnd.oasis.opendocument.spreadsheet"
            "odp" -> "application/vnd.oasis.opendocument.presentation"
            "md", "markdown" -> "text/markdown"
            "log" -> "text/plain"
            "tex" -> "application/x-latex"
            "epub" -> "application/epub+zip"
            "mobi" -> "application/x-mobipocket-ebook"
            "azw", "azw3" -> "application/vnd.amazon.ebook"
            "pages" -> "application/vnd.apple.pages"
            "numbers" -> "application/vnd.apple.numbers"
            "key" -> "application/vnd.apple.keynote"
            
            // Archives
            "zip" -> "application/zip"
            "rar" -> "application/x-rar-compressed"
            "7z" -> "application/x-7z-compressed"
            "tar" -> "application/x-tar"
            "gz" -> "application/gzip"
            "bz2" -> "application/x-bzip2"
            "xz" -> "application/x-xz"
            "iso" -> "application/x-iso9660-image"
            "dmg" -> "application/x-dmg"
            "cab" -> "application/vnd.ms-cab-compressed"
            
            // Applications
            "apk" -> "application/vnd.android.package-archive"
            "xapk" -> "application/vnd.android.package-archive"
            "exe" -> "application/x-msdownload"
            "dll" -> "application/x-msdownload"
            "so" -> "application/octet-stream"
            
            // Database
            "db", "sqlite", "sqlite3" -> "application/octet-stream"
            "sql" -> "text/x-sql"
            
            else -> "application/octet-stream"
        }
    }
    
    private fun shouldSkipFolder(folderName: String): Boolean {
        val lowerName = folderName.lowercase()
        
        // Only skip actual system folders, not hidden app folders
        return lowerName in SKIP_FOLDERS
    }
}
