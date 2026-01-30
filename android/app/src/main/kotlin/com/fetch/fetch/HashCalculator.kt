package com.fetch.fetch

import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

/**
 * Calculate file hashes for duplicate detection
 */
object HashCalculator {
    
    /**
     * Calculate partial hash (first N bytes) for quick duplicate detection
     */
    fun calculate(path: String, bytes: Int = 4096): String? {
        val file = File(path)
        if (!file.exists() || !file.canRead()) return null
        
        return try {
            val digest = MessageDigest.getInstance("SHA-256")
            FileInputStream(file).use { fis ->
                val buffer = ByteArray(minOf(bytes, file.length().toInt()))
                val bytesRead = fis.read(buffer)
                if (bytesRead > 0) {
                    digest.update(buffer, 0, bytesRead)
                }
            }
            bytesToHex(digest.digest())
        } catch (e: Exception) {
            null
        }
    }
    
    /**
     * Calculate full file hash
     */
    fun calculateFull(path: String): String? {
        val file = File(path)
        if (!file.exists() || !file.canRead()) return null
        
        return try {
            val digest = MessageDigest.getInstance("SHA-256")
            FileInputStream(file).use { fis ->
                val buffer = ByteArray(8192)
                var bytesRead: Int
                while (fis.read(buffer).also { bytesRead = it } != -1) {
                    digest.update(buffer, 0, bytesRead)
                }
            }
            bytesToHex(digest.digest())
        } catch (e: Exception) {
            null
        }
    }
    
    private fun bytesToHex(bytes: ByteArray): String {
        val hexChars = CharArray(bytes.size * 2)
        for (i in bytes.indices) {
            val v = bytes[i].toInt() and 0xFF
            hexChars[i * 2] = HEX_CHARS[v ushr 4]
            hexChars[i * 2 + 1] = HEX_CHARS[v and 0x0F]
        }
        return String(hexChars)
    }
    
    private val HEX_CHARS = "0123456789abcdef".toCharArray()
}
