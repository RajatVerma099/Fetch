import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
  
  // In-memory LRU cache for instant access during scrolling
  final _memoryCache = _LruCache<String, Uint8List>(capacity: 200);

  // Limit concurrency to avoid spawning too many isolates / native calls
  final int _maxConcurrent = 4;
  int _running = 0;
  final Queue<Function()> _queue = Queue();

  static const _channel = MethodChannel('com.fetch.app/scanner');

  /// Get a thumbnail as bytes. Returns null on failure.
  Future<Uint8List?> getThumbnail(String filePath, {required bool isVideo, int width = 300}) async {
    final key = await _cacheKey(filePath, width);

    // ... Fast path same ...
    final memCached = _memoryCache.get(key);
    if (memCached != null) return memCached;

    final anyMemKey = _memoryCache._map.keys.firstWhere((k) => k.split('_w').first == key.split('_w').first, orElse: () => '');
    if (anyMemKey.isNotEmpty) {
      final fallback = _memoryCache.get(anyMemKey);
      if (fallback != null) return fallback;
    }

    try {
      final cached = await _cache.getFileFromCache(key);
      if (cached != null && await cached.file.exists()) {
        final bytes = await cached.file.readAsBytes();
        _memoryCache.put(key, bytes);
        return bytes;
      }
    } catch (_) {}

    final completer = Completer<Uint8List?>();

    _queue.add(() async {
      try {
        print('[CACHE] [MISS/DECODE] $filePath (isVideo=$isVideo, width=$width)');
        Uint8List? bytes;
        
        if (isVideo) {
          bytes = await VideoThumbnail.thumbnailData(
            video: filePath,
            imageFormat: ImageFormat.JPEG,
            maxWidth: width,
            quality: 75,
          );
        } else {
          // NEW: Use native decoding for large images
          final String? thumbPath = await _channel.invokeMethod('generateThumbnail', {
            'path': filePath,
            'mimeType': 'image/*',
            'size': width,
          });
          
          if (thumbPath != null) {
            final thumbFile = File(thumbPath);
            if (await thumbFile.exists()) {
              bytes = await thumbFile.readAsBytes();
              // Cleanup temporary native thumbnail file
              try { await thumbFile.delete(); } catch (_) {}
            }
          }
        }

        if (bytes != null && bytes.isNotEmpty) {
          _memoryCache.put(key, bytes);
          try {
            await _cache.putFile(key, bytes, fileExtension: 'jpg');
          } catch (e) {
            print('[ThumbnailManager] Cache write failed: $e');
          }
        }

        completer.complete(bytes);
      } catch (e) {
        print('[ThumbnailManager] Generation failed for $filePath: $e');
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

/// Simple LRU Cache implementation using LinkedHashMap
class _LruCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  _LruCache({required this.capacity});

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= capacity) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  void clear() => _map.clear();
}
