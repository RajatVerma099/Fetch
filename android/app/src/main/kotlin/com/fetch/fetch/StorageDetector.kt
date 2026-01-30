package com.fetch.fetch

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.util.Log
import java.io.File

/**
 * Detects external SD cards and provides storage mount information
 * Uses Android StorageManager API for reliable detection
 */
object StorageDetector {
    private const val TAG = "StorageDetector"
    
    /**
     * Detects if an external SD card is mounted
     * Returns: Map with mount information or empty map if none found
     */
    fun detectExternalSD(context: Context): Map<String, Any> {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                detectUsingStorageManager(context)
            } else {
                detectUsingEnvironment()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error detecting SD card: ${e.message}")
            emptyMap()
        }
    }
    
    /**
     * Check if external SD card is currently mounted
     */
    fun isExternalSDMounted(): Boolean {
        return try {
            // Check common external SD paths
            val externalPaths = listOf(
                "/storage/XXXX-XXXX",
                "/mnt/media_rw/XXXX-XXXX",
                "/storage/extSdCard",
                "/storage/external_SD",
                "/storage/sdcard1"
            )
            
            externalPaths.any { path ->
                val file = File(path)
                file.exists() && file.isDirectory && file.canRead()
            }
        } catch (e: Exception) {
            false
        }
    }
    
    /**
     * Detect SD card using StorageManager (Android 7.0+)
     */
    @Suppress("DEPRECATION")
    private fun detectUsingStorageManager(context: Context): Map<String, Any> {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
                    ?: return emptyMap()
                
                val volumes = storageManager.storageVolumes
                Log.d(TAG, "Found ${volumes.size} storage volumes")
                
                val externalVolumes = mutableListOf<Map<String, Any>>()
                
                for (volume in volumes) {
                    try {
                        // Check if it's removable (SD card)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            if (volume.isRemovable) {
                                val mountPoint = getMountPoint(volume, context)
                                if (mountPoint != null && File(mountPoint).exists()) {
                                    externalVolumes.add(mapOf(
                                        "path" to mountPoint,
                                        "type" to "sdcard",
                                        "removable" to true,
                                        "primary" to volume.isPrimary
                                    ))
                                    Log.d(TAG, "Found removable volume at $mountPoint")
                                }
                            }
                        } else {
                            // For Android 7-10, use different approach
                            val state = volume.state
                            val isRemovable = volume.isRemovable
                            if (isRemovable && state == Environment.MEDIA_MOUNTED) {
                                val mountPoint = getMountPoint(volume, context)
                                if (mountPoint != null && mountPoint != Environment.getExternalStorageDirectory().absolutePath) {
                                    externalVolumes.add(mapOf(
                                        "path" to mountPoint,
                                        "type" to "sdcard",
                                        "removable" to true,
                                        "primary" to false
                                    ))
                                    Log.d(TAG, "Found external volume at $mountPoint")
                                }
                            }
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Error checking volume: ${e.message}")
                    }
                }
                
                return if (externalVolumes.isNotEmpty()) {
                    mapOf(
                        "found" to true,
                        "volumes" to externalVolumes,
                        "count" to externalVolumes.size
                    )
                } else {
                    emptyMap()
                }
            } else {
                emptyMap()
            }
        } catch (e: Exception) {
            Log.e(TAG, "StorageManager detection failed: ${e.message}")
            emptyMap()
        }
    }
    
    /**
     * Get mount point for storage volume (Android 7.0+)
     */
    private fun getMountPoint(volume: StorageVolume, context: Context): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Android 11+: Use getDirectory API
                volume.directory?.absolutePath
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Android 7-10: Use reflection
                val method = StorageVolume::class.java.getMethod("getDirectory")
                (method.invoke(volume) as? File)?.absolutePath
            } else {
                null
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not get mount point: ${e.message}")
            null
        }
    }
    
    /**
     * Fallback detection using Environment (older Android versions)
     */
    @Suppress("DEPRECATION")
    private fun detectUsingEnvironment(): Map<String, Any> {
        val externalStorage = Environment.getExternalStorageState()
        
        return if (externalStorage == Environment.MEDIA_MOUNTED) {
            // Check for secondary external storage
            val secondaryStoragePath = System.getenv("SECONDARY_STORAGE")
            if (!secondaryStoragePath.isNullOrEmpty()) {
                val paths = secondaryStoragePath.split(":")
                val validPaths = paths.filter { path ->
                    val file = File(path)
                    file.exists() && file.isDirectory && file.canRead()
                }
                
                if (validPaths.isNotEmpty()) {
                    mapOf(
                        "found" to true,
                        "volumes" to validPaths.map { path ->
                            mapOf(
                                "path" to path,
                                "type" to "sdcard",
                                "removable" to true
                            )
                        },
                        "count" to validPaths.size
                    )
                } else {
                    emptyMap()
                }
            } else {
                emptyMap()
            }
        } else {
            emptyMap()
        }
    }
}
