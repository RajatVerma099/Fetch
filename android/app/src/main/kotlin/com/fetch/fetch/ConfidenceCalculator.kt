package com.fetch.fetch

/**
 * Calculate confidence score for detected files
 */
object ConfidenceCalculator {
    
    // Minimum file sizes for validation
    private val minimumSizes = mapOf(
        "image/jpeg" to 1024L,
        "image/png" to 67L,
        "image/gif" to 35L,
        "image/webp" to 30L,
        "image/heic" to 1024L,
        "video/mp4" to 4096L,
        "video/quicktime" to 4096L,
        "video/x-msvideo" to 4096L,
        "video/x-matroska" to 1024L,
        "video/3gpp" to 1024L,
        "application/pdf" to 1024L,
        "application/zip" to 22L
    )
    
    /**
     * Calculate confidence score (0-100)
     */
    fun calculate(
        header: ByteArray,
        fileSize: Long,
        mimeType: String,
        path: String,
        hasMetadata: Boolean
    ): Int {
        var score = 0
        
        // Header validation (max 40 points)
        score += calculateHeaderScore(header, mimeType)
        
        // File size validation (max 25 points)
        score += calculateSizeScore(fileSize, mimeType)
        
        // Metadata completeness (max 20 points)
        score += calculateMetadataScore(hasMetadata, mimeType)
        
        // Path-based bonus (max 15 points)
        score += calculatePathScore(path)
        
        return score.coerceIn(0, 100)
    }
    
    private fun calculateHeaderScore(header: ByteArray, mimeType: String): Int {
        if (header.isEmpty()) return 0
        
        // If we detected a valid type from header, it's a good sign
        val detected = SignatureDetector.detectType(header, 0)
        
        if (detected == null) return 5 // Has bytes but unknown type
        
        if (detected.mimeType == mimeType) {
            return 40 // Perfect match
        }
        
        // Category match
        val detectedCategory = detected.category
        val mimeCategory = mimeType.substringBefore('/')
        if (detectedCategory == mimeCategory) {
            return 30 // Same category
        }
        
        return 20 // At least it's a valid file
    }
    
    private fun calculateSizeScore(fileSize: Long, mimeType: String): Int {
        val minSize = minimumSizes[mimeType] ?: 1024L
        
        return when {
            fileSize >= minSize * 10 -> 25 // Well above minimum
            fileSize >= minSize * 2 -> 20 // Comfortable size
            fileSize >= minSize -> 15 // Meets minimum
            fileSize > 0 -> 5 // Below minimum but not empty
            else -> 0
        }
    }
    
    private fun calculateMetadataScore(hasMetadata: Boolean, mimeType: String): Int {
        val isMedia = mimeType.startsWith("image/") || mimeType.startsWith("video/")
        
        return when {
            hasMetadata && isMedia -> 20
            hasMetadata -> 15
            !isMedia -> 10 // Non-media files don't need metadata
            else -> 5
        }
    }
    
    private fun calculatePathScore(path: String): Int {
        val lowerPath = path.lowercase()
        var bonus = 0
        
        // Standard media directories (positive)
        if (lowerPath.contains("/dcim/")) bonus += 5
        if (lowerPath.contains("/pictures/")) bonus += 5
        if (lowerPath.contains("/camera/")) bonus += 5
        if (lowerPath.contains("/screenshots/")) bonus += 5
        if (lowerPath.contains("/download/")) bonus += 3
        
        // Lower confidence paths (negative)
        if (lowerPath.contains("/.thumbnails/")) bonus -= 5
        if (lowerPath.contains("/cache/")) bonus -= 3
        if (lowerPath.contains("/temp/")) bonus -= 5
        if (lowerPath.contains("/tmp/")) bonus -= 5
        
        // Hidden directories (except .thumbnails)
        if (lowerPath.contains("/.") && !lowerPath.contains("/.thumbnails")) {
            bonus -= 3
        }
        
        return (bonus + 10).coerceIn(0, 15) // Base of 10, range 0-15
    }
}
