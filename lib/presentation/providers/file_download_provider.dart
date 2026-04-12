// lib/presentation/providers/file_download_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Provider for managing file downloads across the app.
// Handles progress tracking, error handling, and download state.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/services/file_download_service.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';

enum DownloadState {
  idle,
  downloading,
  success,
  error,
}

class FileDownloadProvider extends ChangeNotifier {
  final FileDownloadService _downloadService;

  DownloadState _state = DownloadState.idle;
  int _downloadedBytes = 0;
  int _totalBytes = 0;
  String? _errorMessage;
  String? _lastDownloadPath;

  DownloadState get state => _state;
  int get downloadedBytes => _downloadedBytes;
  int get totalBytes => _totalBytes;
  String? get errorMessage => _errorMessage;
  String? get lastDownloadPath => _lastDownloadPath;

  double get downloadProgress => _totalBytes <= 0 ? 0 : _downloadedBytes / _totalBytes;
  bool get isDownloading => _state == DownloadState.downloading;

  FileDownloadProvider(this._downloadService);

  void _updateProgress(int received, int total) {
    _downloadedBytes = received;
    _totalBytes = total;
    notifyListeners();
  }

  void _setState(DownloadState state, {String? errorMessage}) {
    _state = state;
    _errorMessage = errorMessage;
    if (state != DownloadState.downloading) {
      _downloadedBytes = 0;
      _totalBytes = 0;
    }
    notifyListeners();
  }

  /// Download user's own CV
  Future<void> downloadMyCV() async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadUserCV(
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('CV downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('CV download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download CV');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Download CV for a specific user
  Future<void> downloadUserCVById(int userId) async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadUserCVById(
        userId,
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('User CV downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('User CV download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download CV');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Download CV for an applicant
  Future<void> downloadApplicantCV(int applicationId) async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadApplicantCV(
        applicationId,
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('Applicant CV downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('Applicant CV download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download CV');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Export users to Excel/CSV
  Future<void> downloadUserExport(String format) async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadExport(
        'users',
        format,
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('Users export downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('Users export download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download export');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Export jobs to Excel/CSV
  Future<void> downloadJobsExport(String format) async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadExport(
        'jobs',
        format,
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('Jobs export downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('Jobs export download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download export');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Export applications to Excel/CSV
  Future<void> downloadApplicationsExport(String format) async {
    _setState(DownloadState.downloading);
    try {
      final filePath = await _downloadService.downloadExport(
        'applications',
        format,
        onProgress: _updateProgress,
      );
      _lastDownloadPath = filePath;
      _setState(DownloadState.success);
      AppLogger.success('Applications export downloaded: $filePath');
    } on ServerException catch (e) {
      _setState(DownloadState.error, errorMessage: e.message);
      AppLogger.error('Applications export download failed: ${e.message}');
    } catch (e) {
      _setState(DownloadState.error, errorMessage: 'Failed to download export');
      AppLogger.error('Unexpected error: $e');
    }
  }

  /// Reset state to idle
  Future<void> reset() async {
    _setState(DownloadState.idle);
  }
}
