import 'dart:typed_data';

import 'package:portfolioph/core/utils/file_download_helper_stub.dart'
    if (dart.library.html) 'package:portfolioph/core/utils/file_download_helper_web.dart'
    as impl;

class FileDownloadHelper {
  static Future<bool> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) {
    return impl.saveBytes(bytes: bytes, fileName: fileName, mimeType: mimeType);
  }
}
