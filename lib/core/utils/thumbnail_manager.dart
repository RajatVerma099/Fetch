import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';

/// ThumbnailManager
/// - Lazy async thumbnail generation for images & videos
/// - Limits concurrent jobs to avoid OOM/CPU spikes
/// - Uses disk cache to persist thumbnails across sessions
class ThumbnailManager {
  ThumbnailManager._internal() {
    _cache = CacheManager(
      Config(
        'thumbnailCache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 2000,
      ),
    );
  }

  static final ThumbnailManager _instance = ThumbnailManager._internal();
  factory ThumbnailManager() => _instance;

  late final CacheManager _cache;

  // Limit concurrency to avoid spawning too many isolates / native calls
  final int _maxConcurrent = 4;
  int _running = 0;
  final Queue<Function()> _queue = Queue();

  /// Get a thumbnail as bytes. Returns null on failure.
  /// - [filePath]: absolute file path
  /// - [isVideo]: true for video
  /// - [width]: target thumbnail width (pixels)
  Future<Uint8List?> getThumbnail(String filePath, {required bool isVideo, int width = 300}) async {
    final key = await _cacheKey(filePath, width);

    try {
      final cached = await _cache.getFileFromCache(key);
      if (cached != null && await cached.file.exists()) {
        print('[ThumbnailManager] Cache hit for $filePath');
        return await cached.file.readAsBytes();
      }
    } catch (e) {
      // ignore cache read errors
    }

    final completer = Completer<Uint8List?>();

    _queue.add(() async {
      try {
        print('[ThumbnailManager] Generating thumbnail for $filePath (isVideo=$isVideo)');
        Uint8List? bytes;
        if (isVideo) {
          bytes = await VideoThumbnail.thumbnailData(
            video: filePath,
            imageFormat: ImageFormat.JPEG,
            maxWidth: width,
            quality: 75,
          );
        } else {
          final original = await File(filePath).readAsBytes();
          bytes = await compute(_decodeAndResize, {'bytes': original, 'width': width});
        }

        if (bytes != null && bytes.isNotEmpty) {
          try {
            await _cache.putFile(key, bytes, fileExtension: 'jpg');
          } catch (e) {
            print('[ThumbnailManager] Cache write failed for $filePath: $e');
          }
        }

        completer.complete(bytes);
        print('[ThumbnailManager] Thumbnail ready for $filePath');
      } catch (e, st) {
        print('[ThumbnailManager] Thumbnail generation failed for $filePath: $e');
        print(st);
        completer.complete(null);
      } finally {
        _running--;
        _schedule();
      }
    });

    _schedule();
    return completer.future;
  }

  void _schedule() {
    while (_running < _maxConcurrent && _queue.isNotEmpty) {
      final task = _queue.removeFirst();
      _running++;
      // run task without awaiting to keep concurrency semantics
      unawaited(Future<void>.microtask(task));
    }
  }

  Future<String> _cacheKey(String path, int width) async {
    try {
      final stat = await File(path).stat();
      return '${path}_${stat.modified.millisecondsSinceEpoch}_w$width';
    } catch (_) {
      return '${path}_w$width';
    }
  }
}

Future<Uint8List> _decodeAndResize(Map args) async {
  final bytes = args['bytes'] as Uint8List;
  final width = args['width'] as int;

  final decoded = img.decodeImage(bytes);
  if (decoded == null) return Uint8List(0);
  final resized = img.copyResize(decoded, width: width);
  final encoded = img.encodeJpg(resized, quality: 85);
  return Uint8List.fromList(encoded);
}
