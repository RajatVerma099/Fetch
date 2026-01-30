import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../results/bloc/results_bloc.dart';
import '../widgets/video_player_widget.dart';

class PreviewScreen extends StatefulWidget {
  final int fileId;

  const PreviewScreen({super.key, required this.fileId});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  ScannedFile? _file;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final database = context.read<AppDatabase>();
    final files = await database.getAllFiles();
    final file = files.firstWhere(
      (f) => f.id == widget.fileId,
      orElse: () => throw Exception('File not found'),
    );
    setState(() {
      _file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_file == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final file = _file!;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              file.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: file.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => _toggleFavorite(file),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                _showInfo = !_showInfo;
              });
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Preview content
          _buildPreview(file),

          // Info panel
          if (_showInfo)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildInfoPanel(file),
            ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(context, file),
    );
  }

  Widget _buildPreview(ScannedFile file) {
    final fileObj = File(file.path);

    if (!fileObj.existsSync()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'File not found',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (file.fileType == FileType.image) {
      return PhotoView(
        imageProvider: FileImage(fileObj),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event?.expectedTotalBytes != null
                ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                : null,
          ),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
        ),
      );
    }

    if (file.fileType == FileType.video) {
      return VideoPlayerWidget(
        videoPath: file.path,
        fileName: file.fileName,
        fileSize: file.fileSize,
      );
    }

    // For documents, show a preview with file info
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            file.fileName,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            formatFileSize(file.fileSize),
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _restoreFile(file),
            icon: const Icon(Icons.download),
            label: const Text('Restore Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(ScannedFile file) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // File name
          Text(
            file.fileName,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Confidence score
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getConfidenceColor(file.confidenceScore)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppTheme.getConfidenceColor(file.confidenceScore),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${file.confidenceScore}% Confidence',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getConfidenceColor(file.confidenceScore),
                      ),
                    ),
                  ],
                ),
              ),
              if (file.sourceAppHint != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    file.sourceAppHint!,
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Details grid
          _buildInfoRow('Size', formatFileSize(file.fileSize)),
          if (file.width != null && file.height != null)
            _buildInfoRow('Resolution', '${file.width} × ${file.height}'),
          if (file.duration != null)
            _buildInfoRow('Duration', formatDuration(file.duration!)),
          _buildInfoRow('Modified', formatDateTime(file.lastModified)),
          _buildInfoRow('Type', file.mimeType),
          _buildInfoRow('Path', file.path, isPath: true),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoRow(String label, String value, {bool isPath = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
              maxLines: isPath ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, ScannedFile file) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.save_alt,
            label: 'Restore',
            onTap: () => _restoreFile(file),
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () => _shareFile(file),
          ),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: colorScheme.error,
            onTap: () => _deleteFile(file),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: buttonColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(ScannedFile file) {
    context.read<ResultsBloc>().add(ToggleFavorite(file.id, !file.isFavorite));
    setState(() {
      _file = ScannedFile(
        id: file.id,
        path: file.path,
        fileName: file.fileName,
        fileSize: file.fileSize,
        mimeType: file.mimeType,
        fileType: file.fileType,
        width: file.width,
        height: file.height,
        duration: file.duration,
        lastModified: file.lastModified,
        sourceAppHint: file.sourceAppHint,
        confidenceScore: file.confidenceScore,
        thumbnailPath: file.thumbnailPath,
        isFavorite: !file.isFavorite,
        fileHash: file.fileHash,
        scannedAt: file.scannedAt,
      );
    });
  }

  Future<void> _restoreFile(ScannedFile file) async {
    // For now, we'll just show a confirmation dialog
    // In a real app, you would implement actual file restoration logic
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore File'),
        content: Text('Restore ${file.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('File restoration feature coming soon');
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile(ScannedFile file) async {
    try {
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      _showSnackBar('Failed to share file', isError: true);
    }
  }

  Future<void> _deleteFile(ScannedFile file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from results?'),
        content: const Text(
          'This will remove the file from scan results. '
          'The actual file will not be deleted from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ResultsBloc>().add(DeleteFile(file.id));
      if (mounted) context.pop();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
  }
}
