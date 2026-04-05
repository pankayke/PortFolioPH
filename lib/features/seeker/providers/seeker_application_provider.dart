// lib/features/seeker/providers/seeker_application_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages seeker's job applications with tracking and status updates.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/services/error_handler.dart';
import 'package:portfolioph/core/services/toast_service.dart';
import 'package:portfolioph/features/seeker/models/seeker_application_model.dart';
import 'package:portfolioph/features/seeker/repositories/seeker_repository_impl.dart';

abstract class SeekerApplicationRepository {
  Future<List<SeekerApplication>> getApplications({
    int page,
    String? status,
    String sortBy,
  });

  Future<SeekerApplication> getApplicationById(int applicationId);

  Future<SeekerApplication> applyForJob(int jobId);

  Future<void> withdrawApplication(int applicationId);

  Future<void> updateResumeForApplication(int applicationId, String resumeFile);
}

class SeekerApplicationProvider extends ChangeNotifier {
  final SeekerApplicationRepositoryImpl _repository;

  List<SeekerApplication> _applications = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  int _currentPage = 1;
  bool _hasMore = true;
  String _sortBy = 'applied_at';

  // ─────── Getters ──────────────────────────────────────────────────────────

  List<SeekerApplication> get applications => List.unmodifiable(_applications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  int get applicationCount => _applications.length;
  int get pendingCount =>
      _applications.where((a) => a.isApplied || a.isReviewing).length;
  int get shortlistedCount =>
      _applications.where((a) => a.isShortlisted).length;
  int get acceptedCount => _applications.where((a) => a.isAccepted).length;
  int get rejectedCount => _applications.where((a) => a.isRejected).length;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  // ─────── Constructor ───────────────────────────────────────────────────────

  SeekerApplicationProvider(this._repository);

  // ─────── Public Methods ────────────────────────────────────────────────────

  /// Load applications with optional filtering
  Future<void> loadApplications({
    int page = 1,
    String? status,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;

    try {
      final loadedApplications = await _repository.getApplications(
        page: page,
        status: status,
        sortBy: _sortBy,
      );

      if (refresh || page == 1) {
        _applications = loadedApplications;
        _currentPage = 1;
      } else {
        _applications.addAll(loadedApplications);
        _currentPage = page;
      }

      _selectedStatus = status;
      _hasMore = loadedApplications.isNotEmpty;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      ToastService.showError('Failed to load applications. Try again.');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page of applications
  Future<void> loadMoreApplications() async {
    if (!_hasMore || _isLoading) return;
    await loadApplications(page: _currentPage + 1, status: _selectedStatus);
  }

  /// Apply for a job
  Future<SeekerApplication> applyForJob(int jobId) async {
    try {
      final application = await _repository.applyForJob(jobId);
      _applications.insert(0, application);
      ToastService.showSuccess('Application submitted successfully! ✅');
      notifyListeners();
      return application;
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      notifyListeners();
      rethrow;
    } catch (e) {
      ToastService.showError('Failed to submit application. Try again.');
      notifyListeners();
      rethrow;
    }
  }

  /// Withdraw an application
  Future<void> withdrawApplication(int applicationId) async {
    try {
      await _repository.withdrawApplication(applicationId);
      // Update status in list
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          status: 'withdrawn',
        );
        notifyListeners();
      }
      ToastService.showSuccess('Application withdrawn! ✅');
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      notifyListeners();
    } catch (e) {
      ToastService.showError('Failed to withdraw application. Try again.');
      notifyListeners();
    }
  }

  /// Filter by status
  Future<void> filterByStatus(String status) async {
    await loadApplications(status: status, refresh: true);
  }

  /// Refresh applications
  Future<void> refreshApplications() async {
    await loadApplications(refresh: true);
  }

  /// Sort applications
  Future<void> sortBy(String sortBy) async {
    _sortBy = sortBy;
    await loadApplications(refresh: true);
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get application by ID
  Future<SeekerApplication?> getApplicationById(int applicationId) async {
    try {
      return await _repository.getApplicationById(applicationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
