import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Custom video player widget with controls and preview
class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final String fileName;
  final int fileSize;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    required this.fileName,
    required this.fileSize,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller.initialize();
      
      _controller.addListener(() {
        if (!mounted) return;
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _showControls = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      String twoDigitHours = twoDigits(duration.inHours);
      return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) {
            setState(() {
              _showControls = true;
            });
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // Thumbnail overlay when paused
            if (!_isPlaying)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),

            // Controls overlay
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress slider
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Theme.of(context).colorScheme.primary,
                          bufferedColor:
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Control buttons
                      Row(
                        children: [
                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          // Time display
                          Text(
                            '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const Spacer(),
                          // Volume button
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.white),
                            onPressed: () {
                              // Volume control would go here
                            },
                          ),
                          // Fullscreen button
                          IconButton(
                            icon: const Icon(Icons.fullscreen, color: Colors.white),
                            onPressed: () {
                              // Fullscreen would go here
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // File info at top
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${(widget.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display video progress and allow scrubbing
class VideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final bool allowScrubbing;
  final VideoProgressColors colors;

  const VideoProgressIndicator(
    this.controller, {
    this.allowScrubbing = false,
    required this.colors,
    super.key,
  });

  @override
  State<VideoProgressIndicator> createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  void _seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    final Duration position = widget.controller.value.duration * relative;
    widget.controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.allowScrubbing
          ? (DragUpdateDetails details) {
              _seekToRelativePosition(details.globalPosition);
            }
          : null,
      onTapDown: widget.allowScrubbing
          ? (TapDownDetails details) {
              _seekToRelativePosition(details.globalPosition);
            }
          : null,
      child: MouseRegion(
        onEnter: widget.allowScrubbing ? (_) {} : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Center(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: widget.colors.backgroundColor,
              ),
              child: VideoProgressBar(
                controller: widget.controller,
                colors: widget.colors,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inner progress bar widget
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;

  const VideoProgressBar({
    required this.controller,
    required this.colors,
    super.key,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  _VideoProgressBarState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void updateProgress(DragUpdateDetails details) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(details.globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = widget.controller.value.duration * relative;
      widget.controller.seekTo(position);
    }

    return GestureDetector(
      onHorizontalDragUpdate: updateProgress,
      onTapDown: (TapDownDetails details) {
        final box = context.findRenderObject() as RenderBox;
        final Offset tapPos = box.globalToLocal(details.globalPosition);
        final double relative = tapPos.dx / box.size.width;
        final Duration position = widget.controller.value.duration * relative;
        widget.controller.seekTo(position);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          LinearProgressIndicator(
            value: widget.controller.value.buffered.isEmpty
                ? 0
                : widget.controller.value.buffered.last.end.inMilliseconds /
                    widget.controller.value.duration.inMilliseconds,
            minHeight: 4,
            backgroundColor: widget.colors.bufferedColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.colors.playedColor),
          ),
          LinearProgressIndicator(
            value: widget.controller.value.isInitialized
                ? widget.controller.value.position.inMilliseconds /
                    widget.controller.value.duration.inMilliseconds
                : 0,
            minHeight: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(widget.colors.playedColor),
          ),
        ],
      ),
    );
  }
}

/// Colors for video progress indicator
class VideoProgressColors {
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;

  VideoProgressColors({
    required this.playedColor,
    required this.bufferedColor,
    required this.backgroundColor,
  });
}
