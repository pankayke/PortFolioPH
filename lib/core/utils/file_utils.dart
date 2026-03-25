import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract final class FileUtils {
  static const Uuid _uuid = Uuid();

  static Future<Directory> getProjectsImageDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(baseDir.path, 'projects', 'images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  static Future<Directory> getCertificatesImageDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(
      path.join(baseDir.path, 'certifications', 'images'),
    );
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  static String generateUniqueFilename({required String extension}) {
    final safeExtension = extension.startsWith('.')
        ? extension.toLowerCase()
        : '.${extension.toLowerCase()}';

    return '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$safeExtension';
  }

  static String fileExtension(String filePath) {
    final ext = path.extension(filePath).trim();
    return ext.isEmpty ? '.jpg' : ext;
  }
}
