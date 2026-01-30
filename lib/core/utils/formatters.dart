import 'package:intl/intl.dart';

/// Format file size in human-readable format
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// Format duration in human-readable format
String formatDuration(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m ${seconds}s';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}

/// Format date in human-readable format
String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    return DateFormat('MMM d, yyyy').format(date);
  }
}

/// Format date and time
String formatDateTime(DateTime date) {
  return DateFormat('MMM d, yyyy • h:mm a').format(date);
}

/// Format resolution
String formatResolution(int? width, int? height) {
  if (width == null || height == null) return 'Unknown';
  return '${width}x$height';
}

/// Format confidence score
String formatConfidence(int score) {
  if (score >= 90) return 'Excellent';
  if (score >= 75) return 'High';
  if (score >= 50) return 'Medium';
  if (score >= 25) return 'Low';
  return 'Very Low';
}

/// Get file extension from path
String getFileExtension(String path) {
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1) return '';
  return path.substring(lastDot + 1).toLowerCase();
}

/// Get file name from path
String getFileName(String path) {
  final lastSeparator = path.lastIndexOf(RegExp(r'[/\\]'));
  if (lastSeparator == -1) return path;
  return path.substring(lastSeparator + 1);
}

/// Get parent directory from path
String getParentDirectory(String path) {
  final lastSeparator = path.lastIndexOf(RegExp(r'[/\\]'));
  if (lastSeparator == -1) return '';
  return path.substring(0, lastSeparator);
}

/// Estimate source app from path
String? estimateSourceApp(String path) {
  final lowerPath = path.toLowerCase();

  // Social media apps
  if (lowerPath.contains('whatsapp')) return 'WhatsApp';
  if (lowerPath.contains('telegram')) return 'Telegram';
  if (lowerPath.contains('instagram')) return 'Instagram';
  if (lowerPath.contains('facebook') || lowerPath.contains('fb')) return 'Facebook';
  if (lowerPath.contains('twitter') || lowerPath.contains('x.com')) return 'Twitter/X';
  if (lowerPath.contains('snapchat')) return 'Snapchat';
  if (lowerPath.contains('tiktok')) return 'TikTok';

  // Media apps
  if (lowerPath.contains('spotify')) return 'Spotify';
  if (lowerPath.contains('youtube')) return 'YouTube';
  if (lowerPath.contains('netflix')) return 'Netflix';

  // Camera & Gallery
  if (lowerPath.contains('dcim') || lowerPath.contains('camera')) return 'Camera';
  if (lowerPath.contains('screenshot')) return 'Screenshots';

  // Office & Productivity
  if (lowerPath.contains('gdocs') || lowerPath.contains('google docs')) return 'Google Docs';
  if (lowerPath.contains('download')) return 'Downloads';

  // Messaging
  if (lowerPath.contains('viber')) return 'Viber';
  if (lowerPath.contains('signal')) return 'Signal';
  if (lowerPath.contains('discord')) return 'Discord';

  // Browsers
  if (lowerPath.contains('chrome')) return 'Chrome';
  if (lowerPath.contains('firefox')) return 'Firefox';
  if (lowerPath.contains('opera')) return 'Opera';
  if (lowerPath.contains('brave')) return 'Brave';

  return null;
}

/// Get MIME type icon name
String getMimeTypeIcon(String mimeType) {
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType.startsWith('video/')) return 'video_file';
  if (mimeType.startsWith('audio/')) return 'audio_file';
  if (mimeType.contains('pdf')) return 'picture_as_pdf';
  if (mimeType.contains('word') || mimeType.contains('doc')) return 'description';
  if (mimeType.contains('excel') || mimeType.contains('sheet')) return 'table_chart';
  if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
    return 'slideshow';
  }
  if (mimeType.contains('zip') || mimeType.contains('rar') || mimeType.contains('7z')) {
    return 'folder_zip';
  }
  if (mimeType.contains('text')) return 'text_snippet';
  return 'insert_drive_file';
}
