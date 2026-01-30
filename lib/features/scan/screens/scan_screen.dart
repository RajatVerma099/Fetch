import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../bloc/scan_bloc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/scan_stats.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/permission_utils.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Real progress from native layer
  double _displayProgress = 0.0;
  double _targetProgress = 0.0;
  
  // Smooth animation controller for progress transitions
  Timer? _progressAnimationTimer;
  
  // Safety timeout for the "FINALIZING" state
  Timer? _finalizingSafetyTimer;
  
  int _totalFilesFound = 0;
  int _bytesScanned = 0;
  int _totalStorageBytes = 0;

  @override
  void initState() {
    super.initState();
    
    // Request permissions and start scan when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool hasPermission = await PermissionUtils.hasStoragePermissions();
      
      if (!hasPermission && mounted) {
        hasPermission = await PermissionUtils.requestStoragePermissions(context);
      }

      // On Android 11+, we strongly recommend All Files Access for recovery
      if (hasPermission && mounted) {
        // This will check if already granted, or show a dialog explaining why it's needed for recovery
        await PermissionUtils.requestAllFilesAccess(context);
      }
      
      if (!hasPermission && mounted) {
        // Permissions denied - show error and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permissions are required to scan your device'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
        return;
      }
      
      // Permissions granted, start the scan
      if (mounted) {
        context.read<ScanBloc>().add(const StartScan());
      }
    });
  }

  /// Smooth real progress updates with animation
  void _updateProgress(double newProgress) {
    _targetProgress = newProgress;
    
    // Start smooth animation from current to target
    _progressAnimationTimer?.cancel();
    _progressAnimationTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) return;
      
      setState(() {
        if ((_displayProgress - _targetProgress).abs() < 0.5) {
          _displayProgress = _targetProgress;
          _progressAnimationTimer?.cancel();
        } else {
          // Animate 20% of the remaining gap per frame
          _displayProgress += (_targetProgress - _displayProgress) * 0.2;
        }
      });
    });
  }

  /// Complete the progress animation - force to 100% with animation
  void _completeProgress() {
    _progressAnimationTimer?.cancel();
    
    // Animate from current to 100% over 600ms
    int frameCount = 0;
    const totalFrames = 20;
    const frameDuration = Duration(milliseconds: 30);
    
    _progressAnimationTimer = Timer.periodic(frameDuration, (_) {
      if (!mounted) {
        _progressAnimationTimer?.cancel();
        return;
      }
      
      frameCount++;
      setState(() {
        _displayProgress = _displayProgress + (100.0 - _displayProgress) * 0.15;
        
        if (frameCount >= totalFrames || _displayProgress >= 99.9) {
          _displayProgress = 100.0;
          _progressAnimationTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _progressAnimationTimer?.cancel();
    _finalizingSafetyTimer?.cancel();
    super.dispose();
  }

  void _startFinalizingSafetyTimer() {
    _finalizingSafetyTimer?.cancel();
    _finalizingSafetyTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      print('[ScanScreen] [SAFETY] Finalizing state timed out! Forcing navigation to results.');
      _completeProgress();
      context.go('/results');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning Storage'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(context),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<ScanBloc, ScanBlocState>(
        listener: (context, state) {
          if (state is ScanCompleted) {
            print('[ScanScreen] [COMPLETE] ScanCompleted received. Navigating to results.');
            _finalizingSafetyTimer?.cancel();
            _completeProgress();
            
            // Immediate navigation as requested
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) context.go('/results');
            });
          } else if (state is ScanCancelled) {
            _progressAnimationTimer?.cancel();
            context.pop();
          } else if (state is ScanError) {
            _progressAnimationTimer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ScanInProgress) {
            // Check for finalizing state to start safety timer
            if (_targetProgress >= 99.0) {
              _startFinalizingSafetyTimer();
            }
            
            // Update real metrics from native layer
            setState(() {
              _totalFilesFound = state.progress.totalFound;
              _bytesScanned = state.progress.bytesScanned;
              _totalStorageBytes = state.progress.totalStorageBytes;
              // Update display progress based on byte-based calculation from native layer
              _updateProgress(state.progress.estimatedProgress ?? state.progress.progress);
            });
          }
        },
        builder: (context, state) {
          if (state is ScanInProgress) {
            return _buildScanningUI(context, state);
          } else if (state is ScanCompleted) {
            return _buildCompletedUI(context, state);
          } else if (state is ScanError) {
            return _buildErrorUI(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _getStatusText(ScanInProgress state) {
    // Determine status text based on native metrics or state
    if (_displayProgress >= 99.9) return 'Finishing up...';
    if (_targetProgress > 90) return 'Almost done...';
    
    // Check if we can get the specific sub-state from the bloc if we wanted to
    // But for now, we'll use progress-based status
    return 'Scanning files...';
  }

  Widget _buildScanningUI(BuildContext context, ScanInProgress state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Progress Ring
                  ProgressRing(
                    progress: _displayProgress,
                    filesScanned: _totalFilesFound,
                    bytesScanned: _bytesScanned,
                    totalStorageBytes: _totalStorageBytes,
                    isPaused: state.isPaused,
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 24),

                  // Scanning status text
                  Text(
                    _getStatusText(state),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  // Files and storage info
                  Text(
                    _totalStorageBytes > 0
                        ? 'Scanning ${((_bytesScanned / (1024.0 * 1024.0 * 1024.0)).toStringAsFixed(1))} GB / ${((_totalStorageBytes / (1024.0 * 1024.0 * 1024.0)).toStringAsFixed(1))} GB'
                        : 'Files found: $_totalFilesFound',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Current path indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.progress.currentPath,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats
                  ScanStats(
                    imagesFound: state.progress.imagesFound,
                    videosFound: state.progress.videosFound,
                    documentsFound: state.progress.documentsFound,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // Time elapsed
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTimeItem(
                            context,
                            'Elapsed',
                            formatDuration(state.elapsed.inMilliseconds),
                            Icons.timer_outlined,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: colorScheme.outlineVariant,
                          ),
                          _buildTimeItem(
                            context,
                            'Files Scanned',
                            state.progress.filesScanned.toString(),
                            Icons.description_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: state.isPaused
                      ? ElevatedButton.icon(
                          onPressed: () {
                            context.read<ScanBloc>().add(ResumeScan());
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Resume'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            context.read<ScanBloc>().add(PauseScan());
                          },
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildCompletedUI(BuildContext context, ScanCompleted state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successColor,
              ),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            Text(
              'Scan Complete!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '${state.totalFound} files found in ${formatDuration(state.duration.inMilliseconds)}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 40),

            ScanStats(
              imagesFound: state.imagesFound,
              videosFound: state.videosFound,
              documentsFound: state.documentsFound,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () => context.go('/results'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('View Results'),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI(BuildContext context, ScanError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Scan Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Scan?'),
        content: const Text(
          'Progress will be saved and you can view partial results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Scanning'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScanBloc>().add(CancelScan());
            },
            child: Text(
              'Cancel Scan',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, ScanCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan Complete! ✓'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Found ${state.totalFound} files',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                color: Theme.of(ctx).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.image, color: Colors.blue, size: 28),
                    const SizedBox(height: 8),
                    Text('${state.imagesFound}'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.videocam, color: Colors.purple, size: 28),
                    const SizedBox(height: 8),
                    Text('${state.videosFound}'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.description, color: Colors.orange, size: 28),
                    const SizedBox(height: 8),
                    Text('${state.documentsFound}'),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/results');
            },
            child: const Text('View Results'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
