import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling storage permissions
class PermissionUtils {
  static const platform = MethodChannel('com.fetch.app/storage');
  
  /// Request storage permissions for scanning
  static Future<bool> requestStoragePermissions(BuildContext context) async {
    // For Android 13+, we need granular media permissions
    if (Platform.isAndroid) {
      // Check Android version
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();

      final allGranted = statuses.values.every(
        (status) => status.isGranted || status.isLimited,
      );

      if (allGranted) {
        return true;
      }

      // Fallback to legacy storage permission for older Android
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // If still not granted, try manage external storage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Show explanation dialog
      if (context.mounted) {
        return await _showPermissionDialog(context);
      }
    }

    return false;
  }

  /// Check if we have necessary permissions
  static Future<bool> hasStoragePermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      // Fallback for Android 13+ media permissions
      if (await Permission.photos.isGranted && await Permission.videos.isGranted) {
        return true;
      }

      // Legacy permission
      return await Permission.storage.isGranted;
    }
    return true;
  }

  /// Explicitly request All Files Access (MANAGE_EXTERNAL_STORAGE)
  /// This is required for recovery and accessing restricted areas on Android 11+
  static Future<bool> requestAllFilesAccess(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    if (context.mounted) {
      return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('All Files Access Required'),
          content: const Text(
            'To recover files and scan protected system folders, Fetch needs "All Files Access" permission.\n\n'
            'Please find "Fetch" in the next screen and toggle it ON.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx, true);
                await openAppSettings(); // Or use ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION via MethodChannel if needed
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ) ?? false;
    }
    return false;
  }

  /// Detect external SD card and request permission if found
  static Future<Map<String, dynamic>?> detectAndRequestSDCardAccess(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      // Check if SD card is present
      final result = await platform.invokeMethod<Map>('detectExternalSD');
      
      if (result == null) {
        return null;
      }

      final sdCardInfo = Map<String, dynamic>.from(result);
      final found = sdCardInfo['found'] as bool? ?? false;

      if (!found) {
        return null; // No SD card found
      }

      if (context.mounted) {
        // Show dialog asking for permission
        final userAllowsSDCard = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.sd_card, size: 48),
            title: const Text('External SD Card Detected'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fetch found an external SD card on your device.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Would you like to also scan the SD card for media files?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Text(
                  'If you allow this, Storage Access Framework will be used to securely access the card.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Scan Internal Only'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Scan SD Card Too'),
              ),
            ],
          ),
        ) ?? false;

        if (userAllowsSDCard) {
          // Request SAF permission for external SD card
          await requestSAFPermission(context);
          return sdCardInfo;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error detecting SD card: $e');
      return null;
    }
  }

  /// Request Storage Access Framework (SAF) permission
  static Future<bool> requestSAFPermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      // Request MANAGE_EXTERNAL_STORAGE permission for Android 11+
      final result = await Permission.manageExternalStorage.request();
      
      if (result.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SD card permission granted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      }

      // For older Android versions, the permission might be implicitly granted
      if (result.isDenied) {
        if (context.mounted) {
          await _showSAFPermissionDialog(context);
        }
      }

      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting SAF permission: $e');
      return false;
    }
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.folder_open, size: 48),
        title: const Text('Storage Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fetch needs access to your device storage to scan for media files.',
            ),
            SizedBox(height: 16),
            Text(
              'We only read files locally. Nothing is uploaded.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show SAF permission explanation dialog
  static Future<void> _showSAFPermissionDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.sd_card, size: 48),
        title: const Text('SD Card Access Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To scan the external SD card, Fetch needs permission to access removable storage.',
            ),
            SizedBox(height: 16),
            Text(
              'This is a system permission required for full storage access.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show rationale for denied permissions
  static Future<void> showDeniedPermissionSnackbar(
    BuildContext context,
    ScaffoldMessengerState messenger,
  ) async {
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Storage permission is required to scan for files.',
        ),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
