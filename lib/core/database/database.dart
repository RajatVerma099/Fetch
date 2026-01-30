import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Enum for file types - expanded to support all file categories
enum FileType {
  image,
  video,
  audio,
  document,
  archive,
  application, // APK, EXE, DLL, etc.
  database,
  code,
  other,
}

/// Table for storing scanned files
class ScannedFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();
  TextColumn get mimeType => text()();
  IntColumn get fileType => intEnum<FileType>()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get duration => integer().nullable()(); // milliseconds for videos
  DateTimeColumn get lastModified => dateTime()();
  TextColumn get sourceAppHint => text().nullable()();
  IntColumn get confidenceScore => integer()(); // 0-100
  TextColumn get thumbnailPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get fileHash => text().nullable()(); // For duplicate detection
  DateTimeColumn get scannedAt => dateTime()();
}

/// Table for storing scan sessions
class ScanSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get totalFilesScanned => integer().withDefault(const Constant(0))();
  IntColumn get imagesFound => integer().withDefault(const Constant(0))();
  IntColumn get videosFound => integer().withDefault(const Constant(0))();
  IntColumn get documentsFound => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // running, paused, completed, cancelled
  TextColumn get scannedPaths => text()(); // JSON array of scanned paths
}

@DriftDatabase(tables: [ScannedFiles, ScanSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ScannedFiles queries
  Future<List<ScannedFile>> getAllFiles() => select(scannedFiles).get();

  /// Watch for all files - reactive stream that emits on every change
  /// Used for results screen to lazily load large datasets
  Stream<List<ScannedFile>> watchAllFiles() {
    print('[Database] [WATCH] Setting up reactive watch for all files');
    return select(scannedFiles).watch();
  }

  Future<List<ScannedFile>> getFilesByType(FileType type) {
    return (select(scannedFiles)..where((f) => f.fileType.equals(type.index)))
        .get();
  }

  Future<List<ScannedFile>> getTopConfidenceFiles({int limit = 50}) {
    return (select(scannedFiles)
          ..orderBy([(f) => OrderingTerm.desc(f.confidenceScore)])
          ..limit(limit))
        .get();
  }

  Future<List<ScannedFile>> getFavorites() {
    return (select(scannedFiles)..where((f) => f.isFavorite.equals(true))).get();
  }

  Future<List<ScannedFile>> searchFiles({
    FileType? type,
    int? minSize,
    int? maxSize,
    DateTime? startDate,
    DateTime? endDate,
    int? minConfidence,
    String? sourceApp,
  }) {
    return (select(scannedFiles)
          ..where((f) {
            Expression<bool> condition = const Constant(true);
            if (type != null) {
              condition = condition & f.fileType.equals(type.index);
            }
            if (minSize != null) {
              condition = condition & f.fileSize.isBiggerOrEqualValue(minSize);
            }
            if (maxSize != null) {
              condition = condition & f.fileSize.isSmallerOrEqualValue(maxSize);
            }
            if (startDate != null) {
              condition = condition & f.lastModified.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              condition = condition & f.lastModified.isSmallerOrEqualValue(endDate);
            }
            if (minConfidence != null) {
              condition =
                  condition & f.confidenceScore.isBiggerOrEqualValue(minConfidence);
            }
            if (sourceApp != null) {
              condition = condition & f.sourceAppHint.equals(sourceApp);
            }
            return condition;
          }))
        .get();
  }

  Future<int> insertFile(ScannedFilesCompanion file) {
    print('[Database] [INSERT] Inserting file: ${file.fileName.value} (type: ${file.fileType.value})');
    return into(scannedFiles).insert(file);
  }

  Future<void> insertFiles(List<ScannedFilesCompanion> files) async {
    print('[Database] [INSERT] Batch inserting ${files.length} files');
    await batch((batch) {
      batch.insertAll(scannedFiles, files);
    });
    print('[Database] [INSERT] Batch insertion complete');
  }

  Future<bool> updateFile(ScannedFile file) {
    return update(scannedFiles).replace(file);
  }

  Future<int> deleteFile(int id) {
    return (delete(scannedFiles)..where((f) => f.id.equals(id))).go();
  }

  Future<int> deleteAllFiles() {
    return delete(scannedFiles).go();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) {
    return (update(scannedFiles)..where((f) => f.id.equals(id)))
        .write(ScannedFilesCompanion(isFavorite: Value(isFavorite)));
  }

  // Find duplicates based on hash
  Future<List<ScannedFile>> findDuplicates() async {
    final allFiles = await getAllFiles();
    final hashGroups = <String, List<ScannedFile>>{};

    for (final file in allFiles) {
      if (file.fileHash != null) {
        hashGroups.putIfAbsent(file.fileHash!, () => []).add(file);
      }
    }

    // Return files that have duplicates
    return hashGroups.values
        .where((group) => group.length > 1)
        .expand((group) => group)
        .toList();
  }

  // ScanSessions queries
  Future<ScanSession?> getLatestSession() {
    return (select(scanSessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> createSession(ScanSessionsCompanion session) {
    return into(scanSessions).insert(session);
  }

  Future<void> updateSession(int id, ScanSessionsCompanion session) {
    return (update(scanSessions)..where((s) => s.id.equals(id))).write(session);
  }

  // Statistics
  Future<Map<String, int>> getFileStats() async {
    final images = await getFilesByType(FileType.image);
    final videos = await getFilesByType(FileType.video);
    final documents = await getFilesByType(FileType.document);
    final audio = await getFilesByType(FileType.audio);
    final archives = await getFilesByType(FileType.archive);
    final applications = await getFilesByType(FileType.application);
    final databases = await getFilesByType(FileType.database);
    final code = await getFilesByType(FileType.code);
    final others = await getFilesByType(FileType.other);
    final favorites = await getFavorites();

    return {
      'images': images.length,
      'videos': videos.length,
      'documents': documents.length,
      'audio': audio.length,
      'archives': archives.length,
      'applications': applications.length,
      'databases': databases.length,
      'code': code.length,
      'others': others.length,
      'favorites': favorites.length,
      'total': images.length + videos.length + documents.length + audio.length + 
               archives.length + applications.length + databases.length + code.length + others.length,
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fetch_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
