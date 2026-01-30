import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, int> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.image_outlined,
          label: 'Images',
          count: stats['images'] ?? 0,
          color: Colors.blue,
          delay: 0,
        ),
        _StatCard(
          icon: Icons.videocam_outlined,
          label: 'Videos',
          count: stats['videos'] ?? 0,
          color: Colors.purple,
          delay: 50,
        ),
        _StatCard(
          icon: Icons.description_outlined,
          label: 'Documents',
          count: stats['documents'] ?? 0,
          color: Colors.orange,
          delay: 100,
        ),
        _StatCard(
          icon: Icons.favorite_outlined,
          label: 'Favorites',
          count: stats['favorites'] ?? 0,
          color: Colors.pink,
          delay: 150,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to filtered results
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCount(count),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
