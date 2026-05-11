import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/file_utils.dart';

class ImageStorageService {
  final ImagePicker _picker;

  ImageStorageService({ImagePicker? imagePicker})
    : _picker = imagePicker ?? ImagePicker();

  Future<List<String>> pickAndStoreImages({
    required List<String> existingPaths,
    int maxImages = AppConstants.maxProjectImages,
  }) async {
    final remainingSlots = maxImages - existingPaths.length;
    if (remainingSlots <= 0) return List.unmodifiable(existingPaths);

    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
      limit: remainingSlots,
    );

    if (pickedFiles.isEmpty) return List.unmodifiable(existingPaths);

    final savedPaths = <String>[...existingPaths];

    for (final file in pickedFiles) {
      final storedPath = await _storeXFile(file);
      if (storedPath != null) {
        savedPaths.add(storedPath);
      }
    }

    return List.unmodifiable(savedPaths);
  }

  Future<String?> _storeXFile(XFile xfile) async {
    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      if (bytes.length > AppConstants.maxProjectImageBytes) {
        debugPrint(
          'Skipping image ${xfile.path}: exceeds ${AppConstants.maxProjectImageBytes} bytes',
        );
        return null;
      }

      final mimeType = _guessMimeType(xfile.path);
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    }

    final source = File(xfile.path);
    if (!await source.exists()) return null;

    final directory = await FileUtils.getProjectsImageDirectory();
    final extension = FileUtils.fileExtension(xfile.path);
    final filename = FileUtils.generateUniqueFilename(extension: extension);
    final destinationPath = path.join(directory.path, filename);

    final bytes = await source.readAsBytes();
    if (bytes.length > AppConstants.maxProjectImageBytes) {
      debugPrint(
        'Skipping image ${xfile.path}: exceeds ${AppConstants.maxProjectImageBytes} bytes',
      );
      return null;
    }

    final destination = File(destinationPath);
    await destination.writeAsBytes(bytes, flush: true);
    return destinationPath;
  }

  Future<void> deleteImage(String imagePath) async {
    if (imagePath.startsWith('data:image/')) {
      return;
    }

    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _guessMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
