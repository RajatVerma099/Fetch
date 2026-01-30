import 'dart:async';
import 'package:flutter/services.dart';
import '../models/scanned_file.dart';

/// Service for scanning device storage using native Android filesystem traversal
/// Receives batched, categorized files from Kotlin layer
class ScannerService {
  static const MethodChannel _channel = MethodChannel('com.fetch.app/scanner');
  static const EventChannel _progressEventChannel = 
      EventChannel('com.fetch.app/scanner/progress');
  static const EventChannel _fileEventChannel = 
      EventChannel('com.fetch.app/scanner/files');
  static const List<String> defaultScanPaths = ['/storage/emulated/0'];

  // Stream controllers for events
  final StreamController<ScanProgress> _progressController =
      StreamController<ScanProgress>.broadcast();
  final StreamController<List<ScannedFile>> _fileFoundController =
      StreamController<List<ScannedFile>>.broadcast();
  final StreamController<ScanState> _stateController =
      StreamController<ScanState>.broadcast();

  Stream<ScanProgress> get progressStream => _progressController.stream;
  Stream<List<ScannedFile>> get fileFoundStream => _fileFoundController.stream;
  Stream<ScanState> get stateStream => _stateController.stream;

  bool _isScanning = false;
  bool _isPaused = false;

  bool get isScanning => _isScanning;
  bool get isPaused => _isPaused;

  /// Start comprehensive filesystem scan
  Future<void> startScan({List<String>? paths}) async {
    if (_isScanning) return;

    print('[ScannerService] ====== SCAN LIFECYCLE START ======');
    print('[ScannerService] [INIT] startScan() called');

    _isScanning = true;
    _isPaused = false;
    _stateController.add(ScanState.initializing);

    final scanPaths = paths ?? ['/storage/emulated/0'];

    try {
      // CRITICAL: Set up method call handler BEFORE starting native scan
      // This prevents race condition where completion fires before handler is registered
      print('[ScannerService] [INIT] Setting up method call handler...');
      _channel.setMethodCallHandler(_handleMethodCall);
      print('[ScannerService] [INIT] Method call handler registered');

      // Listen to progress stream
      print('[ScannerService] [INIT] Setting up progress stream listener...');
      _progressEventChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is Map) {
            _progressController.add(ScanProgress.fromMap(
              Map<String, dynamic>.from(data as Map),
            ));
          }
        },
        onError: (error) => print('[ScannerService] [ERROR] Progress stream error: $error'),
      );

      // Listen to file batches stream
      print('[ScannerService] [INIT] Setting up file stream listener...');
      _fileEventChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is Map) {
            final map = Map<String, dynamic>.from(data);
            final files = (map['files'] as List<dynamic>?)
                ?.map((f) => ScannedFile.fromMap(
                    Map<String, dynamic>.from(f as Map)))
                .toList() ?? [];
            
            if (files.isNotEmpty) {
              print('[ScannerService] [BATCH] Received batch with ${files.length} files (category: ${map['category']}, batch: ${map['batch']})');
              _fileFoundController.add(files);
            }
          }
        },
        onError: (error) => print('[ScannerService] [ERROR] File stream error: $error'),
      );

      // Start native scan
      print('[ScannerService] [SCANNING] Invoking native startScan() method...');
      await _channel.invokeMethod('startScan', {'paths': scanPaths});
      print('[ScannerService] [SCANNING] Native startScan() returned to Flutter');
    } catch (e) {
      print('[ScannerService] [ERROR] ====== SCAN FAILED ====== ');
      print('[ScannerService] [ERROR] Exception: $e');
      _stateController.add(ScanState.error);
      _isScanning = false;
      rethrow;
    }
  }

  /// Pause scanning
  Future<void> pauseScan() async {
    if (!_isScanning || _isPaused) return;
    _isPaused = true;
    _stateController.add(ScanState.paused);
    try {
      await _channel.invokeMethod('pauseScan');
    } catch (e) {
      _isPaused = false;
      rethrow;
    }
  }

  /// Resume scanning
  Future<void> resumeScan() async {
    if (!_isScanning || !_isPaused) return;
    _isPaused = false;
    _stateController.add(ScanState.scanning);
    try {
      await _channel.invokeMethod('resumeScan');
    } catch (e) {
      _isPaused = true;
      rethrow;
    }
  }

  /// Cancel scanning
  Future<void> cancelScan() async {
    if (!_isScanning) return;
    _stateController.add(ScanState.cancelled);
    try {
      await _channel.invokeMethod('cancelScan');
    } finally {
      _isScanning = false;
      _isPaused = false;
    }
  }

  /// Handle method calls from native
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('[ScannerService] [NATIVE_CALLBACK] Native method call received: ${call.method}');
    print('[ScannerService] [NATIVE_CALLBACK] Arguments type: ${call.arguments.runtimeType}');
    switch (call.method) {
      case 'onStateChanged':
        final stateName = (call.arguments as Map)['state'] as String;
        print('[ScannerService] [STATE] Native state changed to: $stateName');
        final newState = _parseScanState(stateName);
        _stateController.add(newState);
        break;
      case 'onScanCompleted':
        print('[ScannerService] [COMPLETE] ====== onScanCompleted RECEIVED ======');
        final data = call.arguments as Map?;
        print('[ScannerService] [COMPLETE] Total files found: ${data?['totalFilesFound']}');
        print('[ScannerService] [COMPLETE] Total bytes scanned: ${data?['totalBytesScanned']}');
        print('[ScannerService] [COMPLETE] Categories summary: ${data?['categoriesSummary']}');

        _isScanning = false;
        print('[ScannerService] [COMPLETE] Setting _isScanning = false');
        print('[ScannerService] [COMPLETE] Emitting ScanState.completed event');
        _stateController.add(ScanState.completed);
        print('[ScannerService] [COMPLETE] State emitted successfully');

        print('[ScannerService] [COMPLETE] ====== LIFECYCLE COMPLETE ======');
        break;

      // Backwards compatible handler (in case older native emits this name)
      case 'onScanComplete':
        print('[ScannerService] [COMPLETE] onScanComplete RECEIVED (legacy)');
        final legacy = call.arguments as Map?;
        print('[ScannerService] [COMPLETE] Total files found (legacy): ${legacy?['totalFiles']}');
        _isScanning = false;
        _stateController.add(ScanState.completed);
        break;
      case 'onError':
        print('[ScannerService] [ERROR] Native error received: ${call.arguments}');
        _stateController.add(ScanState.error);
        _isScanning = false;
        break;
      default:
        print('[ScannerService] [NATIVE_CALLBACK] Unknown method: ${call.method}');
    }
  }

  ScanState _parseScanState(String stateName) {
    switch (stateName.toUpperCase()) {
      case 'IDLE':
        return ScanState.idle;
      case 'INITIALIZING':
        return ScanState.initializing;
      case 'SCANNING':
        return ScanState.scanning;
      case 'FINALIZING':
        return ScanState.finalizing;
      case 'COMPLETED':
        return ScanState.completed;
      case 'ERROR':
        return ScanState.error;
      default:
        return ScanState.scanning;
    }
  }

  /// Get storage info
  Future<StorageInfo> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod('getStorageInfo');
      return StorageInfo.fromMap(Map<String, dynamic>.from(result ?? {}));
    } catch (e) {
      return StorageInfo(totalBytes: 0, usedBytes: 0, freeBytes: 0);
    }
  }

  /// Generate thumbnail for file
  Future<String?> generateThumbnail(String filePath) async {
    try {
      final result = await _channel.invokeMethod('generateThumbnail', 
          {'path': filePath});
      return result as String?;
    } catch (e) {
      return null;
    }
  }

  /// Extract metadata
  Future<Map<String, dynamic>?> extractMetadata(String filePath) async {
    try {
      final result = await _channel.invokeMethod('extractMetadata',
          {'path': filePath});
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _progressController.close();
    _fileFoundController.close();
    _stateController.close();
  }
}

/// Scan state
enum ScanState { idle, initializing, scanning, finalizing, completed, paused, cancelled, error }

/// Scan progress data
class ScanProgress {
  final int filesScanned;
  final int bytesScanned;
  final int totalStorageBytes;
  final int imagesFound;
  final int videosFound;
  final int documentsFound;
  final int audioFound;
  final int archivesFound;
  final int applicationsFound;
  final int databasesFound;
  final int codesFound;
  final int othersFound;
  final double progress;
  final String currentPath;
  final double? estimatedProgress;

  ScanProgress({
    required this.filesScanned,
    this.bytesScanned = 0,
    this.totalStorageBytes = 0,
    required this.imagesFound,
    required this.videosFound,
    required this.documentsFound,
    required this.audioFound,
    this.archivesFound = 0,
    this.applicationsFound = 0,
    this.databasesFound = 0,
    this.codesFound = 0,
    required this.othersFound,
    this.progress = 0.0,
    this.currentPath = '',
    this.estimatedProgress,
  });

  factory ScanProgress.fromMap(Map<String, dynamic> map) {
    return ScanProgress(
      filesScanned: map['filesScanned'] as int? ?? 0,
      bytesScanned: map['bytesScanned'] as int? ?? 0,
      totalStorageBytes: map['totalStorageBytes'] as int? ?? 0,
      imagesFound: map['imagesFound'] as int? ?? 0,
      videosFound: map['videosFound'] as int? ?? 0,
      documentsFound: map['documentsFound'] as int? ?? 0,
      audioFound: map['audioFound'] as int? ?? 0,
      archivesFound: map['archivesFound'] as int? ?? 0,
      applicationsFound: map['applicationsFound'] as int? ?? 0,
      databasesFound: map['databasesFound'] as int? ?? 0,
      codesFound: map['codesFound'] as int? ?? 0,
      othersFound: map['othersFound'] as int? ?? 0,
      progress: (map['progress'] as num? ?? 0.0).toDouble(),
      currentPath: map['currentPath'] as String? ?? '',
      estimatedProgress: map['estimatedProgress'] != null ? (map['estimatedProgress'] as num).toDouble() : null,
    );
  }

  int get totalFound =>
      imagesFound + videosFound + documentsFound + audioFound + 
      archivesFound + applicationsFound + databasesFound + codesFound + othersFound;
}

/// Storage info
class StorageInfo {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;

  StorageInfo({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
  });

  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    return StorageInfo(
      totalBytes: (map['totalBytes'] as num? ?? 0).toInt(),
      usedBytes: (map['usedBytes'] as num? ?? 0).toInt(),
      freeBytes: (map['freeBytes'] as num? ?? 0).toInt(),
    );
  }

  double get usedPercentage =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;
}
