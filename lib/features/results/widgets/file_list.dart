import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import 'date_scroll_indicator.dart';

class FileList extends StatefulWidget {
  final List<ScannedFile> files;
  final Function(ScannedFile) onFileTap;

  const FileList({
    super.key,
    required this.files,
    required this.onFileTap,
  });

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: widget.files.length,
          itemBuilder: (context, index) {
            final file = widget.files[index];
            return _FileListItem(
              file: file,
              onTap: () => widget.onFileTap(file),
              index: index,
            );
          },
        ),
        // Date scroll indicator
        DateScrollIndicator(
          scrollController: _scrollController,
          sortedFiles: widget.files.map((f) => ScannedFileForScroll(
            id: f.id,
            fileName: f.fileName,
            fileSize: f.fileSize,
            lastModified: f.lastModified.millisecondsSinceEpoch,
          )).toList(),
        ),
      ],
    );
  }
}

class _FileListItem extends StatelessWidget {
  final ScannedFile file;
  final VoidCallback onTap;
  final int index;

  const _FileListItem({
    required this.file,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: _buildThumbnail(context),
                ),
              ),
              const SizedBox(width: 12),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatFileSize(file.fileSize),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (file.width != null && file.height != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${file.width}×${file.height}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (file.duration != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDuration(file.duration!),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDate(file.lastModified),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (file.sourceAppHint != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              file.sourceAppHint!,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Confidence & actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getConfidenceColor(file.confidenceScore)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppTheme.getConfidenceColor(file.confidenceScore),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${file.confidenceScore}%',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getConfidenceColor(file.confidenceScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (file.isFavorite)
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 30))
        .slideX(begin: 0.05, end: 0, duration: 200.ms);
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (file.thumbnailPath != null) {
      final thumbnailFile = File(file.thumbnailPath!);
      if (thumbnailFile.existsSync()) {
        return Image.file(
          thumbnailFile,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
        );
      }
    }

    if (file.fileType == FileType.image) {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        cacheWidth: 200,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;
    Color color;

    switch (file.fileType) {
      case FileType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case FileType.video:
        icon = Icons.videocam;
        color = Colors.purple;
        break;
      case FileType.document:
        icon = Icons.description;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = colorScheme.outline;
    }

    return Container(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, color: color),
      ),
    );
  }
}
