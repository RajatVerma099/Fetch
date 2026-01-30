package com.fetch.fetch

import android.content.Context
import android.media.MediaMetadataRetriever
import android.graphics.Bitmap
import android.util.Log
import java.io.File
import java.io.FileOutputStream

/**
 * Extracts video thumbnails using Android's MediaMetadataRetriever
 * Creates proper thumbnail images from video files
 */
class VideoThumbnailExtractor(private val context: Context) {
    
    companion object {
        private const val TAG = "VideoThumbnailExtractor"
        private const val THUMBNAIL_DIR = "video_thumbnails"
        private const val THUMBNAIL_WIDTH = 320
        private const val THUMBNAIL_HEIGHT = 180
    }
    
    /**
     * Extract thumbnail from video file
     * Returns path to saved thumbnail or null if extraction failed
     */
    fun extractThumbnail(
        videoPath: String,
        timeUs: Long = 1000000 // 1 second into video
    ): String? {
        return try {
            val videoFile = File(videoPath)
            if (!videoFile.exists() || !videoFile.canRead()) {
                Log.w(TAG, "Video file not readable: $videoPath")
                return null
            }
            
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(videoPath)
                
                // Get frame at specified time
                val bitmap = retriever.getFrameAtTime(
                    timeUs,
                    MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                ) ?: run {
                    Log.w(TAG, "Could not extract frame from: $videoPath")
                    return null
                }
                
                // Scale down to save space
                val scaled = Bitmap.createScaledBitmap(
                    bitmap,
                    THUMBNAIL_WIDTH,
                    THUMBNAIL_HEIGHT,
                    true
                )
                
                // Save to cache directory
                val savedPath = saveThumbnail(scaled, videoPath)
                
                // Cleanup
                bitmap.recycle()
                if (bitmap != scaled) scaled.recycle()
                
                return savedPath
            } catch (e: Exception) {
                Log.e(TAG, "Error extracting thumbnail from $videoPath: ${e.message}")
                return null
            } finally {
                try {
                    retriever.release()
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing retriever: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error in extractThumbnail: ${e.message}")
            return null
        }
    }
    
    /**
     * Extract multiple thumbnails
     */
    fun extractThumbnails(videoPaths: List<String>): Map<String, String> {
        val results = mutableMapOf<String, String>()
        
        for ((index, path) in videoPaths.withIndex()) {
            try {
                val thumbnail = extractThumbnail(path)
                if (thumbnail != null) {
                    results[path] = thumbnail
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error extracting thumbnail for $path: ${e.message}")
            }
        }
        
        return results
    }
    
    /**
     * Get video metadata (duration, width, height)
     */
    fun getVideoMetadata(videoPath: String): VideoMetadata? {
        return try {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(videoPath)
                
                val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                val widthStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                val heightStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                
                VideoMetadata(
                    duration = durationStr?.toLongOrNull() ?: 0,
                    width = widthStr?.toIntOrNull() ?: 0,
                    height = heightStr?.toIntOrNull() ?: 0
                )
            } finally {
                try {
                    retriever.release()
                } catch (e: Exception) {
                    // Ignore
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting video metadata: ${e.message}")
            null
        }
    }
    
    /**
     * Save bitmap to cache directory
     */
    private fun saveThumbnail(bitmap: Bitmap, videoPath: String): String? {
        return try {
            // Create thumbnail directory
            val cacheDir = File(context.cacheDir, THUMBNAIL_DIR)
            if (!cacheDir.exists()) {
                cacheDir.mkdirs()
            }
            
            // Generate unique filename based on video path hash
            val fileName = "${videoPath.hashCode().toString().replace("-", "")}_thumb.jpg"
            val thumbnailFile = File(cacheDir, fileName)
            
            // Save bitmap as JPEG
            FileOutputStream(thumbnailFile).use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, output)
                output.flush()
            }
            
            Log.d(TAG, "Thumbnail saved: ${thumbnailFile.absolutePath}")
            return thumbnailFile.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Error saving thumbnail: ${e.message}")
            return null
        }
    }
    
    /**
     * Clear thumbnail cache
     */
    fun clearCache() {
        try {
            val cacheDir = File(context.cacheDir, THUMBNAIL_DIR)
            if (cacheDir.exists()) {
                cacheDir.deleteRecursively()
                Log.d(TAG, "Thumbnail cache cleared")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing cache: ${e.message}")
        }
    }
}

/**
 * Video metadata
 */
data class VideoMetadata(
    val duration: Long, // milliseconds
    val width: Int,
    val height: Int
)
