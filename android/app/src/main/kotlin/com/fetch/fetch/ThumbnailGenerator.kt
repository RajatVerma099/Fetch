package com.fetch.fetch

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.media.ThumbnailUtils
import android.os.Build
import android.util.Size
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

/**
 * Generate thumbnails for media files
 */
object ThumbnailGenerator {
    private const val THUMBNAIL_QUALITY = 80
    
    
    fun generate(context: Context, path: String, mimeType: String, size: Int = 256): String? {
        val file = File(path)
        if (!file.exists()) return null
        
        return try {
            val bitmap = when {
                mimeType.startsWith("image/") -> generateImageThumbnail(path, size)
                mimeType.startsWith("video/") -> generateVideoThumbnail(path, size)
                else -> null
            }
            
            bitmap?.let { saveThumbnail(context, it) }
        } catch (e: Exception) {
            null
        }
    }
    
    private fun generateImageThumbnail(path: String, targetSize: Int): Bitmap? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ThumbnailUtils.createImageThumbnail(
                    File(path),
                    Size(targetSize, targetSize),
                    null
                )
            } else {
                // For older Android versions - Use sample size for large images
                val options = android.graphics.BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                android.graphics.BitmapFactory.decodeFile(path, options)
                
                options.inSampleSize = calculateSampleSize(
                    options.outWidth, 
                    options.outHeight, 
                    targetSize, 
                    targetSize
                )
                
                options.inJustDecodeBounds = false
                val bitmap = android.graphics.BitmapFactory.decodeFile(path, options)
                bitmap?.let {
                    Bitmap.createScaledBitmap(it, targetSize, targetSize, true)
                }
            }
        } catch (e: Exception) {
            null
        }
    }
    
    private fun generateVideoThumbnail(path: String, targetSize: Int): Bitmap? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ThumbnailUtils.createVideoThumbnail(
                    File(path),
                    Size(targetSize, targetSize),
                    null
                )
            } else {
                val retriever = MediaMetadataRetriever()
                try {
                    retriever.setDataSource(path)
                    val frame = retriever.getFrameAtTime(
                        1000000, // 1 second
                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                    )
                    frame?.let {
                        Bitmap.createScaledBitmap(it, targetSize, targetSize, true)
                    }
                } finally {
                    retriever.release()
                }
            }
        } catch (e: Exception) {
            null
        }
    }
    
    // ... Rest of the helper methods remain the same ...
    private fun calculateSampleSize(actualWidth: Int, actualHeight: Int, reqWidth: Int, reqHeight: Int): Int {
        var sampleSize = 1
        if (actualHeight > reqHeight || actualWidth > reqWidth) {
            val halfHeight = actualHeight / 2
            val halfWidth = actualWidth / 2
            while ((halfHeight / sampleSize) >= reqHeight && (halfWidth / sampleSize) >= reqWidth) {
                sampleSize *= 2
            }
        }
        return sampleSize
    }
    
    private fun saveThumbnail(context: Context, bitmap: Bitmap): String {
        val thumbnailDir = File(context.cacheDir, "thumbnails")
        if (!thumbnailDir.exists()) thumbnailDir.mkdirs()
        
        val thumbnailFile = File(thumbnailDir, "${UUID.randomUUID()}.jpg")
        FileOutputStream(thumbnailFile).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, THUMBNAIL_QUALITY, out)
        }
        return thumbnailFile.absolutePath
    }
}
