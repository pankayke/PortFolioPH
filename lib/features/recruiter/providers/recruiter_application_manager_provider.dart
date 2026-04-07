// lib/features/recruiter/providers/recruiter_application_manager_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages recruiter application viewing and status updates.
// Handles filtering by status, job, sorting, and bulk operations.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';

class ApplicationStatus {
  static const String applied = 'pending';
  static const String reviewing = 'reviewed';
  static const String shortlisted = 'shortlisted';
  static const String rejected = 'rejected';
  static const String accepted = 'accepted';
  static const String withdrawn = 'rejected';

  static const List<String> all = [
    applied,
    reviewing,
    shortlisted,
    rejected,
    accepted,
    withdrawn,
  ];
}

class RecruiterApplicationManagerProvider extends ChangeNotifier {
  final ApplicationRepositoryImpl _repository;

  List<RecruiterApplication> _applications = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  int? _selectedJobId;
  int _currentPage = 1;
  bool _hasMore = true;
  Set<int> _selectedApplicationIds = {};

  // ─────── Getters ──────────────────────────────────────────────────────────

  List<RecruiterApplication> get applications =>
      List.unmodifiable(_applications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  int? get selectedJobId => _selectedJobId;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  Set<int> get selectedApplicationIds =>
      Set.unmodifiable(_selectedApplicationIds);
  bool get hasSelected => _selectedApplicationIds.isNotEmpty;
  int get selectedCount => _selectedApplicationIds.length;

  // Status counts
  int get appliedCount =>
      _applications.where((a) => a.status == ApplicationStatus.applied).length;
  int get reviewingCount => _applications
      .where((a) => a.status == ApplicationStatus.reviewing)
      .length;
  int get shortlistedCount => _applications
      .where((a) => a.status == ApplicationStatus.shortlisted)
      .length;
  int get rejectedCount =>
      _applications.where((a) => a.status == ApplicationStatus.rejected).length;
  int get acceptedCount =>
      _applications.where((a) => a.status == ApplicationStatus.accepted).length;

  // ─────── Constructor ───────────────────────────────────────────────────────

  RecruiterApplicationManagerProvider(this._repository);

  // ─────── Public Methods ────────────────────────────────────────────────────

  /// Load applications with filtering
  Future<void> loadApplications({
    int page = 1,
    String? status,
    int? jobId,
    String sortBy = 'created_at',
    bool refresh = false,
  }) async {
    if (isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    _currentPage = page;
    _selectedStatus = status;
    _selectedJobId = jobId;

    try {
      final loaded = await _repository.getApplications(
        page: page,
        status: status,
        jobId: jobId,
        sortBy: sortBy,
      );

      if (refresh || page == 1) {
        _applications = loaded;
      } else {
        _applications.addAll(loaded);
      }

      _hasMore = loaded.isNotEmpty;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load more applications (pagination)
  Future<void> loadMoreApplications() async {
    if (!hasMore || isLoading) return;
    await loadApplications(
      page: _currentPage + 1,
      status: _selectedStatus,
      jobId: _selectedJobId,
    );
  }

  /// Refresh application list
  Future<void> refreshApplications() async {
    _selectedApplicationIds.clear();
    await loadApplications(refresh: true);
  }

  /// Get single application details
  Future<RecruiterApplication> getApplication(int applicationId) async {
    try {
      return await _repository.getApplicationById(applicationId);
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Update application status
  Future<void> updateApplicationStatus(
    int applicationId,
    String status, {
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateApplicationStatus(
        applicationId,
        status,
        notes: notes,
      );

      // Update in local list
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          status: status,
          notes: notes,
        );
      }

      _isLoading = false;
      _selectedApplicationIds.remove(applicationId);
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Bulk update application statuses
  Future<void> bulkUpdateApplicationStatus(
    String status, {
    Set<int>? ids,
  }) async {
    final idsToUpdate = ids ?? _selectedApplicationIds;
    if (idsToUpdate.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.bulkUpdateApplicationStatus(
        idsToUpdate.toList(),
        status,
      );

      // Update in local list
      for (final id in idsToUpdate) {
        final index = _applications.indexWhere((a) => a.id == id);
        if (index != -1) {
          _applications[index] = _applications[index].copyWith(status: status);
        }
      }

      _selectedApplicationIds.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    _selectedApplicationIds.clear();
    await loadApplications(status: status, refresh: true);
  }

  /// Filter by job
  Future<void> filterByJob(int? jobId) async {
    _selectedApplicationIds.clear();
    await loadApplications(jobId: jobId, refresh: true);
  }

  /// Sort applications
  Future<void> sortApplications(String sortBy) async {
    _selectedApplicationIds.clear();
    await loadApplications(sortBy: sortBy, refresh: true);
  }

  // ─────── Selection Methods ──────────────────────────────────────────────────

  void toggleApplicationSelection(int applicationId) {
    if (_selectedApplicationIds.contains(applicationId)) {
      _selectedApplicationIds.remove(applicationId);
    } else {
      _selectedApplicationIds.add(applicationId);
    }
    notifyListeners();
  }

  void selectAllApplications() {
    _selectedApplicationIds = _applications.map((a) => a.id).toSet();
    notifyListeners();
  }

  void deselectAllApplications() {
    _selectedApplicationIds.clear();
    notifyListeners();
  }

  bool isApplicationSelected(int applicationId) {
    return _selectedApplicationIds.contains(applicationId);
  }

  // ─────── Private Methods ───────────────────────────────────────────────────

  String _handleError(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'Unknown error occurred';
  }

  @override
  void dispose() {
    _selectedApplicationIds.clear();
    super.dispose();
  }
}
