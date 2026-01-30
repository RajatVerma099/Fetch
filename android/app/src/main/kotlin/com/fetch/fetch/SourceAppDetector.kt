package com.fetch.fetch

/**
 * Detect source app based on file path patterns
 */
object SourceAppDetector {
    
    private val appPatterns = mapOf(
        // Social media
        "whatsapp" to "WhatsApp",
        "telegram" to "Telegram",
        "instagram" to "Instagram",
        "facebook" to "Facebook",
        "twitter" to "Twitter/X",
        "snapchat" to "Snapchat",
        "tiktok" to "TikTok",
        
        // Messaging
        "viber" to "Viber",
        "signal" to "Signal",
        "discord" to "Discord",
        "line" to "LINE",
        "wechat" to "WeChat",
        
        // Media & Entertainment
        "spotify" to "Spotify",
        "youtube" to "YouTube",
        "netflix" to "Netflix",
        "amazonprime" to "Prime Video",
        "vlc" to "VLC",
        
        // Camera & Gallery
        "dcim" to "Camera",
        "camera" to "Camera",
        "screenshot" to "Screenshots",
        "screen_recording" to "Screen Recording",
        
        // Browsers
        "chrome" to "Chrome",
        "firefox" to "Firefox",
        "opera" to "Opera",
        "brave" to "Brave",
        "edge" to "Edge",
        "samsung" to "Samsung Internet",
        
        // Office & Productivity
        "download" to "Downloads",
        "documents" to "Documents",
        "gdocs" to "Google Docs",
        "drive" to "Google Drive",
        "dropbox" to "Dropbox",
        "onedrive" to "OneDrive",
        
        // Photo editing
        "snapseed" to "Snapseed",
        "lightroom" to "Lightroom",
        "vsco" to "VSCO",
        "picsart" to "PicsArt",
        
        // Video apps
        "inshot" to "InShot",
        "capcut" to "CapCut",
        "kinemaster" to "KineMaster"
    )
    
    fun detect(path: String): String? {
        val lowerPath = path.lowercase()
        
        for ((pattern, appName) in appPatterns) {
            if (lowerPath.contains(pattern)) {
                return appName
            }
        }
        
        // Check for package name patterns
        val packagePattern = Regex("/com\\.([^/]+)\\.[^/]+/")
        val match = packagePattern.find(lowerPath)
        if (match != null) {
            val packagePart = match.groupValues[1]
            // Capitalize first letter
            return packagePart.replaceFirstChar { it.uppercase() }
        }
        
        return null
    }
}
