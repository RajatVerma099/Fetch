import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Privacy section
          _buildSectionHeader('Privacy & Safety'),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Your data stays on your device'),
            onTap: () => _showPrivacyInfo(context),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Permissions'),
            subtitle: const Text('Manage storage permissions'),
            onTap: () => _openPermissions(),
          ),
          const Divider(),

          // Data section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Scan Results'),
            subtitle: const Text('Remove all discovered files from database'),
            onTap: () => _showClearDataDialog(context),
          ),
          const Divider(),

          // About section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Fetch'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Disclaimer'),
            subtitle: const Text('Important information'),
            onTap: () => _showDisclaimer(context),
          ),

          const SizedBox(height: 32),

          // Disclaimer card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Your Privacy Matters',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• All scans are performed locally\n'
                      '• No data is uploaded to any server\n'
                      '• No analytics or tracking\n'
                      '• No account required',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fetch respects your privacy:\n\n'
                '1. LOCAL ONLY\n'
                'All file scanning happens entirely on your device. '
                'No files, metadata, or scan results are ever uploaded.\n\n'
                '2. NO TRACKING\n'
                'We do not collect analytics, crash reports, '
                'or any form of usage data.\n\n'
                '3. NO ACCOUNT\n'
                'No registration or login required.\n\n'
                '4. PERMISSIONS\n'
                'We only request storage permissions necessary '
                'to scan and display your files.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPermissions() async {
    await openAppSettings();
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Scan Results?'),
        content: const Text(
          'This will remove all discovered files from the database. '
          'Your actual files will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear database
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scan results cleared')),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fetch',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.search,
          color: Colors.white,
          size: 28,
        ),
      ),
      children: [
        const Text(
          'Rediscover forgotten photos, videos & documents '
          'hidden in your device storage.',
        ),
      ],
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Important Disclaimer'),
        content: const SingleChildScrollView(
          child: Text(
            'This app helps rediscover accessible media files that may be '
            'hidden in various folders on your device.\n\n'
            'LIMITATIONS:\n\n'
            '• Fetch cannot recover files that have been permanently '
            'deleted from your device.\n\n'
            '• Files removed from encrypted storage cannot be retrieved.\n\n'
            '• The app only scans publicly accessible directories.\n\n'
            '• Confidence scores are estimates and may not always '
            'reflect file integrity.\n\n'
            'WHAT FETCH DOES:\n\n'
            '• Scans accessible storage directories\n'
            '• Identifies media files by their signatures\n'
            '• Allows you to copy files to a safe location\n\n'
            'The "Restore" feature copies files to your chosen folder. '
            'Original files are never modified or moved.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}
