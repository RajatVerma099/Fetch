import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/scanner/scanner_service.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/permission_utils.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final BuildContext context;
  
  const LoadHomeData(this.context);
  
  @override
  List<Object?> get props => [context];
}

class RefreshStorageInfo extends HomeEvent {}

class DetectSDCard extends HomeEvent {
  final BuildContext context;
  
  const DetectSDCard(this.context);
  
  @override
  List<Object?> get props => [context];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final StorageInfo storageInfo;
  final ScanSession? lastScan;
  final Map<String, int> fileStats;
  final bool sdCardDetected;
  final Map<String, dynamic>? sdCardInfo;

  const HomeLoaded({
    required this.storageInfo,
    this.lastScan,
    required this.fileStats,
    this.sdCardDetected = false,
    this.sdCardInfo,
  });

  @override
  List<Object?> get props => [storageInfo, lastScan, fileStats, sdCardDetected, sdCardInfo];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ScannerService _scannerService;
  final AppDatabase _database;

  HomeBloc({
    required ScannerService scannerService,
    required AppDatabase database,
  })  : _scannerService = scannerService,
        _database = database,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshStorageInfo>(_onRefreshStorageInfo);
    on<DetectSDCard>(_onDetectSDCard);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final storageInfo = await _scannerService.getStorageInfo();
      final lastScan = await _database.getLatestSession();
      final fileStats = await _database.getFileStats();

      emit(HomeLoaded(
        storageInfo: storageInfo,
        lastScan: lastScan,
        fileStats: fileStats,
      ));
      
      // After loading home data, detect SD card in background
      add(DetectSDCard(event.context));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onDetectSDCard(
    DetectSDCard event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      try {
        // Detect SD card and request permission if needed
        final sdCardInfo = await PermissionUtils.detectAndRequestSDCardAccess(
          event.context,
        );
        
        emit(HomeLoaded(
          storageInfo: currentState.storageInfo,
          lastScan: currentState.lastScan,
          fileStats: currentState.fileStats,
          sdCardDetected: sdCardInfo != null,
          sdCardInfo: sdCardInfo,
        ));
      } catch (e) {
        // SD card detection error is non-critical, don't change state
        debugPrint('SD card detection error: $e');
      }
    }
  }

  Future<void> _onRefreshStorageInfo(
    RefreshStorageInfo event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      try {
        final storageInfo = await _scannerService.getStorageInfo();
        emit(HomeLoaded(
          storageInfo: storageInfo,
          lastScan: currentState.lastScan,
          fileStats: currentState.fileStats,
          sdCardDetected: currentState.sdCardDetected,
          sdCardInfo: currentState.sdCardInfo,
        ));
      } catch (e) {
        // Keep current state on refresh error
      }
    }
  }
}
