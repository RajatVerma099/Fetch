import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/database.dart';

// Events
abstract class ResultsEvent extends Equatable {
  const ResultsEvent();

  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  final FileType? filterType;
  const LoadResults({this.filterType});

  @override
  List<Object?> get props => [filterType];
}

class ApplyFilter extends ResultsEvent {
  final ResultsFilter filter;
  const ApplyFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ToggleFavorite extends ResultsEvent {
  final int fileId;
  final bool isFavorite;
  const ToggleFavorite(this.fileId, this.isFavorite);

  @override
  List<Object?> get props => [fileId, isFavorite];
}

class DeleteFile extends ResultsEvent {
  final int fileId;
  const DeleteFile(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

// Filter model
class ResultsFilter extends Equatable {
  final FileType? fileType;
  final int? minSize;
  final int? maxSize;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minConfidence;
  final String? sourceApp;
  final bool showDuplicatesOnly;
  final SortOption sortBy;

  const ResultsFilter({
    this.fileType,
    this.minSize,
    this.maxSize,
    this.startDate,
    this.endDate,
    this.minConfidence,
    this.sourceApp,
    this.showDuplicatesOnly = false,
    this.sortBy = SortOption.dateDesc,
  });

  ResultsFilter copyWith({
    FileType? fileType,
    int? minSize,
    int? maxSize,
    DateTime? startDate,
    DateTime? endDate,
    int? minConfidence,
    String? sourceApp,
    bool? showDuplicatesOnly,
    SortOption? sortBy,
  }) {
    return ResultsFilter(
      fileType: fileType ?? this.fileType,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minConfidence: minConfidence ?? this.minConfidence,
      sourceApp: sourceApp ?? this.sourceApp,
      showDuplicatesOnly: showDuplicatesOnly ?? this.showDuplicatesOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        fileType,
        minSize,
        maxSize,
        startDate,
        endDate,
        minConfidence,
        sourceApp,
        showDuplicatesOnly,
        sortBy,
      ];
}

enum SortOption {
  dateDesc,
  dateAsc,
  sizeDesc,
  sizeAsc,
  confidenceDesc,
  nameAsc,
}

// States
abstract class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {}

class ResultsLoading extends ResultsState {}

class ResultsLoaded extends ResultsState {
  final List<ScannedFile> allFiles;
  final List<ScannedFile> images;
  final List<ScannedFile> videos;
  final List<ScannedFile> audio;
  final List<ScannedFile> documents;
  final List<ScannedFile> archives;
  final List<ScannedFile> applications;
  final List<ScannedFile> bestMatches;
  final ResultsFilter filter;

  const ResultsLoaded({
    required this.allFiles,
    required this.images,
    required this.videos,
    required this.audio,
    required this.documents,
    required this.archives,
    required this.applications,
    required this.bestMatches,
    required this.filter,
  });

  @override
  List<Object?> get props => [allFiles, images, videos, audio, documents, archives, applications, bestMatches, filter];
}

class ResultsError extends ResultsState {
  final String message;
  const ResultsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final AppDatabase _database;

  ResultsBloc({required AppDatabase database})
      : _database = database,
        super(ResultsInitial()) {
    on<LoadResults>(_onLoadResults);
    on<ApplyFilter>(_onApplyFilter);
    on<ToggleFavorite>(_onToggleFavorite);
    on<DeleteFile>(_onDeleteFile);
  }

  Future<void> _onLoadResults(LoadResults event, Emitter<ResultsState> emit) async {
    emit(ResultsLoading());

    try {
      final filter = event.filterType != null
          ? ResultsFilter(fileType: event.filterType)
          : const ResultsFilter();

      await _loadWithFilter(filter, emit);
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(ApplyFilter event, Emitter<ResultsState> emit) async {
    emit(ResultsLoading());
    await _loadWithFilter(event.filter, emit);
  }

  Future<void> _loadWithFilter(ResultsFilter filter, Emitter<ResultsState> emit) async {
    try {
      List<ScannedFile> allFiles;

      if (filter.showDuplicatesOnly) {
        allFiles = await _database.findDuplicates();
      } else {
        allFiles = await _database.searchFiles(
          type: filter.fileType,
          minSize: filter.minSize,
          maxSize: filter.maxSize,
          startDate: filter.startDate,
          endDate: filter.endDate,
          minConfidence: filter.minConfidence,
          sourceApp: filter.sourceApp,
        );
      }

      // Sort files
      allFiles = _sortFiles(allFiles, filter.sortBy);

      // Separate by type
      final images = allFiles.where((f) => f.fileType == FileType.image).toList();
      final videos = allFiles.where((f) => f.fileType == FileType.video).toList();
      final audio = allFiles.where((f) => f.fileType == FileType.audio).toList();
      final documents = allFiles.where((f) => f.fileType == FileType.document).toList();
      final archives = allFiles.where((f) => f.fileType == FileType.archive).toList();
      final applications = allFiles.where((f) => f.fileType == FileType.application).toList();

      // Best matches = top confidence scores
      final bestMatches = List<ScannedFile>.from(allFiles)
        ..sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

      emit(ResultsLoaded(
        allFiles: allFiles,
        images: images,
        videos: videos,
        audio: audio,
        documents: documents,
        archives: archives,
        applications: applications,
        bestMatches: bestMatches.take(50).toList(),
        filter: filter,
      ));
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  List<ScannedFile> _sortFiles(List<ScannedFile> files, SortOption sortBy) {
    final sorted = List<ScannedFile>.from(files);

    switch (sortBy) {
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.lastModified.compareTo(b.lastModified));
        break;
      case SortOption.sizeDesc:
        sorted.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case SortOption.sizeAsc:
        sorted.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
      case SortOption.confidenceDesc:
        sorted.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
        break;
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.fileName.compareTo(b.fileName));
        break;
    }

    return sorted;
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<ResultsState> emit) async {
    await _database.toggleFavorite(event.fileId, event.isFavorite);

    if (state is ResultsLoaded) {
      final currentState = state as ResultsLoaded;
      add(ApplyFilter(currentState.filter));
    }
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<ResultsState> emit) async {
    await _database.deleteFile(event.fileId);

    if (state is ResultsLoaded) {
      final currentState = state as ResultsLoaded;
      add(ApplyFilter(currentState.filter));
    }
  }
}
