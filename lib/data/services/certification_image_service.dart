import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/file_utils.dart';

class CertificationImageService {
  final ImagePicker _picker;

  CertificationImageService({ImagePicker? imagePicker})
    : _picker = imagePicker ?? ImagePicker();

  Future<String?> pickAndStoreImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (pickedFile == null) return null;

    final source = File(pickedFile.path);
    if (!await source.exists()) return null;

    final bytes = await source.readAsBytes();
    if (bytes.length > AppConstants.maxCertificateImageBytes) {
      debugPrint(
        'Skipping certificate image: exceeds ${AppConstants.maxCertificateImageBytes} bytes',
      );
      return null;
    }

    final directory = await FileUtils.getCertificatesImageDirectory();
    final extension = FileUtils.fileExtension(pickedFile.path);
    final filename = FileUtils.generateUniqueFilename(extension: extension);
    final destinationPath = path.join(directory.path, filename);

    final destination = File(destinationPath);
    await destination.writeAsBytes(bytes, flush: true);
    return destinationPath;
  }

  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
