// lib/features/seeker/providers/seeker_job_list_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages job listing for job seekers with search, filter, and pagination.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/services/error_handler.dart';
import 'package:portfolioph/core/services/toast_service.dart';
import 'package:portfolioph/features/seeker/models/seeker_job_model.dart';
import 'package:portfolioph/features/seeker/repositories/seeker_repository_impl.dart';

abstract class SeekerJobRepository {
  Future<List<SeekerJob>> getJobs({
    int page,
    String? search,
    String? category,
    String? location,
    String? employmentType,
    String? experienceLevel,
  });

  Future<SeekerJob> getJobById(int jobId);

  Future<void> saveJob(int jobId);

  Future<void> unsaveJob(int jobId);

  Future<List<SeekerJob>> getSavedJobs({int page});
}

class SeekerJobListProvider extends ChangeNotifier {
  final SeekerRepositoryImpl _repository;

  List<SeekerJob> _jobs = [];
  List<SeekerJob> _savedJobs = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedEmploymentType;
  String? _selectedExperienceLevel;
  int _currentPage = 1;
  bool _hasMore = true;

  // ─────── Getters ──────────────────────────────────────────────────────────

  List<SeekerJob> get jobs => List.unmodifiable(_jobs);
  List<SeekerJob> get savedJobs => List.unmodifiable(_savedJobs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  int get jobCount => _jobs.length;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  // ─────── Constructor ───────────────────────────────────────────────────────

  SeekerJobListProvider(this._repository);

  // ─────── Public Methods ────────────────────────────────────────────────────

  /// Load all available jobs with filtering
  Future<void> loadJobs({
    int page = 1,
    String? search,
    String? category,
    String? location,
    String? employmentType,
    String? experienceLevel,
    bool refresh = false,
  }) async {
    if (isLoading && !refresh) return;

    _isLoading = true;
    _error = null;

    try {
      final loadedJobs = await _repository.getJobs(
        page: page,
        search: search,
        category: category,
        location: location,
        employmentType: employmentType,
        experienceLevel: experienceLevel,
      );

      if (refresh || page == 1) {
        _jobs = loadedJobs;
        _currentPage = 1;
      } else {
        _jobs.addAll(loadedJobs);
        _currentPage = page;
      }

      _searchQuery = search;
      _selectedCategory = category;
      _selectedLocation = location;
      _selectedEmploymentType = employmentType;
      _selectedExperienceLevel = experienceLevel;
      _hasMore = loadedJobs.isNotEmpty;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      ToastService.showError('An error occurred. Please try again.');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page of jobs
  Future<void> loadMoreJobs() async {
    if (!_hasMore || _isLoading) return;
    await loadJobs(
      page: _currentPage + 1,
      search: _searchQuery,
      category: _selectedCategory,
      location: _selectedLocation,
      employmentType: _selectedEmploymentType,
      experienceLevel: _selectedExperienceLevel,
    );
  }

  /// Search jobs by query
  Future<void> searchJobs(String query) async {
    await loadJobs(search: query, refresh: true);
  }

  /// Filter jobs by category
  Future<void> filterByCategory(String category) async {
    await loadJobs(category: category, search: _searchQuery, refresh: true);
  }

  /// Filter jobs by location
  Future<void> filterByLocation(String location) async {
    await loadJobs(location: location, search: _searchQuery, refresh: true);
  }

  /// Save job for later
  Future<void> saveJob(int jobId) async {
    try {
      await _repository.saveJob(jobId);
      // Update the job in the list
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(isSaved: true);
        notifyListeners();
      }
      ToastService.showSuccess('Job saved! ✅');
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      notifyListeners();
    } catch (e) {
      ToastService.showError('Failed to save job. Try again.');
      notifyListeners();
    }
  }

  /// Unsave job
  Future<void> unsaveJob(int jobId) async {
    try {
      await _repository.unsaveJob(jobId);
      // Update the job in the list
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(isSaved: false);
        notifyListeners();
      }
      ToastService.showSuccess('Job removed from saved! ✅');
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      notifyListeners();
    } catch (e) {
      ToastService.showError('Failed to unsave job. Try again.');
      notifyListeners();
    }
  }

  /// Load saved jobs
  Future<void> loadSavedJobs({int page = 1, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;

    try {
      final loadedJobs = await _repository.getSavedJobs(page: page);

      if (refresh || page == 1) {
        _savedJobs = loadedJobs;
      } else {
        _savedJobs.addAll(loadedJobs);
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ErrorHandler.mapError(e);
      ToastService.showError(_error!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      ToastService.showError('Failed to load saved jobs. Try again.');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear search and filters
  Future<void> clearFilters() async {
    await loadJobs(refresh: true);
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
