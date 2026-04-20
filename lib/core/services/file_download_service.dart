// lib/core/services/file_download_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service for downloading files (CVs, exports, etc.) from the server.
// Handles file saving, progress tracking, and error handling.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';

typedef DownloadProgressCallback = void Function(int received, int total);

class FileDownloadService {
  static const String tokenKey = 'auth_token';
  static const Duration kConnectTimeout = Duration(seconds: 30);
  static const Duration kReceiveTimeout = Duration(minutes: 5);

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  FileDownloadService(this._secureStorage) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: kConnectTimeout,
        receiveTimeout: kReceiveTimeout,
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest));
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  /// Download a file from the server
  /// Returns the file path where it was saved
  Future<String> downloadFile(
    String endpoint, {
    String? filename,
    DownloadProgressCallback? onProgress,
  }) async {
    try {
      // Determine save directory
      Directory saveDir;
      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile, use downloads directory or temp
        try {
          saveDir = Directory('/storage/emulated/0/Download');
          if (!await saveDir.exists()) {
            saveDir = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          saveDir = await getApplicationDocumentsDirectory();
        }
      } else {
        // For web/desktop
        saveDir = await getApplicationDocumentsDirectory();
      }

      // Prepare filename
      final finalFilename = filename ?? _extractFilenameFromUrl(endpoint);
      final filePath = '${saveDir.path}/$finalFilename';

      AppLogger.log('Starting download: $endpoint → $filePath');

      var lastLoggedPercent = -1;

      // Download with progress
      final response = await _dio.download(
        endpoint,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percentage = ((received / total) * 100).floor();
            if (percentage ~/ 10 > lastLoggedPercent ~/ 10 ||
                percentage == 100) {
              lastLoggedPercent = percentage;
              AppLogger.debug('Download progress: $percentage%');
            }
            onProgress?.call(received, total);
          }
        },
      );

      if (response.statusCode != 200) {
        throw ServerException('Download failed: ${response.statusCode}');
      }

      AppLogger.success('File downloaded successfully: $filePath');
      return filePath;
    } on DioException catch (e) {
      AppLogger.error('Download error: ${e.message}');
      throw ServerException('Failed to download file: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected download error: $e');
      throw ServerException('Unexpected error during download: $e');
    }
  }

  /// Download CV for current user
  Future<String> downloadUserCV({DownloadProgressCallback? onProgress}) async {
    return downloadFile(
      '/profile/cv',
      filename: 'my_cv.pdf',
      onProgress: onProgress,
    );
  }

  /// Download CV for a specific user (admin/recruiter)
  Future<String> downloadUserCVById(
    int userId, {
    DownloadProgressCallback? onProgress,
  }) async {
    return downloadFile(
      '/users/$userId/cv',
      filename: 'cv_user_$userId.pdf',
      onProgress: onProgress,
    );
  }

  /// Download CV for an applicant
  Future<String> downloadApplicantCV(
    int applicationId, {
    DownloadProgressCallback? onProgress,
  }) async {
    return downloadFile(
      '/applications/$applicationId/cv',
      filename: 'applicant_cv_$applicationId.pdf',
      onProgress: onProgress,
    );
  }

  /// Download export file (Excel/CSV)
  Future<String> downloadExport(
    String exportType, // 'users', 'jobs', 'applications'
    String format, { // 'xlsx' or 'csv'
    DownloadProgressCallback? onProgress,
  }) async {
    final endpoint = '/admin/$exportType/export/$format';
    final timestamp = DateTime.now()
        .toIso8601String()
        .split('.')[0]
        .replaceAll(':', '-');
    final filename = '${exportType}_export_$timestamp.$format';

    return downloadFile(endpoint, filename: filename, onProgress: onProgress);
  }

  /// Extract filename from URL
  String _extractFilenameFromUrl(String url) {
    final uri = Uri.parse(url);
    final lastSegment = uri.pathSegments.last;
    return lastSegment.isNotEmpty ? lastSegment : 'download';
  }

  /// Check if file exists at path
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete a downloaded file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.log('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error deleting file: $e');
      return false;
    }
  }
}
