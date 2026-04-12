// lib/core/services/file_picker_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Utility service for picking and validating files (PDFs, images) for upload.
//
// Features:
//   • Pick PDF files with validation
//   • Validate file type and size
//   • User-friendly error messages
//   • Consistent error handling across app
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

class FilePickerService {
  // ── File Size Limits (in bytes) ────────────────────────────────────────────
  static const int maxResumeSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxAvatarSizeBytes = 2 * 1024 * 1024; // 2MB

  // ── Allowed Extensions ─────────────────────────────────────────────────────
  static const Set<String> allowedResumeExtensions = {'pdf'};
  static const Set<String> allowedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
  };

  /// Validates if a file is a PDF with size < 5MB.
  ///
  /// Returns:
  ///   - null if validation passes
  ///   - Error message string if validation fails
  ///
  /// Checks:
  ///   - File exists
  ///   - Extension is .pdf
  ///   - File size < 5MB
  ///
  /// Example:
  /// ```dart
  /// final error = FilePickerService.validateResume(file);
  /// if (error != null) {
  ///   showSnackBar(error);
  ///   return;
  /// }
  /// // File is valid, proceed with upload
  /// ```
  static String? validateResume(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return 'File does not exist';
    }

    // Check file extension
    final filename = file.path.toLowerCase();
    final extension = _getFileExtension(filename);

    if (!allowedResumeExtensions.contains(extension)) {
      return 'Only PDF files are allowed (got: .$extension)';
    }

    // Check file size
    final sizeBytes = file.lengthSync();
    if (sizeBytes > maxResumeSizeBytes) {
      final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      return 'File size is $sizeMB MB. Maximum allowed is 5 MB.';
    }

    return null; // Valid
  }

  /// Validates if a file is an allowed image with size < 2MB.
  ///
  /// Returns:
  ///   - null if validation passes
  ///   - Error message string if validation fails
  ///
  /// Allowed formats: jpg, jpeg, png, gif
  static String? validateImage(File file) {
    if (!file.existsSync()) {
      return 'Image file does not exist';
    }

    final filename = file.path.toLowerCase();
    final extension = _getFileExtension(filename);

    if (!allowedImageExtensions.contains(extension)) {
      return 'Only image files allowed: JPG, PNG, GIF (got: .$extension)';
    }

    final sizeBytes = file.lengthSync();
    if (sizeBytes > maxAvatarSizeBytes) {
      final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      return 'Image size is $sizeMB MB. Maximum allowed is 2 MB.';
    }

    return null; // Valid
  }

  /// Extracts file extension from a file path.
  ///
  /// Example: "/path/to/file.pdf" → "pdf"
  static String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot + 1).toLowerCase();
  }

  /// Gets a human-readable file size string.
  ///
  /// Example: 1024 → "1 KB", 1048576 → "1 MB"
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Gets the file name from a file path.
  ///
  /// Example: "/path/to/resume.pdf" → "resume.pdf"
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
