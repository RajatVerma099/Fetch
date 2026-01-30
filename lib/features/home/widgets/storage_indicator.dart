import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/scanner/scanner_service.dart';
import '../../../core/utils/formatters.dart';

class StorageIndicator extends StatelessWidget {
  final StorageInfo storageInfo;

  const StorageIndicator({super.key, required this.storageInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final usedPercentage = storageInfo.usedPercentage / 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Storage',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Stack(
                  children: [
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Used space
                    FractionallySizedBox(
                      widthFactor: usedPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                        .animate()
                        .scaleX(begin: 0, end: 1, duration: 800.ms, curve: Curves.easeOutCubic)
                        .then()
                        .shimmer(duration: 1200.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStorageStat(
                  context,
                  'Used',
                  formatFileSize(storageInfo.usedBytes),
                  colorScheme.primary,
                ),
                _buildStorageStat(
                  context,
                  'Free',
                  formatFileSize(storageInfo.freeBytes),
                  colorScheme.tertiary,
                ),
                _buildStorageStat(
                  context,
                  'Total',
                  formatFileSize(storageInfo.totalBytes),
                  colorScheme.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
