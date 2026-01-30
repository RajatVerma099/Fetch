import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final int filesScanned;
  final int bytesScanned;
  final int totalStorageBytes;
  final bool isPaused;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.filesScanned,
    required this.bytesScanned,
    required this.totalStorageBytes,
    required this.isPaused,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _rotationController.stop();
    } else {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.0),
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Background ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Progress ring
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _ProgressPainter(
                progress: widget.progress,
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isPaused)
                Icon(
                  Icons.pause_circle_filled,
                  size: 32,
                  color: colorScheme.primary,
                )
              else
                Icon(
                  Icons.search,
                  size: 32,
                  color: colorScheme.primary,
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 600.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                    ),
              const SizedBox(height: 8),
              Text(
                '${widget.progress.toStringAsFixed(1)}%',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                widget.totalStorageBytes > 0
                    ? '${(widget.bytesScanned / (1024.0 * 1024.0)).toStringAsFixed(0)} MB / ${((widget.totalStorageBytes / (1024.0 * 1024.0 * 1024.0)).toStringAsFixed(1))} GB'
                    : '${widget.filesScanned} files',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (widget.isPaused)
                Text(
                  'Paused',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.tertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          colors: [color.withValues(alpha: 0.5), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -math.pi / 2,
        2 * math.pi * (progress / 100),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
