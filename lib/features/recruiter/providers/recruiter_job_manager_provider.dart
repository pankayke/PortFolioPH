// lib/features/recruiter/providers/recruiter_job_manager_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages recruiter job listing and CRUD operations.
// Handles loading state, error state, and data persistence.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';

class RecruiterJobManagerProvider extends ChangeNotifier {
  final RecruiterRepositoryImpl _repository;

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  int _currentPage = 1;
  final int _totalPages = 1;
  bool _hasMore = true;
  String? _searchQuery;

  // ─────── Getters ──────────────────────────────────────────────────────────

  List<Job> get jobs => List.unmodifiable(_jobs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  String? get searchQuery => _searchQuery;

  int get activeJobCount => _jobs
      .where((j) => j.status == 'approved' || j.status == 'pending')
      .length;
  int get openJobCount => _jobs
      .where((j) => j.status == 'approved' || j.status == 'pending')
      .length;
  int get draftJobCount => _jobs.where((j) => j.status == 'draft').length;
  int get closedJobCount => _jobs.where((j) => j.status == 'closed').length;

  // ─────── Constructor ───────────────────────────────────────────────────────

  RecruiterJobManagerProvider(this._repository);

  // ─────── Public Methods ────────────────────────────────────────────────────

  /// Load all jobs (with pagination and filtering)
  Future<void> loadJobs({
    int page = 1,
    String? status,
    String? search,
    bool refresh = false,
  }) async {
    if (isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    _currentPage = page;
    _selectedStatus = status;
    _searchQuery = search;

    try {
      final loadedJobs = await _repository.getJobs(
        page: page,
        status: status,
        search: search,
      );

      if (refresh || page == 1) {
        _jobs = loadedJobs;
      } else {
        _jobs.addAll(loadedJobs);
      }

      _hasMore = loadedJobs.isNotEmpty;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load next page of jobs
  Future<void> loadMoreJobs() async {
    if (!hasMore || isLoading) return;
    await loadJobs(page: _currentPage + 1);
  }

  /// Refresh job list
  Future<void> refreshJobs() async {
    await loadJobs(refresh: true);
  }

  /// Get a single job by ID
  Future<Job> getJob(int jobId) async {
    try {
      return await _repository.getJobById(jobId);
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Create a new job
  Future<Job> createJob(CreateJobRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newJob = await _repository.createJob(request);
      _jobs.insert(0, newJob); // Add to top of list
      _isLoading = false;
      notifyListeners();
      return newJob;
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing job
  Future<Job> updateJob(int jobId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedJob = await _repository.updateJob(jobId, data);

      // Update in local list
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }

      _isLoading = false;
      notifyListeners();
      return updatedJob;
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a job
  Future<void> deleteJob(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteJob(jobId);
      _jobs.removeWhere((j) => j.id == jobId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Close a job (stop accepting applications)
  Future<void> closeJob(int jobId) async {
    try {
      await _repository.closeJob(jobId);
      await updateJob(jobId, {'status': 'closed'});
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Filter jobs by status
  Future<void> filterByStatus(String? status) async {
    await loadJobs(status: status, refresh: true);
  }

  /// Search jobs by title/description
  Future<void> searchJobs(String query) async {
    if (query.isEmpty) {
      await loadJobs(refresh: true);
    } else {
      await loadJobs(search: query, refresh: true);
    }
  }

  // ─────── Private Methods ───────────────────────────────────────────────────

  String _handleError(dynamic error) {
    if (error is ApiException) return error.message;
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return error?.toString() ?? 'Unable to complete job action.';
  }
}
