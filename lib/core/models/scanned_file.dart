/// Enumeration of file categories
enum FileCategory {
  image,
  video,
  audio,
  document,
  archive,
  app,
  database,
  code,
  other,
}

/// Model for a scanned file with metadata
class ScannedFile {
  final String path;
  final String name;
  final int size;
  final String extension;
  final String category;
  final String mimeType;
  final int lastModified;
  final bool isHidden;
  final String? thumbnailPath;

  ScannedFile({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
    required this.category,
    required this.mimeType,
    required this.lastModified,
    this.isHidden = false,
    this.thumbnailPath,
  });

  /// Parse from native Android map
  factory ScannedFile.fromMap(Map<String, dynamic> map) {
    return ScannedFile(
      path: map['path'] as String? ?? '',
      name: map['name'] as String? ?? '',
      size: map['size'] as int? ?? 0,
      extension: map['extension'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      mimeType: map['mimeType'] as String? ?? 'application/octet-stream',
      lastModified: map['lastModified'] as int? ?? 0,
      isHidden: map['isHidden'] as bool? ?? false,
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() => {
        'path': path,
        'name': name,
        'size': size,
        'extension': extension,
        'category': category,
        'mimeType': mimeType,
        'lastModified': lastModified,
        'isHidden': isHidden,
        'thumbnailPath': thumbnailPath,
      };

  /// Check if file is an image
  bool get isImage => category == 'image';

  /// Check if file is a video
  bool get isVideo => category == 'video';

  /// Check if file is audio
  bool get isAudio => category == 'audio';

  /// Check if file is a document
  bool get isDocument => category == 'document';

  /// Format file size as human-readable string
  String get sizeFormatted {
    const units = ['B', 'KB', 'MB', 'GB'];
    var bytes = size.toDouble();
    var unitIndex = 0;

    while (bytes >= 1024 && unitIndex < units.length - 1) {
      bytes /= 1024;
      unitIndex++;
    }

    return '${bytes.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Get display name
  String get displayName => name.isEmpty ? 'Unknown' : name;

  @override
  String toString() =>
      'ScannedFile(path=$path, name=$name, size=$size, category=$category)';
}
