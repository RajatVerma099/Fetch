// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ScannedFilesTable extends ScannedFiles
    with TableInfo<$ScannedFilesTable, ScannedFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FileType, int> fileType =
      GeneratedColumn<int>(
        'file_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<FileType>($ScannedFilesTable.$converterfileType);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAppHintMeta = const VerificationMeta(
    'sourceAppHint',
  );
  @override
  late final GeneratedColumn<String> sourceAppHint = GeneratedColumn<String>(
    'source_app_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<int> confidenceScore = GeneratedColumn<int>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    fileName,
    fileSize,
    mimeType,
    fileType,
    width,
    height,
    duration,
    lastModified,
    sourceAppHint,
    confidenceScore,
    thumbnailPath,
    isFavorite,
    fileHash,
    scannedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('source_app_hint')) {
      context.handle(
        _sourceAppHintMeta,
        sourceAppHint.isAcceptableOrUnknown(
          data['source_app_hint']!,
          _sourceAppHintMeta,
        ),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceScoreMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      fileType: $ScannedFilesTable.$converterfileType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}file_type'],
        )!,
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      sourceAppHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_app_hint'],
      ),
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence_score'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      ),
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
    );
  }

  @override
  $ScannedFilesTable createAlias(String alias) {
    return $ScannedFilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FileType, int, int> $converterfileType =
      const EnumIndexConverter<FileType>(FileType.values);
}

class ScannedFile extends DataClass implements Insertable<ScannedFile> {
  final int id;
  final String path;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final FileType fileType;
  final int? width;
  final int? height;
  final int? duration;
  final DateTime lastModified;
  final String? sourceAppHint;
  final int confidenceScore;
  final String? thumbnailPath;
  final bool isFavorite;
  final String? fileHash;
  final DateTime scannedAt;
  const ScannedFile({
    required this.id,
    required this.path,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.fileType,
    this.width,
    this.height,
    this.duration,
    required this.lastModified,
    this.sourceAppHint,
    required this.confidenceScore,
    this.thumbnailPath,
    required this.isFavorite,
    this.fileHash,
    required this.scannedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    map['mime_type'] = Variable<String>(mimeType);
    {
      map['file_type'] = Variable<int>(
        $ScannedFilesTable.$converterfileType.toSql(fileType),
      );
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    if (!nullToAbsent || sourceAppHint != null) {
      map['source_app_hint'] = Variable<String>(sourceAppHint);
    }
    map['confidence_score'] = Variable<int>(confidenceScore);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    return map;
  }

  ScannedFilesCompanion toCompanion(bool nullToAbsent) {
    return ScannedFilesCompanion(
      id: Value(id),
      path: Value(path),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      mimeType: Value(mimeType),
      fileType: Value(fileType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      lastModified: Value(lastModified),
      sourceAppHint: sourceAppHint == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAppHint),
      confidenceScore: Value(confidenceScore),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      isFavorite: Value(isFavorite),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      scannedAt: Value(scannedAt),
    );
  }

  factory ScannedFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedFile(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileType: $ScannedFilesTable.$converterfileType.fromJson(
        serializer.fromJson<int>(json['fileType']),
      ),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      duration: serializer.fromJson<int?>(json['duration']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      sourceAppHint: serializer.fromJson<String?>(json['sourceAppHint']),
      confidenceScore: serializer.fromJson<int>(json['confidenceScore']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileType': serializer.toJson<int>(
        $ScannedFilesTable.$converterfileType.toJson(fileType),
      ),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'duration': serializer.toJson<int?>(duration),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'sourceAppHint': serializer.toJson<String?>(sourceAppHint),
      'confidenceScore': serializer.toJson<int>(confidenceScore),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'fileHash': serializer.toJson<String?>(fileHash),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
    };
  }

  ScannedFile copyWith({
    int? id,
    String? path,
    String? fileName,
    int? fileSize,
    String? mimeType,
    FileType? fileType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    DateTime? lastModified,
    Value<String?> sourceAppHint = const Value.absent(),
    int? confidenceScore,
    Value<String?> thumbnailPath = const Value.absent(),
    bool? isFavorite,
    Value<String?> fileHash = const Value.absent(),
    DateTime? scannedAt,
  }) => ScannedFile(
    id: id ?? this.id,
    path: path ?? this.path,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    mimeType: mimeType ?? this.mimeType,
    fileType: fileType ?? this.fileType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    duration: duration.present ? duration.value : this.duration,
    lastModified: lastModified ?? this.lastModified,
    sourceAppHint: sourceAppHint.present
        ? sourceAppHint.value
        : this.sourceAppHint,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    isFavorite: isFavorite ?? this.isFavorite,
    fileHash: fileHash.present ? fileHash.value : this.fileHash,
    scannedAt: scannedAt ?? this.scannedAt,
  );
  ScannedFile copyWithCompanion(ScannedFilesCompanion data) {
    return ScannedFile(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      duration: data.duration.present ? data.duration.value : this.duration,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      sourceAppHint: data.sourceAppHint.present
          ? data.sourceAppHint.value
          : this.sourceAppHint,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedFile(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileType: $fileType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('duration: $duration, ')
          ..write('lastModified: $lastModified, ')
          ..write('sourceAppHint: $sourceAppHint, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('fileHash: $fileHash, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    fileName,
    fileSize,
    mimeType,
    fileType,
    width,
    height,
    duration,
    lastModified,
    sourceAppHint,
    confidenceScore,
    thumbnailPath,
    isFavorite,
    fileHash,
    scannedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedFile &&
          other.id == this.id &&
          other.path == this.path &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.mimeType == this.mimeType &&
          other.fileType == this.fileType &&
          other.width == this.width &&
          other.height == this.height &&
          other.duration == this.duration &&
          other.lastModified == this.lastModified &&
          other.sourceAppHint == this.sourceAppHint &&
          other.confidenceScore == this.confidenceScore &&
          other.thumbnailPath == this.thumbnailPath &&
          other.isFavorite == this.isFavorite &&
          other.fileHash == this.fileHash &&
          other.scannedAt == this.scannedAt);
}

class ScannedFilesCompanion extends UpdateCompanion<ScannedFile> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<String> mimeType;
  final Value<FileType> fileType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> duration;
  final Value<DateTime> lastModified;
  final Value<String?> sourceAppHint;
  final Value<int> confidenceScore;
  final Value<String?> thumbnailPath;
  final Value<bool> isFavorite;
  final Value<String?> fileHash;
  final Value<DateTime> scannedAt;
  const ScannedFilesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.duration = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.sourceAppHint = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.scannedAt = const Value.absent(),
  });
  ScannedFilesCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String fileName,
    required int fileSize,
    required String mimeType,
    required FileType fileType,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.duration = const Value.absent(),
    required DateTime lastModified,
    this.sourceAppHint = const Value.absent(),
    required int confidenceScore,
    this.thumbnailPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.fileHash = const Value.absent(),
    required DateTime scannedAt,
  }) : path = Value(path),
       fileName = Value(fileName),
       fileSize = Value(fileSize),
       mimeType = Value(mimeType),
       fileType = Value(fileType),
       lastModified = Value(lastModified),
       confidenceScore = Value(confidenceScore),
       scannedAt = Value(scannedAt);
  static Insertable<ScannedFile> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? mimeType,
    Expression<int>? fileType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? duration,
    Expression<DateTime>? lastModified,
    Expression<String>? sourceAppHint,
    Expression<int>? confidenceScore,
    Expression<String>? thumbnailPath,
    Expression<bool>? isFavorite,
    Expression<String>? fileHash,
    Expression<DateTime>? scannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileType != null) 'file_type': fileType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (duration != null) 'duration': duration,
      if (lastModified != null) 'last_modified': lastModified,
      if (sourceAppHint != null) 'source_app_hint': sourceAppHint,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (fileHash != null) 'file_hash': fileHash,
      if (scannedAt != null) 'scanned_at': scannedAt,
    });
  }

  ScannedFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? fileName,
    Value<int>? fileSize,
    Value<String>? mimeType,
    Value<FileType>? fileType,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? duration,
    Value<DateTime>? lastModified,
    Value<String?>? sourceAppHint,
    Value<int>? confidenceScore,
    Value<String?>? thumbnailPath,
    Value<bool>? isFavorite,
    Value<String?>? fileHash,
    Value<DateTime>? scannedAt,
  }) {
    return ScannedFilesCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      fileType: fileType ?? this.fileType,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      lastModified: lastModified ?? this.lastModified,
      sourceAppHint: sourceAppHint ?? this.sourceAppHint,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isFavorite: isFavorite ?? this.isFavorite,
      fileHash: fileHash ?? this.fileHash,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<int>(
        $ScannedFilesTable.$converterfileType.toSql(fileType.value),
      );
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (sourceAppHint.present) {
      map['source_app_hint'] = Variable<String>(sourceAppHint.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<int>(confidenceScore.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedFilesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileType: $fileType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('duration: $duration, ')
          ..write('lastModified: $lastModified, ')
          ..write('sourceAppHint: $sourceAppHint, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('fileHash: $fileHash, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }
}

class $ScanSessionsTable extends ScanSessions
    with TableInfo<$ScanSessionsTable, ScanSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalFilesScannedMeta = const VerificationMeta(
    'totalFilesScanned',
  );
  @override
  late final GeneratedColumn<int> totalFilesScanned = GeneratedColumn<int>(
    'total_files_scanned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imagesFoundMeta = const VerificationMeta(
    'imagesFound',
  );
  @override
  late final GeneratedColumn<int> imagesFound = GeneratedColumn<int>(
    'images_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _videosFoundMeta = const VerificationMeta(
    'videosFound',
  );
  @override
  late final GeneratedColumn<int> videosFound = GeneratedColumn<int>(
    'videos_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _documentsFoundMeta = const VerificationMeta(
    'documentsFound',
  );
  @override
  late final GeneratedColumn<int> documentsFound = GeneratedColumn<int>(
    'documents_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedPathsMeta = const VerificationMeta(
    'scannedPaths',
  );
  @override
  late final GeneratedColumn<String> scannedPaths = GeneratedColumn<String>(
    'scanned_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    totalFilesScanned,
    imagesFound,
    videosFound,
    documentsFound,
    status,
    scannedPaths,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('total_files_scanned')) {
      context.handle(
        _totalFilesScannedMeta,
        totalFilesScanned.isAcceptableOrUnknown(
          data['total_files_scanned']!,
          _totalFilesScannedMeta,
        ),
      );
    }
    if (data.containsKey('images_found')) {
      context.handle(
        _imagesFoundMeta,
        imagesFound.isAcceptableOrUnknown(
          data['images_found']!,
          _imagesFoundMeta,
        ),
      );
    }
    if (data.containsKey('videos_found')) {
      context.handle(
        _videosFoundMeta,
        videosFound.isAcceptableOrUnknown(
          data['videos_found']!,
          _videosFoundMeta,
        ),
      );
    }
    if (data.containsKey('documents_found')) {
      context.handle(
        _documentsFoundMeta,
        documentsFound.isAcceptableOrUnknown(
          data['documents_found']!,
          _documentsFoundMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scanned_paths')) {
      context.handle(
        _scannedPathsMeta,
        scannedPaths.isAcceptableOrUnknown(
          data['scanned_paths']!,
          _scannedPathsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scannedPathsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      totalFilesScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_files_scanned'],
      )!,
      imagesFound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}images_found'],
      )!,
      videosFound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}videos_found'],
      )!,
      documentsFound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documents_found'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      scannedPaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scanned_paths'],
      )!,
    );
  }

  @override
  $ScanSessionsTable createAlias(String alias) {
    return $ScanSessionsTable(attachedDatabase, alias);
  }
}

class ScanSession extends DataClass implements Insertable<ScanSession> {
  final int id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalFilesScanned;
  final int imagesFound;
  final int videosFound;
  final int documentsFound;
  final String status;
  final String scannedPaths;
  const ScanSession({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.totalFilesScanned,
    required this.imagesFound,
    required this.videosFound,
    required this.documentsFound,
    required this.status,
    required this.scannedPaths,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['total_files_scanned'] = Variable<int>(totalFilesScanned);
    map['images_found'] = Variable<int>(imagesFound);
    map['videos_found'] = Variable<int>(videosFound);
    map['documents_found'] = Variable<int>(documentsFound);
    map['status'] = Variable<String>(status);
    map['scanned_paths'] = Variable<String>(scannedPaths);
    return map;
  }

  ScanSessionsCompanion toCompanion(bool nullToAbsent) {
    return ScanSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      totalFilesScanned: Value(totalFilesScanned),
      imagesFound: Value(imagesFound),
      videosFound: Value(videosFound),
      documentsFound: Value(documentsFound),
      status: Value(status),
      scannedPaths: Value(scannedPaths),
    );
  }

  factory ScanSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      totalFilesScanned: serializer.fromJson<int>(json['totalFilesScanned']),
      imagesFound: serializer.fromJson<int>(json['imagesFound']),
      videosFound: serializer.fromJson<int>(json['videosFound']),
      documentsFound: serializer.fromJson<int>(json['documentsFound']),
      status: serializer.fromJson<String>(json['status']),
      scannedPaths: serializer.fromJson<String>(json['scannedPaths']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'totalFilesScanned': serializer.toJson<int>(totalFilesScanned),
      'imagesFound': serializer.toJson<int>(imagesFound),
      'videosFound': serializer.toJson<int>(videosFound),
      'documentsFound': serializer.toJson<int>(documentsFound),
      'status': serializer.toJson<String>(status),
      'scannedPaths': serializer.toJson<String>(scannedPaths),
    };
  }

  ScanSession copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? totalFilesScanned,
    int? imagesFound,
    int? videosFound,
    int? documentsFound,
    String? status,
    String? scannedPaths,
  }) => ScanSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    totalFilesScanned: totalFilesScanned ?? this.totalFilesScanned,
    imagesFound: imagesFound ?? this.imagesFound,
    videosFound: videosFound ?? this.videosFound,
    documentsFound: documentsFound ?? this.documentsFound,
    status: status ?? this.status,
    scannedPaths: scannedPaths ?? this.scannedPaths,
  );
  ScanSession copyWithCompanion(ScanSessionsCompanion data) {
    return ScanSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      totalFilesScanned: data.totalFilesScanned.present
          ? data.totalFilesScanned.value
          : this.totalFilesScanned,
      imagesFound: data.imagesFound.present
          ? data.imagesFound.value
          : this.imagesFound,
      videosFound: data.videosFound.present
          ? data.videosFound.value
          : this.videosFound,
      documentsFound: data.documentsFound.present
          ? data.documentsFound.value
          : this.documentsFound,
      status: data.status.present ? data.status.value : this.status,
      scannedPaths: data.scannedPaths.present
          ? data.scannedPaths.value
          : this.scannedPaths,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalFilesScanned: $totalFilesScanned, ')
          ..write('imagesFound: $imagesFound, ')
          ..write('videosFound: $videosFound, ')
          ..write('documentsFound: $documentsFound, ')
          ..write('status: $status, ')
          ..write('scannedPaths: $scannedPaths')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    completedAt,
    totalFilesScanned,
    imagesFound,
    videosFound,
    documentsFound,
    status,
    scannedPaths,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.totalFilesScanned == this.totalFilesScanned &&
          other.imagesFound == this.imagesFound &&
          other.videosFound == this.videosFound &&
          other.documentsFound == this.documentsFound &&
          other.status == this.status &&
          other.scannedPaths == this.scannedPaths);
}

class ScanSessionsCompanion extends UpdateCompanion<ScanSession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> totalFilesScanned;
  final Value<int> imagesFound;
  final Value<int> videosFound;
  final Value<int> documentsFound;
  final Value<String> status;
  final Value<String> scannedPaths;
  const ScanSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.totalFilesScanned = const Value.absent(),
    this.imagesFound = const Value.absent(),
    this.videosFound = const Value.absent(),
    this.documentsFound = const Value.absent(),
    this.status = const Value.absent(),
    this.scannedPaths = const Value.absent(),
  });
  ScanSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.totalFilesScanned = const Value.absent(),
    this.imagesFound = const Value.absent(),
    this.videosFound = const Value.absent(),
    this.documentsFound = const Value.absent(),
    required String status,
    required String scannedPaths,
  }) : startedAt = Value(startedAt),
       status = Value(status),
       scannedPaths = Value(scannedPaths);
  static Insertable<ScanSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? totalFilesScanned,
    Expression<int>? imagesFound,
    Expression<int>? videosFound,
    Expression<int>? documentsFound,
    Expression<String>? status,
    Expression<String>? scannedPaths,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (totalFilesScanned != null) 'total_files_scanned': totalFilesScanned,
      if (imagesFound != null) 'images_found': imagesFound,
      if (videosFound != null) 'videos_found': videosFound,
      if (documentsFound != null) 'documents_found': documentsFound,
      if (status != null) 'status': status,
      if (scannedPaths != null) 'scanned_paths': scannedPaths,
    });
  }

  ScanSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? totalFilesScanned,
    Value<int>? imagesFound,
    Value<int>? videosFound,
    Value<int>? documentsFound,
    Value<String>? status,
    Value<String>? scannedPaths,
  }) {
    return ScanSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalFilesScanned: totalFilesScanned ?? this.totalFilesScanned,
      imagesFound: imagesFound ?? this.imagesFound,
      videosFound: videosFound ?? this.videosFound,
      documentsFound: documentsFound ?? this.documentsFound,
      status: status ?? this.status,
      scannedPaths: scannedPaths ?? this.scannedPaths,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (totalFilesScanned.present) {
      map['total_files_scanned'] = Variable<int>(totalFilesScanned.value);
    }
    if (imagesFound.present) {
      map['images_found'] = Variable<int>(imagesFound.value);
    }
    if (videosFound.present) {
      map['videos_found'] = Variable<int>(videosFound.value);
    }
    if (documentsFound.present) {
      map['documents_found'] = Variable<int>(documentsFound.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scannedPaths.present) {
      map['scanned_paths'] = Variable<String>(scannedPaths.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalFilesScanned: $totalFilesScanned, ')
          ..write('imagesFound: $imagesFound, ')
          ..write('videosFound: $videosFound, ')
          ..write('documentsFound: $documentsFound, ')
          ..write('status: $status, ')
          ..write('scannedPaths: $scannedPaths')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScannedFilesTable scannedFiles = $ScannedFilesTable(this);
  late final $ScanSessionsTable scanSessions = $ScanSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scannedFiles,
    scanSessions,
  ];
}

typedef $$ScannedFilesTableCreateCompanionBuilder =
    ScannedFilesCompanion Function({
      Value<int> id,
      required String path,
      required String fileName,
      required int fileSize,
      required String mimeType,
      required FileType fileType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> duration,
      required DateTime lastModified,
      Value<String?> sourceAppHint,
      required int confidenceScore,
      Value<String?> thumbnailPath,
      Value<bool> isFavorite,
      Value<String?> fileHash,
      required DateTime scannedAt,
    });
typedef $$ScannedFilesTableUpdateCompanionBuilder =
    ScannedFilesCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> fileName,
      Value<int> fileSize,
      Value<String> mimeType,
      Value<FileType> fileType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> duration,
      Value<DateTime> lastModified,
      Value<String?> sourceAppHint,
      Value<int> confidenceScore,
      Value<String?> thumbnailPath,
      Value<bool> isFavorite,
      Value<String?> fileHash,
      Value<DateTime> scannedAt,
    });

class $$ScannedFilesTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedFilesTable> {
  $$ScannedFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FileType, FileType, int> get fileType =>
      $composableBuilder(
        column: $table.fileType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAppHint => $composableBuilder(
    column: $table.sourceAppHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScannedFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedFilesTable> {
  $$ScannedFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAppHint => $composableBuilder(
    column: $table.sourceAppHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScannedFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedFilesTable> {
  $$ScannedFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FileType, int> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAppHint => $composableBuilder(
    column: $table.sourceAppHint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);
}

class $$ScannedFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedFilesTable,
          ScannedFile,
          $$ScannedFilesTableFilterComposer,
          $$ScannedFilesTableOrderingComposer,
          $$ScannedFilesTableAnnotationComposer,
          $$ScannedFilesTableCreateCompanionBuilder,
          $$ScannedFilesTableUpdateCompanionBuilder,
          (
            ScannedFile,
            BaseReferences<_$AppDatabase, $ScannedFilesTable, ScannedFile>,
          ),
          ScannedFile,
          PrefetchHooks Function()
        > {
  $$ScannedFilesTableTableManager(_$AppDatabase db, $ScannedFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScannedFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScannedFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<FileType> fileType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String?> sourceAppHint = const Value.absent(),
                Value<int> confidenceScore = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> fileHash = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
              }) => ScannedFilesCompanion(
                id: id,
                path: path,
                fileName: fileName,
                fileSize: fileSize,
                mimeType: mimeType,
                fileType: fileType,
                width: width,
                height: height,
                duration: duration,
                lastModified: lastModified,
                sourceAppHint: sourceAppHint,
                confidenceScore: confidenceScore,
                thumbnailPath: thumbnailPath,
                isFavorite: isFavorite,
                fileHash: fileHash,
                scannedAt: scannedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String fileName,
                required int fileSize,
                required String mimeType,
                required FileType fileType,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                required DateTime lastModified,
                Value<String?> sourceAppHint = const Value.absent(),
                required int confidenceScore,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> fileHash = const Value.absent(),
                required DateTime scannedAt,
              }) => ScannedFilesCompanion.insert(
                id: id,
                path: path,
                fileName: fileName,
                fileSize: fileSize,
                mimeType: mimeType,
                fileType: fileType,
                width: width,
                height: height,
                duration: duration,
                lastModified: lastModified,
                sourceAppHint: sourceAppHint,
                confidenceScore: confidenceScore,
                thumbnailPath: thumbnailPath,
                isFavorite: isFavorite,
                fileHash: fileHash,
                scannedAt: scannedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScannedFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedFilesTable,
      ScannedFile,
      $$ScannedFilesTableFilterComposer,
      $$ScannedFilesTableOrderingComposer,
      $$ScannedFilesTableAnnotationComposer,
      $$ScannedFilesTableCreateCompanionBuilder,
      $$ScannedFilesTableUpdateCompanionBuilder,
      (
        ScannedFile,
        BaseReferences<_$AppDatabase, $ScannedFilesTable, ScannedFile>,
      ),
      ScannedFile,
      PrefetchHooks Function()
    >;
typedef $$ScanSessionsTableCreateCompanionBuilder =
    ScanSessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int> totalFilesScanned,
      Value<int> imagesFound,
      Value<int> videosFound,
      Value<int> documentsFound,
      required String status,
      required String scannedPaths,
    });
typedef $$ScanSessionsTableUpdateCompanionBuilder =
    ScanSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> totalFilesScanned,
      Value<int> imagesFound,
      Value<int> videosFound,
      Value<int> documentsFound,
      Value<String> status,
      Value<String> scannedPaths,
    });

class $$ScanSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalFilesScanned => $composableBuilder(
    column: $table.totalFilesScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imagesFound => $composableBuilder(
    column: $table.imagesFound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videosFound => $composableBuilder(
    column: $table.videosFound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentsFound => $composableBuilder(
    column: $table.documentsFound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scannedPaths => $composableBuilder(
    column: $table.scannedPaths,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalFilesScanned => $composableBuilder(
    column: $table.totalFilesScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imagesFound => $composableBuilder(
    column: $table.imagesFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videosFound => $composableBuilder(
    column: $table.videosFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentsFound => $composableBuilder(
    column: $table.documentsFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scannedPaths => $composableBuilder(
    column: $table.scannedPaths,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalFilesScanned => $composableBuilder(
    column: $table.totalFilesScanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imagesFound => $composableBuilder(
    column: $table.imagesFound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get videosFound => $composableBuilder(
    column: $table.videosFound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get documentsFound => $composableBuilder(
    column: $table.documentsFound,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get scannedPaths => $composableBuilder(
    column: $table.scannedPaths,
    builder: (column) => column,
  );
}

class $$ScanSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanSessionsTable,
          ScanSession,
          $$ScanSessionsTableFilterComposer,
          $$ScanSessionsTableOrderingComposer,
          $$ScanSessionsTableAnnotationComposer,
          $$ScanSessionsTableCreateCompanionBuilder,
          $$ScanSessionsTableUpdateCompanionBuilder,
          (
            ScanSession,
            BaseReferences<_$AppDatabase, $ScanSessionsTable, ScanSession>,
          ),
          ScanSession,
          PrefetchHooks Function()
        > {
  $$ScanSessionsTableTableManager(_$AppDatabase db, $ScanSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> totalFilesScanned = const Value.absent(),
                Value<int> imagesFound = const Value.absent(),
                Value<int> videosFound = const Value.absent(),
                Value<int> documentsFound = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> scannedPaths = const Value.absent(),
              }) => ScanSessionsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                totalFilesScanned: totalFilesScanned,
                imagesFound: imagesFound,
                videosFound: videosFound,
                documentsFound: documentsFound,
                status: status,
                scannedPaths: scannedPaths,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> totalFilesScanned = const Value.absent(),
                Value<int> imagesFound = const Value.absent(),
                Value<int> videosFound = const Value.absent(),
                Value<int> documentsFound = const Value.absent(),
                required String status,
                required String scannedPaths,
              }) => ScanSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                totalFilesScanned: totalFilesScanned,
                imagesFound: imagesFound,
                videosFound: videosFound,
                documentsFound: documentsFound,
                status: status,
                scannedPaths: scannedPaths,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanSessionsTable,
      ScanSession,
      $$ScanSessionsTableFilterComposer,
      $$ScanSessionsTableOrderingComposer,
      $$ScanSessionsTableAnnotationComposer,
      $$ScanSessionsTableCreateCompanionBuilder,
      $$ScanSessionsTableUpdateCompanionBuilder,
      (
        ScanSession,
        BaseReferences<_$AppDatabase, $ScanSessionsTable, ScanSession>,
      ),
      ScanSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScannedFilesTableTableManager get scannedFiles =>
      $$ScannedFilesTableTableManager(_db, _db.scannedFiles);
  $$ScanSessionsTableTableManager get scanSessions =>
      $$ScanSessionsTableTableManager(_db, _db.scanSessions);
}
