package com.fetch.fetch

import java.io.File
import java.io.FileInputStream

/**
 * File signature detection using magic bytes
 */
object SignatureDetector {
    
    // Image signatures
    private val JPEG = byteArrayOf(0xFF.toByte(), 0xD8.toByte(), 0xFF.toByte())
    private val PNG = byteArrayOf(0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
    private val GIF87A = "GIF87a".toByteArray()
    private val GIF89A = "GIF89a".toByteArray()
    private val WEBP_PREFIX = "RIFF".toByteArray()
    private val WEBP_SUFFIX = "WEBP".toByteArray()
    private val BMP = byteArrayOf(0x42, 0x4D)
    private val TIFF_LE = byteArrayOf(0x49.toByte(), 0x49, 0x2A, 0x00)  // Little-endian TIFF
    private val TIFF_BE = byteArrayOf(0x4D, 0x4D, 0x00, 0x2A)  // Big-endian TIFF
    private val ICO = byteArrayOf(0x00, 0x00, 0x01, 0x00)  // ICO icon file
    
    // Video signatures
    private val FTYP = "ftyp".toByteArray()
    private val RIFF = "RIFF".toByteArray()
    private val AVI = "AVI ".toByteArray()
    private val MATROSKA = byteArrayOf(0x1A, 0x45, 0xDF.toByte(), 0xA3.toByte())
    private val FLV = byteArrayOf(0x46, 0x4C, 0x56)  // FLV
    
    // Document signatures
    private val PDF = "%PDF".toByteArray()
    private val ZIP = byteArrayOf(0x50, 0x4B, 0x03, 0x04)
    private val ZIP_EMPTY = byteArrayOf(0x50, 0x4B, 0x05, 0x06)
    private val RAR = byteArrayOf(0x52, 0x61, 0x72, 0x21, 0x1A, 0x07)
    private val SEVEN_ZIP = byteArrayOf(0x37, 0x7A, 0xBC.toByte(), 0xAF.toByte(), 0x27, 0x1C)
    private val DOCX = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP but contains specific structure
    private val DOC = byteArrayOf(0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte())
    private val XLS = byteArrayOf(0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte())
    private val XLSX = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP
    private val PPT = byteArrayOf(0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte())
    private val PPTX = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP
    private val ODP = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP
    private val ODS = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP
    private val ODT = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // Same as ZIP
    private val XLSX_MARKER = "[Content_Types].xml".toByteArray()
    private val DOCX_MARKER = "word/".toByteArray()
    private val PPTX_MARKER = "ppt/".toByteArray()
    
    // Audio signatures
    private val MP3_ID3 = "ID3".toByteArray()
    private val MP3_SYNC = byteArrayOf(0xFF.toByte(), 0xFB.toByte())
    private val FLAC = "fLaC".toByteArray()
    private val OGG = "OggS".toByteArray()
    private val WAV = "RIFF".toByteArray()  // Followed by WAVE
    
    /**
     * Read file header bytes
     */
    fun readHeader(file: File, bytes: Int = 32): ByteArray {
        if (!file.exists() || !file.canRead()) return ByteArray(0)
        
        return try {
            FileInputStream(file).use { fis ->
                val buffer = ByteArray(minOf(bytes, file.length().toInt()))
                fis.read(buffer)
                buffer
            }
        } catch (e: Exception) {
            ByteArray(0)
        }
    }
    
    /**
     * Detect file type from header bytes
     */
    fun detectType(header: ByteArray, fileSize: Long): FileTypeResult? {
        if (header.isEmpty()) return null
        
        // Images
        if (matchesSignature(header, JPEG)) {
            return FileTypeResult("image/jpeg", "jpg", "image")
        }
        if (matchesSignature(header, PNG)) {
            return FileTypeResult("image/png", "png", "image")
        }
        if (matchesSignature(header, GIF87A) || matchesSignature(header, GIF89A)) {
            return FileTypeResult("image/gif", "gif", "image")
        }
        if (matchesSignature(header, BMP)) {
            return FileTypeResult("image/bmp", "bmp", "image")
        }
        if (matchesSignature(header, TIFF_LE) || matchesSignature(header, TIFF_BE)) {
            return FileTypeResult("image/tiff", "tiff", "image")
        }
        if (matchesSignature(header, ICO)) {
            return FileTypeResult("image/x-icon", "ico", "image")
        }
        if (matchesSignature(header, WEBP_PREFIX) && header.size >= 12) {
            if (matchesSignature(header, WEBP_SUFFIX, 8)) {
                return FileTypeResult("image/webp", "webp", "image")
            }
        }
        
        // Videos - check for ftyp box at offset 4
        if (header.size >= 12 && matchesSignature(header, FTYP, 4)) {
            val brand = String(header.sliceArray(8..11))
            
            // HEIC/HEIF images
            if (brand.contains("heic", ignoreCase = true) || 
                brand.contains("mif1", ignoreCase = true) ||
                brand.contains("heif", ignoreCase = true)) {
                return FileTypeResult("image/heic", "heic", "image")
            }
            
            // MP4 variants
            if (brand.contains("isom", ignoreCase = true) ||
                brand.contains("mp4", ignoreCase = true) ||
                brand.contains("M4V", ignoreCase = true) ||
                brand.contains("avc", ignoreCase = true)) {
                return FileTypeResult("video/mp4", "mp4", "video")
            }
            
            // QuickTime MOV
            if (brand.contains("qt", ignoreCase = true)) {
                return FileTypeResult("video/quicktime", "mov", "video")
            }
            
            // 3GP
            if (brand.contains("3gp", ignoreCase = true) ||
                brand.contains("3g2", ignoreCase = true)) {
                return FileTypeResult("video/3gpp", "3gp", "video")
            }
            
            // Default to MP4
            return FileTypeResult("video/mp4", "mp4", "video")
        }
        
        // AVI
        if (matchesSignature(header, RIFF) && header.size >= 12) {
            if (matchesSignature(header, AVI, 8)) {
                return FileTypeResult("video/x-msvideo", "avi", "video")
            }
        }
        
        // MKV/WebM
        if (matchesSignature(header, MATROSKA)) {
            return FileTypeResult("video/x-matroska", "mkv", "video")
        }
        
        // FLV
        if (matchesSignature(header, FLV)) {
            return FileTypeResult("video/x-flv", "flv", "video")
        }
        
        // Documents
        if (matchesSignature(header, PDF)) {
            return FileTypeResult("application/pdf", "pdf", "document")
        }
        
        // Office documents (OLE format: Word, Excel, PowerPoint 97-2003)
        if (matchesSignature(header, DOC)) {
            // Check further into file to determine exact type
            if (header.size >= 2080) {
                val subheader = String(header.sliceArray(512..600), Charsets.ISO_8859_1)
                when {
                    subheader.contains("Mirrorled Database", ignoreCase = true) -> 
                        return FileTypeResult("application/x-mdb", "mdb", "document")
                    subheader.contains("WordDocument", ignoreCase = true) -> 
                        return FileTypeResult("application/msword", "doc", "document")
                    subheader.contains("Workbook", ignoreCase = true) -> 
                        return FileTypeResult("application/vnd.ms-excel", "xls", "document")
                    subheader.contains("PowerPoint", ignoreCase = true) -> 
                        return FileTypeResult("application/vnd.ms-powerpoint", "ppt", "document")
                }
            }
            return FileTypeResult("application/octet-stream", "ole", "document")
        }
        
        // Office Open XML formats (DOCX, XLSX, PPTX - all ZIP-based)
        if (matchesSignature(header, ZIP) || matchesSignature(header, ZIP_EMPTY)) {
            // Try to identify Office Open XML by checking content
            // These files contain specific directories/files
            if (header.size >= 100) {
                val headerStr = String(header, Charsets.ISO_8859_1)
                when {
                    headerStr.contains("word/") || headerStr.contains("_rels/") -> 
                        return FileTypeResult("application/vnd.openxmlformats-officedocument.wordprocessingml.document", "docx", "document")
                    headerStr.contains("xl/") || headerStr.contains("worksheets/") -> 
                        return FileTypeResult("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "xlsx", "document")
                    headerStr.contains("ppt/") || headerStr.contains("slides/") -> 
                        return FileTypeResult("application/vnd.openxmlformats-officedocument.presentationml.presentation", "pptx", "document")
                    headerStr.contains("META-INF") || headerStr.contains("content.xml") -> 
                        return FileTypeResult("application/vnd.oasis.opendocument.text", "odt", "document")
                    headerStr.contains("META-INF") && headerStr.contains("Configurations") ->
                        return FileTypeResult("application/vnd.oasis.opendocument.spreadsheet", "ods", "document")
                    headerStr.contains("META-INF") && headerStr.contains("Presentations") ->
                        return FileTypeResult("application/vnd.oasis.opendocument.presentation", "odp", "document")
                }
            }
            return FileTypeResult("application/zip", "zip", "document")
        }
        
        if (matchesSignature(header, RAR)) {
            return FileTypeResult("application/x-rar-compressed", "rar", "document")
        }
        if (matchesSignature(header, SEVEN_ZIP)) {
            return FileTypeResult("application/x-7z-compressed", "7z", "document")
        }
        
        // Audio
        if (matchesSignature(header, MP3_ID3) || matchesSignature(header, MP3_SYNC)) {
            return FileTypeResult("audio/mpeg", "mp3", "audio")
        }
        if (matchesSignature(header, WAV) && header.size >= 12) {
            if (matchesSignature(header, "WAVE".toByteArray(), 8)) {
                return FileTypeResult("audio/wav", "wav", "audio")
            }
        }
        if (matchesSignature(header, FLAC)) {
            return FileTypeResult("audio/flac", "flac", "audio")
        }
        if (matchesSignature(header, OGG)) {
            return FileTypeResult("audio/ogg", "ogg", "audio")
        }
        
        return null
    }
    
    private fun matchesSignature(data: ByteArray, signature: ByteArray, offset: Int = 0): Boolean {
        if (data.size < offset + signature.size) return false
        for (i in signature.indices) {
            if (data[offset + i] != signature[i]) return false
        }
        return true
    }
}

/**
 * File type detection result
 */
data class FileTypeResult(
    val mimeType: String,
    val extension: String,
    val category: String // "image", "video", "audio", "document"
)
