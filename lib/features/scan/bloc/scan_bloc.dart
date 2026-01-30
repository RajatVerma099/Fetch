import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/scanner/scanner_service.dart';
import '../../../core/models/scanned_file.dart' as scanned_file_model;
import '../../../core/database/database.dart';
import 'package:drift/drift.dart';

// Events
abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends ScanEvent {
  final List<String>? paths;
  const StartScan({this.paths});
}

class PauseScan extends ScanEvent {}

class ResumeScan extends ScanEvent {}

class CancelScan extends ScanEvent {}

class _ScanProgressUpdated extends ScanEvent {
  final ScanProgress progress;
  const _ScanProgressUpdated(this.progress);
}

class _ScanStateChanged extends ScanEvent {
  final ScanState scanState;
  const _ScanStateChanged(this.scanState);
}

class _FileFound extends ScanEvent {
  final scanned_file_model.ScannedFile file;
  const _FileFound(this.file);
}

// States
abstract class ScanBlocState extends Equatable {
  const ScanBlocState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanBlocState {}

class ScanInProgress extends ScanBlocState {
  final ScanProgress progress;
  final bool isPaused;
  final DateTime startTime;
  final int currentSessionId;

  const ScanInProgress({
    required this.progress,
    required this.isPaused,
    required this.startTime,
    required this.currentSessionId,
  });

  Duration get elapsed => DateTime.now().difference(startTime);

  @override
  List<Object?> get props => [progress, isPaused, startTime, currentSessionId];
}

class ScanCompleted extends ScanBlocState {
  final int imagesFound;
  final int videosFound;
  final int documentsFound;
  final int audioFound;
  final int archivesFound;
  final int applicationsFound;
  final int databasesFound;
  final int codesFound;
  final int othersFound;
  final int totalBytesScanned;
  final Duration duration;

  const ScanCompleted({
    required this.imagesFound,
    required this.videosFound,
    required this.documentsFound,
    required this.audioFound,
    required this.archivesFound,
    required this.applicationsFound,
    required this.databasesFound,
    required this.codesFound,
    required this.othersFound,
    required this.totalBytesScanned,
    required this.duration,
  });

  int get totalFound => imagesFound + videosFound + documentsFound + audioFound + 
                        archivesFound + applicationsFound + databasesFound + 
                        codesFound + othersFound;

  @override
  List<Object?> get props => [
    imagesFound, videosFound, documentsFound, audioFound, archivesFound,
    applicationsFound, databasesFound, codesFound, othersFound, 
    totalBytesScanned, duration
  ];
}

class ScanCancelled extends ScanBlocState {
  final int filesFound;

  const ScanCancelled({required this.filesFound});

  @override
  List<Object?> get props => [filesFound];
}

class ScanError extends ScanBlocState {
  final String message;

  const ScanError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ScanBloc extends Bloc<ScanEvent, ScanBlocState> {
  final ScannerService _scannerService;
  final AppDatabase _database;

  StreamSubscription<ScanProgress>? _progressSubscription;
  StreamSubscription<ScanState>? _stateSubscription;
  StreamSubscription<List<scanned_file_model.ScannedFile>>? _fileSubscription;

  DateTime? _startTime;
  int? _currentSessionId;
  Timer? _completionTimeoutTimer;
  double _lastProgressValue = 0.0;

  ScanBloc({
    required ScannerService scannerService,
    required AppDatabase database,
  })  : _scannerService = scannerService,
        _database = database,
        super(ScanInitial()) {
    on<StartScan>(_onStartScan);
    on<PauseScan>(_onPauseScan);
    on<ResumeScan>(_onResumeScan);
    on<CancelScan>(_onCancelScan);
    on<_ScanProgressUpdated>(_onProgressUpdated);
    on<_ScanStateChanged>(_onStateChanged);
    on<_FileFound>(_onFileFound);
  }

  Future<void> _onStartScan(StartScan event, Emitter<ScanBlocState> emit) async {
    try {
      _startTime = DateTime.now();

      // Create scan session
      _currentSessionId = await _database.createSession(
        ScanSessionsCompanion.insert(
          startedAt: _startTime!,
          status: 'running',
          scannedPaths: (event.paths ?? ScannerService.defaultScanPaths).join(','),
        ),
      );

      // Subscribe to streams
      _progressSubscription = _scannerService.progressStream.listen(
        (progress) => add(_ScanProgressUpdated(progress)),
      );

      _stateSubscription = _scannerService.stateStream.listen(
        (scanState) => add(_ScanStateChanged(scanState)),
      );

      _fileSubscription = _scannerService.fileFoundStream.listen(
        (files) {
          for (var file in files) {
            add(_FileFound(file));
          }
        },
      );

      // Emit initial state
      emit(ScanInProgress(
        progress: ScanProgress(
          filesScanned: 0,
          imagesFound: 0,
          videosFound: 0,
          documentsFound: 0,
          audioFound: 0,
          othersFound: 0,
          currentPath: 'Starting...',
        ),
        isPaused: false,
        startTime: _startTime!,
        currentSessionId: _currentSessionId!,
      ));

      // Start scanning
      await _scannerService.startScan(paths: event.paths);
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onPauseScan(PauseScan event, Emitter<ScanBlocState> emit) async {
    if (state is ScanInProgress) {
      await _scannerService.pauseScan();
      final current = state as ScanInProgress;
      emit(ScanInProgress(
        progress: current.progress,
        isPaused: true,
        startTime: current.startTime,
        currentSessionId: current.currentSessionId,
      ));

      // Update session
      await _database.updateSession(
        current.currentSessionId,
        const ScanSessionsCompanion(status: Value('paused')),
      );
    }
  }

  Future<void> _onResumeScan(ResumeScan event, Emitter<ScanBlocState> emit) async {
    if (state is ScanInProgress) {
      await _scannerService.resumeScan();
      final current = state as ScanInProgress;
      emit(ScanInProgress(
        progress: current.progress,
        isPaused: false,
        startTime: current.startTime,
        currentSessionId: current.currentSessionId,
      ));

      // Update session
      await _database.updateSession(
        current.currentSessionId,
        const ScanSessionsCompanion(status: Value('scanning')),
      );
    }
  }

  Future<void> _onCancelScan(CancelScan event, Emitter<ScanBlocState> emit) async {
    if (state is ScanInProgress) {
      final current = state as ScanInProgress;
      await _scannerService.cancelScan();

      // Update session
      await _database.updateSession(
        current.currentSessionId,
        ScanSessionsCompanion(
          status: const Value('cancelled'),
          completedAt: Value(DateTime.now()),
        ),
      );

      emit(ScanCancelled(filesFound: current.progress.totalFound));
    }
  }

  void _onProgressUpdated(_ScanProgressUpdated event, Emitter<ScanBlocState> emit) {
    if (state is ScanInProgress) {
      final current = state as ScanInProgress;
      final newProgress = event.progress;
      
      // Calculate estimated progress based on files scanned
      double calculatedProgress = 0.0;
      if (newProgress.filesScanned > 0) {
        final totalFound = newProgress.totalFound;
        calculatedProgress = (totalFound.toDouble() / newProgress.filesScanned) * 100.0;
      }
      
      final progress = ScanProgress(
        filesScanned: newProgress.filesScanned,
        imagesFound: newProgress.imagesFound,
        videosFound: newProgress.videosFound,
        documentsFound: newProgress.documentsFound,
        audioFound: newProgress.audioFound,
        othersFound: newProgress.othersFound,
        currentPath: newProgress.currentPath,
        estimatedProgress: (newProgress.estimatedProgress ?? calculatedProgress).clamp(0.0, 100.0),
      );
      
      final finalProgress = progress.estimatedProgress ?? 0.0;
      
      _lastProgressValue = finalProgress;
      
      emit(ScanInProgress(
        progress: progress,
        isPaused: current.isPaused,
        startTime: current.startTime,
        currentSessionId: current.currentSessionId,
      ));
    }
  }

  Future<void> _onStateChanged(_ScanStateChanged event, Emitter<ScanBlocState> emit) async {
    if (event.scanState == ScanState.completed && state is ScanInProgress) {
      final current = state as ScanInProgress;
      
      print('[ScanBloc] [COMPLETE] ScanState.completed received from native signal');
      print('[ScanBloc] [COMPLETE] Files found - Images: ${current.progress.imagesFound}, Videos: ${current.progress.videosFound}, Docs: ${current.progress.documentsFound}');
      
      _completionTimeoutTimer?.cancel();

      // Update session with all file type counts
      await _database.updateSession(
        current.currentSessionId,
        ScanSessionsCompanion(
          status: const Value('completed'),
          completedAt: Value(DateTime.now()),
          imagesFound: Value(current.progress.imagesFound),
          videosFound: Value(current.progress.videosFound),
          documentsFound: Value(current.progress.documentsFound),
          totalFilesScanned: Value(current.progress.filesScanned),
        ),
      );

      print('[ScanBloc] [COMPLETE] Emitting ScanCompleted state');
      emit(ScanCompleted(
        imagesFound: current.progress.imagesFound,
        videosFound: current.progress.videosFound,
        documentsFound: current.progress.documentsFound,
        audioFound: current.progress.audioFound,
        archivesFound: current.progress.archivesFound,
        applicationsFound: current.progress.applicationsFound,
        databasesFound: current.progress.databasesFound,
        codesFound: current.progress.codesFound,
        othersFound: current.progress.othersFound,
        totalBytesScanned: current.progress.bytesScanned,
        duration: current.elapsed,
      ));
      
      print('[ScanBloc] [COMPLETE] ====== SCAN COMPLETED STATE EMITTED ======');
    } else if (event.scanState == ScanState.scanning && state is ScanInProgress) {
      final current = state as ScanInProgress;
      if (current.isPaused) {
        emit(ScanInProgress(
          progress: current.progress,
          isPaused: false,
          startTime: current.startTime,
          currentSessionId: current.currentSessionId,
        ));
      }
    } else if (event.scanState == ScanState.error) {
      print('[ScanBloc] [ERROR] ScanState.error received');
      emit(const ScanError('An error occurred during scanning'));
    }
  }

  Future<void> _onFileFound(_FileFound event, Emitter<ScanBlocState> emit) async {
    // Store file in database
    try {
      final fileType = _getFileType(event.file.category);
      
      print('[ScanBloc] [FILE] Storing file: ${event.file.name} (${event.file.category} -> $fileType)');
      await _database.insertFile(ScannedFilesCompanion.insert(
        path: event.file.path,
        fileName: event.file.name,
        fileSize: event.file.size,
        mimeType: event.file.mimeType,
        fileType: fileType,
        lastModified: DateTime.fromMillisecondsSinceEpoch(event.file.lastModified),
        confidenceScore: 100,
        scannedAt: DateTime.now(),
        thumbnailPath: Value(event.file.thumbnailPath),
      ));
    } catch (e) {
      // Log error for debugging but don't stop the scan
      print('[ScanBloc] [FILE] ERROR storing file: $e');
    }
  }

  FileType _getFileType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      case 'document':
        return FileType.document;
      case 'archive':
        return FileType.archive;
      case 'application':
        return FileType.application;
      case 'database':
        return FileType.database;
      case 'code':
        return FileType.code;
      default:
        return FileType.other;
    }
  }

  @override
  Future<void> close() {
    _completionTimeoutTimer?.cancel();
    _progressSubscription?.cancel();
    _stateSubscription?.cancel();
    _fileSubscription?.cancel();
    return super.close();
  }
}
