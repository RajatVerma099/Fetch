package com.fetch.fetch

import android.media.MediaMetadataRetriever
import android.media.ExifInterface
import java.io.File

/**
 * Extract metadata from media files
 */
object MetadataExtractor {
    
    fun extract(path: String): Map<String, Any?>? {
        val file = File(path)
        if (!file.exists()) return null
        
        return try {
            when {
                isImage(path) -> extractImageMetadata(path)
                isVideo(path) -> extractVideoMetadata(path)
                else -> null
            }
        } catch (e: Exception) {
            null
        }
    }
    
    private fun isImage(path: String): Boolean {
        val ext = path.substringAfterLast('.').lowercase()
        return ext in listOf("jpg", "jpeg", "png", "gif", "bmp", "webp", "heic", "heif")
    }
    
    private fun isVideo(path: String): Boolean {
        val ext = path.substringAfterLast('.').lowercase()
        return ext in listOf("mp4", "mov", "avi", "mkv", "webm", "3gp", "m4v")
    }
    
    private fun extractImageMetadata(path: String): Map<String, Any?> {
        val metadata = mutableMapOf<String, Any?>()
        
        try {
            val exif = ExifInterface(path)
            
            // Get dimensions
            val width = exif.getAttributeInt(ExifInterface.TAG_IMAGE_WIDTH, 0)
            val height = exif.getAttributeInt(ExifInterface.TAG_IMAGE_LENGTH, 0)
            
            if (width > 0) metadata["width"] = width
            if (height > 0) metadata["height"] = height
            
            // Get orientation
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION, 
                ExifInterface.ORIENTATION_NORMAL
            )
            metadata["orientation"] = orientation
            
            // Get date taken
            val dateTime = exif.getAttribute(ExifInterface.TAG_DATETIME)
            if (dateTime != null) {
                metadata["dateTaken"] = dateTime
            }
            
            // Get location if available
            val latLong = FloatArray(2)
            if (exif.getLatLong(latLong)) {
                metadata["latitude"] = latLong[0].toDouble()
                metadata["longitude"] = latLong[1].toDouble()
            }
            
            // Get camera info
            val make = exif.getAttribute(ExifInterface.TAG_MAKE)
            val model = exif.getAttribute(ExifInterface.TAG_MODEL)
            if (make != null) metadata["cameraMake"] = make
            if (model != null) metadata["cameraModel"] = model
            
        } catch (e: Exception) {
            // EXIF extraction failed, try alternative methods
        }
        
        // If dimensions not found via EXIF, try to get them from file
        if (!metadata.containsKey("width") || metadata["width"] == 0) {
            try {
                val options = android.graphics.BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                android.graphics.BitmapFactory.decodeFile(path, options)
                if (options.outWidth > 0) {
                    metadata["width"] = options.outWidth
                    metadata["height"] = options.outHeight
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
        
        return metadata
    }
    
    private fun extractVideoMetadata(path: String): Map<String, Any?> {
        val metadata = mutableMapOf<String, Any?>()
        
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(path)
            
            // Get dimensions
            val width = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH
            )?.toIntOrNull()
            val height = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT
            )?.toIntOrNull()
            
            if (width != null) metadata["width"] = width
            if (height != null) metadata["height"] = height
            
            // Get duration in milliseconds
            val duration = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_DURATION
            )?.toLongOrNull()
            if (duration != null) metadata["duration"] = duration.toInt()
            
            // Get rotation
            val rotation = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION
            )?.toIntOrNull()
            if (rotation != null) metadata["rotation"] = rotation
            
            // Get bitrate
            val bitrate = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_BITRATE
            )?.toLongOrNull()
            if (bitrate != null) metadata["bitrate"] = bitrate
            
            // Get frame rate (Android 23+)
            val frameRate = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE
            )?.toFloatOrNull()
            if (frameRate != null) metadata["frameRate"] = frameRate
            
            // Get date
            val date = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_DATE
            )
            if (date != null) metadata["date"] = date
            
            // Get location
            val location = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_LOCATION
            )
            if (location != null) metadata["location"] = location
            
            // Get MIME type
            val mimeType = retriever.extractMetadata(
                MediaMetadataRetriever.METADATA_KEY_MIMETYPE
            )
            if (mimeType != null) metadata["mimeType"] = mimeType
            
        } catch (e: Exception) {
            // Extraction failed
        } finally {
            try {
                retriever.release()
            } catch (e: Exception) {
                // Ignore
            }
        }
        
        return metadata
    }
}
