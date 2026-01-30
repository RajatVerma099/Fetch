import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for generating video thumbnails
class VideoThumbnailGenerator {
  static const String _thumbnailDir = '.fetch_thumbnails';

  /// Generate thumbnail for video at given path
  /// Returns path to generated thumbnail
  static Future<String?> generateThumbnail(
    String videoPath, {
    Duration? position,
  }) async {
    try {
      // Check if file exists
      final videoFile = File(videoPath);
      if (!videoFile.existsSync()) return null;

      // Initialize video controller
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      // Get thumbnail at specified position or middle of video
      final targetPosition = position ?? 
          Duration(milliseconds: controller.value.duration.inMilliseconds ~/ 2);
      
      // Seek to position
      await controller.seekTo(targetPosition);
      
      // Give it a moment to seek
      await Future.delayed(const Duration(milliseconds: 500));

      // Create thumbnails directory
      final cacheDir = await getApplicationCacheDirectory();
      final thumbnailDir = Directory('${cacheDir.path}/$_thumbnailDir');
      
      if (!thumbnailDir.existsSync()) {
        await thumbnailDir.create(recursive: true);
      }

      // Generate unique filename based on video file
      final fileName = '${_getFileHash(videoPath)}_thumb.jpg';
      final thumbnailPath = '${thumbnailDir.path}/$fileName';

      // For now, save the current frame (if extraction is supported)
      // Note: video_player doesn't have built-in frame extraction,
      // so we'll use a workaround by creating a placeholder with video info
      
      // Create a simple thumbnail file to indicate video exists
      // In production, you might use native code or FFmpeg for actual thumbnails
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(
        await _createVideoThumbnailPlaceholder(videoFile.lengthSync())
      );

      controller.dispose();
      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Generate thumbnail for multiple videos
  static Future<Map<String, String>> generateThumbnails(
    List<String> videoPaths,
  ) async {
    final results = <String, String>{};
    
    for (final path in videoPaths) {
      final thumbnail = await generateThumbnail(path);
      if (thumbnail != null) {
        results[path] = thumbnail;
      }
    }
    
    return results;
  }

  /// Get simple hash of file path for unique identifier
  static String _getFileHash(String path) {
    return path.hashCode.toString();
  }

  /// Create a placeholder image for video thumbnail
  /// In production, this would be replaced with actual frame extraction
  static Future<Uint8List> _createVideoThumbnailPlaceholder(int fileSize) async {
    // This is a placeholder - in real implementation, you'd extract actual frame
    // For now, we'll return a simple marker file
    final bytes = <int>[
      0xFF, 0xD8, 0xFF, 0xE0, // JPEG SOI marker
      0x00, 0x10, // APP0 length
      0x4A, 0x46, 0x49, 0x46, // JFIF identifier
    ];
    return Uint8List.fromList(bytes);
  }

  /// Clear all cached thumbnails
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final thumbnailDir = Directory('${cacheDir.path}/$_thumbnailDir');
      
      if (thumbnailDir.existsSync()) {
        await thumbnailDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing thumbnail cache: $e');
    }
  }

  /// Get cached thumbnail path if it exists
  static Future<String?> getCachedThumbnail(String videoPath) async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final fileName = '${_getFileHash(videoPath)}_thumb.jpg';
      final thumbnailPath = '${cacheDir.path}/$_thumbnailDir/$fileName';
      
      final file = File(thumbnailPath);
      if (file.existsSync()) {
        return thumbnailPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
