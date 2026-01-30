import 'dart:async';

/// PreviewManager
/// - Controls preview lifecycle (start/cancel/release)
/// - Pauses background thumbnail generation during preview
/// - Handles resource priorities
class PreviewManager {
  PreviewManager._internal();

  static final PreviewManager _instance = PreviewManager._internal();
  factory PreviewManager() => _instance;

  bool _isPreviewActive = false;
  StreamController<bool>? _previewStateController;

  /// Check if preview is currently active
  bool get isPreviewActive => _isPreviewActive;

  /// Stream of preview state changes (true = active, false = inactive)
  Stream<bool> get previewStateStream {
    _previewStateController ??= StreamController<bool>.broadcast();
    return _previewStateController!.stream;
  }

  /// Called when a preview starts (long-press down)
  /// Pauses background thumbnail generation
  void startPreview() {
    print('[PreviewManager] Preview started - pausing background work');
    _isPreviewActive = true;
    _previewStateController?.add(true);
  }

  /// Called when a preview is cancelled (finger moved away, scroll started)
  /// Resumes background thumbnail generation
  void cancelPreview() {
    print('[PreviewManager] Preview cancelled - resuming background work');
    _isPreviewActive = false;
    _previewStateController?.add(false);
  }

  /// Called when a preview is released (finger lifted)
  /// Ensures cleanup and resumes background work
  void releasePreview() {
    print('[PreviewManager] Preview released - resuming background work');
    _isPreviewActive = false;
    _previewStateController?.add(false);
  }

  /// Dispose resources
  void dispose() {
    _previewStateController?.close();
    _previewStateController = null;
  }
}
