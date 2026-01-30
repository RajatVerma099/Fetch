import 'package:flutter/material.dart';
import '../bloc/results_bloc.dart';
import '../../../core/database/database.dart';

class FilterSheet extends StatefulWidget {
  final ResultsFilter currentFilter;
  final Function(ResultsFilter) onApply;

  const FilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FileType? _selectedType;
  late int? _minConfidence;
  late SortOption _sortBy;
  late bool _showDuplicatesOnly;

  final _sizeOptions = <int?>[null, 100 * 1024, 1024 * 1024, 10 * 1024 * 1024];
  int? _minSize;
  int? _maxSize;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter.fileType;
    _minConfidence = widget.currentFilter.minConfidence;
    _sortBy = widget.currentFilter.sortBy;
    _showDuplicatesOnly = widget.currentFilter.showDuplicatesOnly;
    _minSize = widget.currentFilter.minSize;
    _maxSize = widget.currentFilter.maxSize;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Filter options
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // File Type
                  _buildSectionTitle('File Type'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip(null, 'All'),
                      _buildTypeChip(FileType.image, 'Images'),
                      _buildTypeChip(FileType.video, 'Videos'),
                      _buildTypeChip(FileType.audio, 'Audio'),
                      _buildTypeChip(FileType.document, 'Documents'),
                      _buildTypeChip(FileType.archive, 'Archives'),
                      _buildTypeChip(FileType.application, 'Apps'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Minimum Confidence
                  _buildSectionTitle('Minimum Confidence'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildConfidenceChip(null, 'Any'),
                      _buildConfidenceChip(50, '50%+'),
                      _buildConfidenceChip(75, '75%+'),
                      _buildConfidenceChip(90, '90%+'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sort By
                  _buildSectionTitle('Sort By'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip(SortOption.dateDesc, 'Newest'),
                      _buildSortChip(SortOption.dateAsc, 'Oldest'),
                      _buildSortChip(SortOption.sizeDesc, 'Largest'),
                      _buildSortChip(SortOption.sizeAsc, 'Smallest'),
                      _buildSortChip(SortOption.confidenceDesc, 'Best Match'),
                      _buildSortChip(SortOption.nameAsc, 'Name'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Special filters
                  _buildSectionTitle('Special'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Show duplicates only'),
                    subtitle: const Text('Files with matching hashes'),
                    value: _showDuplicatesOnly,
                    onChanged: (value) {
                      setState(() {
                        _showDuplicatesOnly = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildTypeChip(FileType? type, String label) {
    final isSelected = _selectedType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildConfidenceChip(int? confidence, String label) {
    final isSelected = _minConfidence == confidence;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _minConfidence = selected ? confidence : null;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildSortChip(SortOption option, String label) {
    final isSelected = _sortBy == option;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = option;
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _minConfidence = null;
      _sortBy = SortOption.dateDesc;
      _showDuplicatesOnly = false;
      _minSize = null;
      _maxSize = null;
    });
  }

  void _applyFilters() {
    widget.onApply(ResultsFilter(
      fileType: _selectedType,
      minConfidence: _minConfidence,
      sortBy: _sortBy,
      showDuplicatesOnly: _showDuplicatesOnly,
      minSize: _minSize,
      maxSize: _maxSize,
    ));
  }
}
