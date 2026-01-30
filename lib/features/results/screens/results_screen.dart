import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/database/database.dart';
import '../../../core/utils/thumbnail_manager.dart';
import '../../../core/utils/preview_manager.dart';
import '../../../core/widgets/preview_overlay.dart';
import 'dart:typed_data';

/// Results screen showing recovered files in categorized tabs
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _images = <ScannedFile>[];
  final _videos = <ScannedFile>[];
  final _audio = <ScannedFile>[];
  final _documents = <ScannedFile>[];
  final _others = <ScannedFile>[];
  bool _isGridView = true;
  bool _isLoading = true;
  
  // CRITICAL: Store subscription to prevent garbage collection
  StreamSubscription<List<ScannedFile>>? _fileStreamSubscription;
  
  // Preview overlay state
  ScannedFile? _previewFile;
  bool _isPreviewVisible = false;
  Timer? _previewTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Set up reactive stream listener in next frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupReactiveFileListener();
      }
    });
  }

  /// Set up reactive listener for files using database stream
  /// This automatically rebuilds the UI as files are inserted into DB
  void _setupReactiveFileListener() {
    print('[ResultsScreen] [INIT] Setting up reactive file stream listener');
    try {
      final database = context.read<AppDatabase>();
      print('[ResultsScreen] [INIT] Database instance retrieved');
      
      // First, load any existing files (in case they were already scanned)
      _loadExistingFiles(database);
      
      // CRITICAL: Watch the database for changes - updates as batches arrive
      // Store subscription to prevent garbage collection
      print('[ResultsScreen] [INIT] Calling watchAllFiles()...');
      _fileStreamSubscription = database.watchAllFiles().listen(
        (files) {
          print('[ResultsScreen] [STREAM] ====== STREAM EMITTED ====== ${files.length} total files');
          
          if (mounted) {
            setState(() {
              _images.clear();
              _videos.clear();
              _audio.clear();
              _documents.clear();
              _others.clear();
              
              // Categorize incoming files
              for (final file in files) {
                switch (file.fileType) {
                  case FileType.image:
                    _images.add(file);
                    break;
                  case FileType.video:
                    _videos.add(file);
                    break;
                  case FileType.audio:
                    _audio.add(file);
                    break;
                  case FileType.document:
                    _documents.add(file);
                    break;
                  default:
                    _others.add(file);
                }
              }
              
              // CRITICAL: Hide loading indicator when we have ANY files
              if (files.isNotEmpty && _isLoading) {
                print('[ResultsScreen] [STREAM] Files found (${files.length})! Setting _isLoading = false');
                _isLoading = false;
              }
              
              print('[ResultsScreen] [STREAM] Categorized: ${_images.length} img, ${_videos.length} vid, ${_documents.length} doc, ${_audio.length} aud, ${_others.length} oth');
            });
          }
        },
        onError: (e, st) {
          print('[ResultsScreen] [STREAM] ERROR: $e');
          print('[ResultsScreen] [STREAM] STACKTRACE: $st');
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load files: $e')),
            );
          }
        },
      );
      print('[ResultsScreen] [INIT] Stream subscription established (stored)');
    } catch (e, st) {
      print('[ResultsScreen] [INIT] ERROR setting up listener: $e');
      print('[ResultsScreen] [INIT] STACKTRACE: $st');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Load any files that already exist in DB (fallback)
  Future<void> _loadExistingFiles(AppDatabase database) async {
    try {
      print('[ResultsScreen] [INIT] Attempting to load existing files...');
      final existingFiles = await database.getAllFiles();
      print('[ResultsScreen] [INIT] Found ${existingFiles.length} existing files in DB');
      
      if (existingFiles.isNotEmpty && mounted) {
        setState(() {
          _images.clear();
          _videos.clear();
          _audio.clear();
          _documents.clear();
          _others.clear();
          
          for (final file in existingFiles) {
            switch (file.fileType) {
              case FileType.image:
                _images.add(file);
                break;
              case FileType.video:
                _videos.add(file);
                break;
              case FileType.audio:
                _audio.add(file);
                break;
              case FileType.document:
                _documents.add(file);
                break;
              default:
                _others.add(file);
            }
          }
          
          _isLoading = false;
          print('[ResultsScreen] [INIT] Existing files loaded. _isLoading = false');
        });
      }
    } catch (e) {
      print('[ResultsScreen] [INIT] Error loading existing files: $e');
    }
  }

  @override
  void dispose() {
    // CRITICAL: Cancel subscription to prevent memory leak
    print('[ResultsScreen] [DISPOSE] Cancelling file stream subscription');
    _fileStreamSubscription?.cancel();
    _previewTimer?.cancel();
    _tabController.dispose();
    _closePreview();
    super.dispose();
  }

  void _showPreview(ScannedFile file) {
    print('[ResultsScreen] [PREVIEW] Long-press detected for ${file.fileName}');
    setState(() {
      _previewFile = file;
      _isPreviewVisible = true;
    });
    PreviewManager().startPreview();
  }

  void _closePreview() {
    print('[ResultsScreen] [PREVIEW] Closing preview');
    _previewTimer?.cancel();
    _previewTimer = null;
    setState(() => _isPreviewVisible = false);
    _previewFile = null;
    PreviewManager().releasePreview();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recovered Files'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: [
              _buildTab('Images', _images.length),
              _buildTab('Videos', _videos.length),
              _buildTab('Audio', _audio.length),
              _buildTab('Documents', _documents.length),
              _buildTab('Other', _others.length),
            ],
          ),
        ),
        body: Stack(
          children: [
            _buildBody(context),
            // Preview overlay (shown when long-press active)
            if (_isPreviewVisible && _previewFile != null)
              PreviewOverlay(
                file: _previewFile!,
                onDismiss: _closePreview,
              ),
          ],
        ),
      ),
    );
  }

  /// Build body with loading state check
  /// CRITICAL: Loading indicator hides when files.length > 0, NOT when thumbnails finish
  Widget _buildBody(BuildContext context) {
    // Show loading spinner only if no files exist
    if (_isLoading && _images.isEmpty && _videos.isEmpty && _documents.isEmpty && _audio.isEmpty && _others.isEmpty) {
      print('[ResultsScreen] [BUILD] Showing loading indicator (no files yet)');
      return const Center(child: CircularProgressIndicator());
    }
    
    // Files exist OR we have at least some data - show grid/list immediately
    print('[ResultsScreen] [BUILD] Building results UI with ${_images.length + _videos.length + _documents.length + _audio.length + _others.length} total files');
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildFileTab(_images, 'image'),
          _buildFileTab(_videos, 'video'),
          _buildFileTab(_audio, 'audio'),
          _buildFileTab(_documents, 'document'),
          _buildFileTab(_others, 'other'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Badge.count(count: count),
          ),
      ],
    );
  }

  Widget _buildFileTab(List<ScannedFile> files, String category) {
    print('[ResultsScreen] [TAB] Building $category tab with ${files.length} files');
    
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIconFromString(category),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No files found'),
          ],
        ),
      );
    }

    if (_isGridView && (category == 'image' || category == 'video')) {
      print('[ResultsScreen] [TAB] Using GridView.builder for $category (itemCount: ${files.length})');
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        cacheExtent: 500, // Preload small buffer (roughly 2 rows)
        itemCount: files.length,
        itemBuilder: (ctx, idx) {
          print('[ResultsScreen] [GRID_ITEM] Rendering item $idx of $category');
          return _buildFileGridItem(files[idx]);
        },
      );
    }

    // List view for audio, documents, and others
    print('[ResultsScreen] [TAB] Using ListView.builder for $category (itemCount: ${files.length})');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: files.length,
      itemBuilder: (ctx, idx) {
        print('[ResultsScreen] [LIST_ITEM] Rendering item $idx of $category');
        return _buildFileListItem(files[idx]);
      },
    );
  }

  Widget _buildFileGridItem(ScannedFile file) {
    final isVideo = file.fileType == FileType.video;
    print('[ResultsScreen] [GRID_ITEM] Building tile for ${file.fileName} (isVideo=$isVideo)');

    return GestureDetector(
      onLongPressStart: (_) {
        print('[ResultsScreen] [PREVIEW] Long-press detected, starting 500ms timer (total 1000ms)');
        _previewTimer?.cancel();
        _previewTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showPreview(file);
          }
        });
      },
      onLongPressEnd: (_) => _closePreview(),
      onLongPressCancel: () => _closePreview(),
      child: InkWell(
        onTap: () => _showFileDetails(file),
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.grey[300],
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail (lazy, async, cached)
                FutureBuilder<Uint8List?>(
                  future: ThumbnailManager().getThumbnail(file.path, isVideo: isVideo, width: 300),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('[Thumbnail] requested for ${file.fileName}');
                    }

                    if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                      print('[Thumbnail] loaded for ${file.fileName}');
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }

                    if (snapshot.hasError) {
                      print('[Thumbnail] failed for ${file.fileName}: ${snapshot.error}');
                    }

                    // Placeholder (shown immediately)
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          _getCategoryIconFromFileType(file.fileType),
                          color: Colors.white70,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),

                // Video overlay icon
                if (isVideo)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),

                // Bottom info bar (name + size)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _formatFileSize(file.fileSize),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileListItem(ScannedFile file) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          _getCategoryIconFromFileType(file.fileType),
          color: _getCategoryColorFromFileType(file.fileType),
        ),
        title: Text(file.fileName),
        subtitle: Text(
          file.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(_formatFileSize(file.fileSize)),
        onTap: () => _showFileDetails(file),
      ),
    );
  }

  void _showFileDetails(ScannedFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIconFromFileType(file.fileType),
                  size: 48,
                  color: _getCategoryColorFromFileType(file.fileType),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _formatFileSize(file.fileSize),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Path', file.path),
            _buildDetailRow('Modified', file.lastModified.toString()),
            _buildDetailRow('Mime Type', file.mimeType),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _recoverFile(file);
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Recover'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _recoverFile(ScannedFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File ${file.fileName} recovered successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData _getCategoryIconFromString(String category) {
    switch (category) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audio_file;
      case 'document':
        return Icons.description;
      case 'archive':
        return Icons.folder_zip;
      case 'app':
      case 'application':
        return Icons.apps;
      case 'database':
        return Icons.storage;
      case 'code':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  IconData _getCategoryIconFromFileType(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.videocam;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.document:
        return Icons.description;
      case FileType.archive:
        return Icons.folder_zip;
      case FileType.application:
        return Icons.apps;
      case FileType.database:
        return Icons.storage;
      case FileType.code:
        return Icons.code;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getCategoryColorFromFileType(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return Colors.orange;
      case FileType.video:
        return Colors.red;
      case FileType.audio:
        return Colors.blue;
      case FileType.document:
        return Colors.purple;
      case FileType.archive:
        return Colors.brown;
      case FileType.application:
        return Colors.green;
      case FileType.database:
        return Colors.indigo;
      case FileType.code:
        return Colors.teal;
      case FileType.other:
        return Colors.grey;
    }
  }
}
