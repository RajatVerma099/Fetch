import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../database/database.dart';
import '../utils/thumbnail_manager.dart';

/// PreviewOverlay
/// Shows a centered overlay preview of an image or video
/// Appears on long-press, disappears on release
class PreviewOverlay extends StatefulWidget {
  final ScannedFile file;
  final VoidCallback onDismiss;

  const PreviewOverlay({
    required this.file,
    required this.onDismiss,
    super.key,
  });

  @override
  State<PreviewOverlay> createState() => _PreviewOverlayState();
}

class _PreviewOverlayState extends State<PreviewOverlay> {
  late Future<Uint8List?> _imageFuture;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    print('[PreviewOverlay] Initializing preview for ${widget.file.fileName}');

    if (widget.file.fileType == FileType.image) {
      // Load higher-resolution image for preview
      _imageFuture = ThumbnailManager()
          .getThumbnail(widget.file.path, isVideo: false, width: 600);
    } else if (widget.file.fileType == FileType.video) {
      // Initialize video player
      _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    try {
      print('[PreviewOverlay] Initializing video player for ${widget.file.fileName}');
      _videoController = VideoPlayerController.file(
        File(widget.file.path),
      );

      await _videoController!.initialize();
      print('[PreviewOverlay] Video controller initialized');

      if (mounted) {
        setState(() => _videoInitialized = true);
        // Start playing automatically, muted
        _videoController!.setVolume(0.0);
        await _videoController!.play();
        print('[PreviewOverlay] Video playback started');
      }
    } catch (e, st) {
      print('[PreviewOverlay] Failed to initialize video: $e');
      print(st);
      if (mounted) {
        widget.onDismiss();
      }
    }
  }

  @override
  void dispose() {
    print('[PreviewOverlay] Disposing preview resources');
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVideo = widget.file.fileType == FileType.video;

    return GestureDetector(
      onTap: () {
        print('[PreviewOverlay] Dismissed by tap');
        widget.onDismiss();
      },
      child: Container(
        // Semi-transparent backdrop
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              // Preview container with slight shadow and rounded corners
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isVideo ? _buildVideoPreview() : _buildImagePreview(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('[PreviewOverlay] Image preview loading...');
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          print('[PreviewOverlay] Image preview loaded');
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        }

        print('[PreviewOverlay] Image preview failed to load');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildVideoPreview() {
    if (!_videoInitialized || _videoController == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        // Play icon overlay (subtle)
        const Positioned(
          bottom: 12,
          left: 12,
          child: Icon(
            Icons.play_circle,
            color: Colors.white70,
            size: 32,
          ),
        ),
      ],
    );
  }
}


