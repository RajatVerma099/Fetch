import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanStats extends StatelessWidget {
  final int imagesFound;
  final int videosFound;
  final int documentsFound;

  const ScanStats({
    super.key,
    required this.imagesFound,
    required this.videosFound,
    required this.documentsFound,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.image_outlined,
          count: imagesFound,
          label: 'Images',
          color: Colors.blue,
          delay: 0,
        ),
        _StatItem(
          icon: Icons.videocam_outlined,
          count: videosFound,
          label: 'Videos',
          color: Colors.purple,
          delay: 100,
        ),
        _StatItem(
          icon: Icons.description_outlined,
          count: documentsFound,
          label: 'Documents',
          color: Colors.orange,
          delay: 200,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final int delay;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          )
              .animate(
                key: ValueKey(count),
                onPlay: (c) => c.forward(from: 0),
              )
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1, 1),
                duration: 200.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0);
  }
}
