/// File signature definitions for magic byte detection
class FileSignatures {
  /// JPEG image signature
  static const List<int> jpeg = [0xFF, 0xD8, 0xFF];

  /// PNG image signature
  static const List<int> png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

  /// GIF87a signature
  static const List<int> gif87a = [0x47, 0x49, 0x46, 0x38, 0x37, 0x61];

  /// GIF89a signature
  static const List<int> gif89a = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61];

  /// WebP image signature (RIFF....WEBP)
  static const List<int> webpPrefix = [0x52, 0x49, 0x46, 0x46];
  static const List<int> webpSuffix = [0x57, 0x45, 0x42, 0x50];

  /// BMP image signature
  static const List<int> bmp = [0x42, 0x4D];

  /// HEIC/HEIF container prefix (ftyp)
  static const List<int> ftypPrefix = [0x66, 0x74, 0x79, 0x70];

  /// MP4 container (ftyp at offset 4)
  static const List<int> mp4Ftyp = [0x66, 0x74, 0x79, 0x70];

  /// AVI container
  static const List<int> aviPrefix = [0x52, 0x49, 0x46, 0x46];
  static const List<int> aviSuffix = [0x41, 0x56, 0x49, 0x20];

  /// MKV/WebM container
  static const List<int> matroska = [0x1A, 0x45, 0xDF, 0xA3];

  /// MOV container
  static const List<int> movFtyp = [0x66, 0x74, 0x79, 0x70, 0x71, 0x74];

  /// 3GP container
  static const List<int> threeGP = [0x66, 0x74, 0x79, 0x70, 0x33, 0x67];

  /// PDF document
  static const List<int> pdf = [0x25, 0x50, 0x44, 0x46]; // %PDF

  /// ZIP archive
  static const List<int> zip = [0x50, 0x4B, 0x03, 0x04];

  /// ZIP empty archive
  static const List<int> zipEmpty = [0x50, 0x4B, 0x05, 0x06];

  /// RAR archive
  static const List<int> rar = [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07];

  /// 7-Zip archive
  static const List<int> sevenZip = [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C];

  /// MP3 audio (ID3 tag)
  static const List<int> mp3Id3 = [0x49, 0x44, 0x33]; // ID3

  /// MP3 audio (frame sync)
  static const List<int> mp3Sync = [0xFF, 0xFB];
  static const List<int> mp3SyncAlt = [0xFF, 0xFA];

  /// WAV audio
  static const List<int> wavPrefix = [0x52, 0x49, 0x46, 0x46];
  static const List<int> wavSuffix = [0x57, 0x41, 0x56, 0x45];

  /// FLAC audio
  static const List<int> flac = [0x66, 0x4C, 0x61, 0x43]; // fLaC

  /// OGG container
  static const List<int> ogg = [0x4F, 0x67, 0x67, 0x53]; // OggS

  /// Microsoft Office (old format - compound document)
  static const List<int> msOfficeOld = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1];

  /// Microsoft Office (new format - OOXML, essentially ZIP)
  // Uses ZIP signature

  /// SQLite database
  static const List<int> sqlite = [
    0x53,
    0x51,
    0x4C,
    0x69,
    0x74,
    0x65,
    0x20,
    0x66,
    0x6F,
    0x72,
    0x6D,
    0x61,
    0x74,
    0x20,
    0x33,
    0x00
  ]; // "SQLite format 3\0"

  /// Minimum file sizes for different types (to filter out corrupted files)
  static const Map<String, int> minimumSizes = {
    'image/jpeg': 1024, // 1KB minimum for JPEG
    'image/png': 67, // Minimum PNG file
    'image/gif': 35, // Minimum GIF file
    'image/webp': 30, // Minimum WebP file
    'image/bmp': 26, // Minimum BMP header
    'image/heic': 1024, // 1KB minimum for HEIC
    'video/mp4': 4096, // 4KB minimum for MP4
    'video/quicktime': 4096, // 4KB minimum for MOV
    'video/x-msvideo': 4096, // 4KB minimum for AVI
    'video/webm': 1024, // 1KB minimum for WebM
    'video/x-matroska': 1024, // 1KB minimum for MKV
    'video/3gpp': 1024, // 1KB minimum for 3GP
    'application/pdf': 1024, // 1KB minimum for PDF
    'application/zip': 22, // Minimum ZIP file
    'audio/mpeg': 128, // Minimum MP3
    'audio/wav': 44, // Minimum WAV header
    'audio/flac': 42, // Minimum FLAC header
    'audio/ogg': 28, // Minimum OGG header
  };

  /// Check if bytes match a signature
  static bool matchesSignature(List<int> bytes, List<int> signature, [int offset = 0]) {
    if (bytes.length < offset + signature.length) return false;
    for (int i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature[i]) return false;
    }
    return true;
  }

  /// Detect file type from header bytes
  static FileTypeResult? detectType(List<int> bytes, int fileSize) {
    if (bytes.isEmpty) return null;

    // Images
    if (matchesSignature(bytes, jpeg)) {
      return FileTypeResult('image/jpeg', 'jpg', 'image');
    }
    if (matchesSignature(bytes, png)) {
      return FileTypeResult('image/png', 'png', 'image');
    }
    if (matchesSignature(bytes, gif87a) || matchesSignature(bytes, gif89a)) {
      return FileTypeResult('image/gif', 'gif', 'image');
    }
    if (matchesSignature(bytes, bmp)) {
      return FileTypeResult('image/bmp', 'bmp', 'image');
    }
    if (matchesSignature(bytes, webpPrefix) &&
        bytes.length >= 12 &&
        matchesSignature(bytes, webpSuffix, 8)) {
      return FileTypeResult('image/webp', 'webp', 'image');
    }

    // Videos - check for ftyp box (common for MP4, MOV, 3GP, HEIC)
    if (bytes.length >= 12) {
      // ftyp is usually at offset 4 (after 4-byte size)
      if (matchesSignature(bytes, ftypPrefix, 4)) {
        final brand = bytes.sublist(8, 12);
        final brandStr = String.fromCharCodes(brand);

        // HEIC/HEIF images
        if (brandStr.contains('heic') ||
            brandStr.contains('mif1') ||
            brandStr.contains('heif')) {
          return FileTypeResult('image/heic', 'heic', 'image');
        }

        // MP4 variants
        if (brandStr.contains('isom') ||
            brandStr.contains('mp4') ||
            brandStr.contains('M4V') ||
            brandStr.contains('avc1')) {
          return FileTypeResult('video/mp4', 'mp4', 'video');
        }

        // QuickTime MOV
        if (brandStr.contains('qt')) {
          return FileTypeResult('video/quicktime', 'mov', 'video');
        }

        // 3GP
        if (brandStr.contains('3gp') || brandStr.contains('3g2')) {
          return FileTypeResult('video/3gpp', '3gp', 'video');
        }

        // Default to MP4 for unknown ftyp brands
        return FileTypeResult('video/mp4', 'mp4', 'video');
      }
    }

    // AVI
    if (matchesSignature(bytes, aviPrefix) &&
        bytes.length >= 12 &&
        matchesSignature(bytes, aviSuffix, 8)) {
      return FileTypeResult('video/x-msvideo', 'avi', 'video');
    }

    // MKV/WebM
    if (matchesSignature(bytes, matroska)) {
      // WebM is a subset of MKV, check for webm marker if possible
      return FileTypeResult('video/x-matroska', 'mkv', 'video');
    }

    // Documents
    if (matchesSignature(bytes, pdf)) {
      return FileTypeResult('application/pdf', 'pdf', 'document');
    }

    // Archives
    if (matchesSignature(bytes, zip) || matchesSignature(bytes, zipEmpty)) {
      // Could be DOCX, XLSX, PPTX, etc.
      return FileTypeResult('application/zip', 'zip', 'document');
    }
    if (matchesSignature(bytes, rar)) {
      return FileTypeResult('application/x-rar-compressed', 'rar', 'document');
    }
    if (matchesSignature(bytes, sevenZip)) {
      return FileTypeResult('application/x-7z-compressed', '7z', 'document');
    }

    // Audio
    if (matchesSignature(bytes, mp3Id3) ||
        matchesSignature(bytes, mp3Sync) ||
        matchesSignature(bytes, mp3SyncAlt)) {
      return FileTypeResult('audio/mpeg', 'mp3', 'audio');
    }
    if (matchesSignature(bytes, wavPrefix) &&
        bytes.length >= 12 &&
        matchesSignature(bytes, wavSuffix, 8)) {
      return FileTypeResult('audio/wav', 'wav', 'audio');
    }
    if (matchesSignature(bytes, flac)) {
      return FileTypeResult('audio/flac', 'flac', 'audio');
    }
    if (matchesSignature(bytes, ogg)) {
      return FileTypeResult('audio/ogg', 'ogg', 'audio');
    }

    // MS Office old format
    if (matchesSignature(bytes, msOfficeOld)) {
      return FileTypeResult(
          'application/vnd.ms-office', 'doc', 'document');
    }

    return null;
  }
}

/// Result of file type detection
class FileTypeResult {
  final String mimeType;
  final String extension;
  final String category; // 'image', 'video', 'audio', 'document'

  const FileTypeResult(this.mimeType, this.extension, this.category);

  @override
  String toString() => 'FileTypeResult($mimeType, $extension, $category)';
}
