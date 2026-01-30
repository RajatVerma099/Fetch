import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'file_signatures.dart';

/// Calculator for file confidence scores
class ConfidenceScorer {
  /// Calculate confidence score for a scanned file
  /// Returns a score from 0-100
  static int calculateScore({
    required List<int> headerBytes,
    required int fileSize,
    required String? mimeType,
    required bool hasThumbnail,
    required int? width,
    required int? height,
    required int? duration,
    required bool hasValidExtension,
  }) {
    int score = 0;

    // Header validation (max 40 points)
    final headerScore = _validateHeader(headerBytes, mimeType);
    score += headerScore;

    // File size validation (max 25 points)
    final sizeScore = _validateSize(fileSize, mimeType);
    score += sizeScore;

    // Metadata completeness (max 20 points)
    final metadataScore = _validateMetadata(
      mimeType: mimeType,
      width: width,
      height: height,
      duration: duration,
      hasThumbnail: hasThumbnail,
    );
    score += metadataScore;

    // Extension match (max 15 points)
    if (hasValidExtension) {
      score += 15;
    }

    return score.clamp(0, 100);
  }

  /// Validate file header using magic bytes
  static int _validateHeader(List<int> headerBytes, String? mimeType) {
    if (headerBytes.isEmpty) return 0;

    final detected = FileSignatures.detectType(headerBytes, 0);
    if (detected == null) return 5; // Unknown but has header

    // Perfect match with detected type
    if (mimeType != null && detected.mimeType == mimeType) {
      return 40;
    }

    // Category match (image detected as image, video as video, etc.)
    if (mimeType != null) {
      final mimeCategory = mimeType.split('/').first;
      if (detected.category == mimeCategory) {
        return 30;
      }
    }

    // At least it's a valid file type
    return 20;
  }

  /// Validate file size against expected minimums
  static int _validateSize(int fileSize, String? mimeType) {
    if (mimeType == null) {
      // No MIME type, just check it's not too small
      if (fileSize > 10240) return 15; // > 10KB
      if (fileSize > 1024) return 10; // > 1KB
      return 5;
    }

    final minSize = FileSignatures.minimumSizes[mimeType];
    if (minSize == null) {
      // No minimum defined, use reasonable defaults
      if (fileSize > 10240) return 20;
      if (fileSize > 1024) return 15;
      return 10;
    }

    // Check against minimum
    if (fileSize >= minSize * 10) {
      return 25; // Well above minimum
    }
    if (fileSize >= minSize * 2) {
      return 20; // Comfortable size
    }
    if (fileSize >= minSize) {
      return 15; // Meets minimum
    }

    // Below minimum - suspicious
    return 5;
  }

  /// Validate metadata completeness
  static int _validateMetadata({
    required String? mimeType,
    required int? width,
    required int? height,
    required int? duration,
    required bool hasThumbnail,
  }) {
    int score = 0;

    if (mimeType != null) {
      final category = mimeType.split('/').first;

      if (category == 'image') {
        // Images should have dimensions
        if (width != null && height != null) {
          score += 10;
          // Reasonable dimensions
          if (width >= 10 && height >= 10 && width <= 50000 && height <= 50000) {
            score += 5;
          }
        }
      } else if (category == 'video') {
        // Videos should have dimensions and duration
        if (width != null && height != null) {
          score += 5;
        }
        if (duration != null && duration > 0) {
          score += 5;
        }
      }
    }

    // Thumbnail availability is a good sign
    if (hasThumbnail) {
      score += 5;
    }

    return score.clamp(0, 20);
  }

  /// Quick confidence assessment based on file path patterns
  static int getPathBasedConfidenceBonus(String path) {
    final lowerPath = path.toLowerCase();
    int bonus = 0;

    // Files in standard media directories
    if (lowerPath.contains('/dcim/')) bonus += 5;
    if (lowerPath.contains('/pictures/')) bonus += 5;
    if (lowerPath.contains('/camera/')) bonus += 5;
    if (lowerPath.contains('/screenshots/')) bonus += 5;

    // Files in download directory
    if (lowerPath.contains('/download/')) bonus += 3;

    // Thumbnails and cache are lower confidence
    if (lowerPath.contains('/.thumbnails/')) bonus -= 5;
    if (lowerPath.contains('/cache/')) bonus -= 3;

    // Hidden directories
    if (lowerPath.contains('/.')) bonus -= 5;

    // Temp files
    if (lowerPath.contains('/temp/') || lowerPath.contains('/tmp/')) {
      bonus -= 5;
    }

    return bonus;
  }

  /// Calculate hash of first N bytes for duplicate detection
  static String calculatePartialHash(Uint8List bytes, {int length = 4096}) {
    final bytesToHash = bytes.length > length ? bytes.sublist(0, length) : bytes;
    final digest = sha256.convert(bytesToHash);
    return digest.toString();
  }
}

/// File validation result
class FileValidationResult {
  final bool isValid;
  final String? detectedMimeType;
  final String? detectedExtension;
  final int confidenceScore;
  final List<String> issues;

  FileValidationResult({
    required this.isValid,
    this.detectedMimeType,
    this.detectedExtension,
    required this.confidenceScore,
    this.issues = const [],
  });
}
