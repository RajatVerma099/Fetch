import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/formatters.dart';

class LastScanCard extends StatelessWidget {
  final ScanSession session;

  const LastScanCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalFound =
        session.imagesFound + session.videosFound + session.documentsFound;

    return Card(
      child: InkWell(
        onTap: () => context.push('/results'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Last Scan',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(session.status, colorScheme),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(session.status),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    context,
                    Icons.image_outlined,
                    session.imagesFound.toString(),
                    'Images',
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    Icons.videocam_outlined,
                    session.videosFound.toString(),
                    'Videos',
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    Icons.description_outlined,
                    session.documentsFound.toString(),
                    'Docs',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatDate(session.startedAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$totalFound files found',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'running':
        return colorScheme.primary;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return colorScheme.outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'running':
        return 'Running';
      case 'paused':
        return 'Paused';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
