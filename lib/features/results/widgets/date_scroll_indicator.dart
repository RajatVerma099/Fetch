import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A floating date indicator that shows the month and year while scrolling
class DateScrollIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final List<ScannedFileForScroll> sortedFiles;
  final Duration hideDuration;

  const DateScrollIndicator({
    super.key,
    required this.scrollController,
    required this.sortedFiles,
    this.hideDuration = const Duration(seconds: 2),
  });

  @override
  State<DateScrollIndicator> createState() => _DateScrollIndicatorState();
}

class _DateScrollIndicatorState extends State<DateScrollIndicator>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  DateTime? _currentDate;
  bool _isVisible = false;
  late final _dateFormat = DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.sortedFiles.isEmpty) return;

    // Calculate which file is visible based on scroll position
    final position = widget.scrollController.position;
    
    // Estimate item height (assuming roughly 80 pixels per item in a list)
    // This is an approximation; adjust based on your actual list item height
    const itemHeight = 80.0;
    final visibleItemIndex = (position.pixels / itemHeight).toInt();

    if (visibleItemIndex >= 0 && visibleItemIndex < widget.sortedFiles.length) {
      final file = widget.sortedFiles[visibleItemIndex];
      final date = DateTime.fromMillisecondsSinceEpoch(file.lastModified);
      
      if (_currentDate == null || 
          _currentDate!.year != date.year || 
          _currentDate!.month != date.month) {
        setState(() {
          _currentDate = date;
        });
      }
    }

    // Show indicator
    if (!_isVisible) {
      _isVisible = true;
      _fadeController.forward();
      _slideController.forward();
    }

    // Hide after delay
    Future.delayed(widget.hideDuration, () {
      if (mounted && _isVisible) {
        _fadeController.reverse();
        _slideController.reverse();
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentDate == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 100,
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: Transform.translate(
              offset: Offset(_slideController.value * 30, 0),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _dateFormat.format(_currentDate!),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for scrollable files
class ScannedFileForScroll {
  final int id;
  final String fileName;
  final int fileSize;
  final int lastModified;

  ScannedFileForScroll({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.lastModified,
  });
}
