import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/database.dart';

/// Smart folder browser widget for browsing files by directory structure
class FolderBrowser extends StatefulWidget {
  final List<ScannedFile> allFiles;
  final Function(ScannedFile) onFileTap;

  const FolderBrowser({
    super.key,
    required this.allFiles,
    required this.onFileTap,
  });

  @override
  State<FolderBrowser> createState() => _FolderBrowserState();
}

class _FolderBrowserState extends State<FolderBrowser> {
  late String _currentPath;
  final List<String> _navigationStack = [];

  @override
  void initState() {
    super.initState();
    _currentPath = '/storage/emulated/0';
  }

  /// Get folders at current path from files
  Map<String, List<ScannedFile>> _getFoldersAndFiles() {
    final folders = <String, List<ScannedFile>>{};
    final files = <ScannedFile>[];

    for (final file in widget.allFiles) {
      final filePath = file.path;
      
      // Only show files in current path or immediate subdirectories
      if (!filePath.startsWith(_currentPath)) continue;

      final relativePath = filePath.replaceFirst(_currentPath, '').removeLeading('/');
      final parts = relativePath.split('/');

      if (parts.isEmpty || parts[0].isEmpty) continue;

      if (parts.length == 1) {
        // File in current directory
        files.add(file);
      } else {
        // File in subdirectory
        final folderName = parts[0];
        folders.putIfAbsent(folderName, () => []);
        folders[folderName]!.add(file);
      }
    }

    return {...folders, ...{'__files__': files}};
  }

  void _navigateToFolder(String folderName) {
    _navigationStack.add(_currentPath);
    setState(() {
      if (_currentPath.endsWith('/')) {
        _currentPath += folderName;
      } else {
        _currentPath += '/$folderName';
      }
    });
  }

  void _navigateBack() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _currentPath = _navigationStack.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foldersAndFiles = _getFoldersAndFiles();
    final folders = foldersAndFiles.entries
        .where((e) => e.key != '__files__')
        .toList();
    final files = foldersAndFiles['__files__'] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb navigation
          if (_navigationStack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _navigationStack.clear();
                              _currentPath = '/storage/emulated/0';
                            });
                          },
                          child: Chip(
                            label: const Text('Home'),
                            onDeleted: null,
                            backgroundColor:
                                colorScheme.primaryContainer,
                          ),
                        ),
                        ...List.generate(
                          _navigationStack.length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  final removedCount =
                                      _navigationStack.length - i - 1;
                                  _currentPath = _navigationStack[i];
                                  _navigationStack.removeRange(
                                      i + 1, _navigationStack.length);
                                });
                              },
                              child: Chip(
                                label: Text(_navigationStack[i]
                                    .split('/')
                                    .last),
                                onDeleted: null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: $_currentPath',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Folders grid
          if (folders.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Folders',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folderName = folders[index].key;
                final folderFiles = folders[index].value;

                return GestureDetector(
                  onTap: () => _navigateToFolder(folderName),
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          folderName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${folderFiles.length} files',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Files in current directory
          if (files.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Files',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];

                return ListTile(
                  leading: _buildFileIcon(file),
                  title: Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${(file.fileSize / 1024).toStringAsFixed(1)} KB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => widget.onFileTap(file),
                  trailing: Icon(
                    Icons.info_outline,
                    color: colorScheme.outline,
                    size: 18,
                  ),
                );
              },
            ),
          ],

          // Empty state
          if (folders.isEmpty && files.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No files found in this folder',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(ScannedFile file) {
    if (file.fileType == FileType.image) {
      return Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      );
    } else if (file.fileType == FileType.video) {
      return Icon(
        Icons.video_library,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      return Icon(
        Icons.description,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }
}

extension on String {
  String removeLeading(String char) {
    if (startsWith(char)) {
      return substring(char.length);
    }
    return this;
  }
}
