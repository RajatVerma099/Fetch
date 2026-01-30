import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';

class FileGrid extends StatelessWidget {
  final List<ScannedFile> files;
  final Function(ScannedFile) onFileTap;

  const FileGrid({
    super.key,
    required this.files,
    required this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileGridItem(
          file: file,
          onTap: () => onFileTap(file),
          index: index,
        );
      },
    );
  }
}

class _FileGridItem extends StatelessWidget {
  final ScannedFile file;
  final VoidCallback onTap;
  final int index;

  const _FileGridItem({
    required this.file,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showPreview(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail or placeholder
            _buildThumbnail(context),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // File info
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getConfidenceColor(file.confidenceScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${file.confidenceScore}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // File size
                  Text(
                    formatFileSize(file.fileSize),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Video duration badge
            if (file.duration != null)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        formatDuration(file.duration!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Favorite indicator
            if (file.isFavorite)
              const Positioned(
                top: 6,
                left: 6,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 16,
                ),
              ),

            // Long-tap hint for videos
            if (file.fileType == FileType.video)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Tap & hold',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: (index % 20) * 30))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreviewContent(context),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    if (file.fileType == FileType.image) {
      return Image.file(
        File(file.path),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorPreview(),
      );
    } else if (file.fileType == FileType.video) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to play video',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );
    }
    return _buildErrorPreview();
  }

  Widget _buildErrorPreview() {
    return Center(
      child: Icon(
        Icons.broken_image,
        color: Colors.white54,
        size: 64,
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Try to load thumbnail
    if (file.thumbnailPath != null) {
      final thumbnailFile = File(file.thumbnailPath!);
      if (thumbnailFile.existsSync()) {
        return _buildThumbnailWithOverlay(
          Image.file(
            thumbnailFile,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(context),
          ),
          context,
        );
      }
    }

    // Try to load actual file for images
    if (file.fileType == FileType.image) {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        cacheWidth: 300,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    // For videos, show a video placeholder with play icon
    if (file.fileType == FileType.video) {
      return _buildVideoPlaceholder(context);
    }

    return _buildPlaceholder(context);
  }

  Widget _buildThumbnailWithOverlay(Widget thumbnail, BuildContext context) {
    if (file.fileType == FileType.video) {
      return Stack(
        fit: StackFit.expand,
        children: [
          thumbnail,
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      );
    }
    return thumbnail;
  }

  Widget _buildVideoPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          // Play icon in center
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;

    switch (file.fileType) {
      case FileType.image:
        icon = Icons.image;
        break;
      case FileType.video:
        icon = Icons.videocam;
        break;
      case FileType.audio:
        icon = Icons.music_note;
        break;
      case FileType.document:
        icon = Icons.description;
        break;
      case FileType.archive:
        icon = Icons.folder_zip;
        break;
      case FileType.application:
        icon = Icons.app_shortcut;
        break;
      case FileType.database:
        icon = Icons.storage;
        break;
      case FileType.code:
        icon = Icons.code;
        break;
      case FileType.other:
        icon = Icons.insert_drive_file;
        break;
    }

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          icon,
          size: 32,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
