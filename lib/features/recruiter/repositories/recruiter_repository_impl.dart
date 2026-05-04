// lib/features/recruiter/repositories/recruiter_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────
// Concrete implementation of recruiter repository with API calls.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/recruiter_dashboard_summary.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';

class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int total;
  final int perPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < totalPages;
}

class RecruiterRepositoryImpl {
  final ApiService _apiService;

  RecruiterRepositoryImpl(this._apiService);

  Future<RecruiterDashboardSummary> getDashboardSummary() async {
    final response = await _apiService.get('/recruiter/dashboard');
    return RecruiterDashboardSummary.fromJson(response as Map<String, dynamic>);
  }

  Future<PaginatedResult<Job>> getJobs({
    int page = 1,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 15};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        '/jobs/mine',
        queryParameters: queryParams,
      );

      return _parsePaginatedResponse(
        response,
        (job) => Job.fromJson(job),
        fallbackPage: page,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Job> getJobById(int jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId');
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Job> createJob(CreateJobRequest request) async {
    try {
      final response = await _apiService.post('/jobs', data: request.toJson());
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Job> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/jobs/$jobId', data: data);
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await _apiService.delete('/jobs/$jobId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeJob(int jobId) async {
    try {
      await _apiService.put('/jobs/$jobId', data: {'status': 'closed'});
    } catch (e) {
      rethrow;
    }
  }
}

class ApplicationRepositoryImpl {
  final ApiService _apiService;

  ApplicationRepositoryImpl(this._apiService);

  Future<PaginatedResult<RecruiterApplication>> getApplications({
    int page = 1,
    String? status,
    int? jobId,
    String sortBy = 'created_at',
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 15};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (jobId != null) queryParams['job_id'] = jobId;
      queryParams['sort_by'] = sortBy;

      final response = await _apiService.get(
        '/applications',
        queryParameters: queryParams,
      );

      return _parsePaginatedResponse(
        response,
        (application) => RecruiterApplication.fromJson(application),
        fallbackPage: page,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<RecruiterApplication> getApplicationById(int applicationId) async {
    try {
      final response = await _apiService.get('/applications/$applicationId');
      return RecruiterApplication.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateApplicationStatus(
    int applicationId,
    String status, {
    String? notes,
  }) async {
    try {
      await _apiService.put(
        '/applications/$applicationId/status',
        data: {
          'status': status,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> bulkUpdateApplicationStatus(
    List<int> applicationIds,
    String status,
  ) async {
    try {
      await Future.wait(
        applicationIds.map(
          (id) => _apiService.put(
            '/applications/$id/status',
            data: {'status': status},
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Request model for creating jobs
class CreateJobRequest {
  final String title;
  final String description;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String jobType;
  final List<String> requiredSkills;
  final DateTime? deadline;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.jobType,
    required this.requiredSkills,
    this.deadline,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'job_type': jobType,
    'required_skills': requiredSkills,
    if (deadline != null) 'deadline': deadline!.toIso8601String(),
  };
}

PaginatedResult<T> _parsePaginatedResponse<T>(
  Object? response,
  T Function(Map<String, dynamic>) fromJson, {
  required int fallbackPage,
}) {
  if (response is List) {
    final items = response
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: true);
    return PaginatedResult<T>(
      items: items,
      currentPage: fallbackPage,
      totalPages: fallbackPage,
      total: items.length,
      perPage: items.length,
    );
  }

  if (response is Map<String, dynamic>) {
    final rawItems = response['data'];
    final items = rawItems is List
        ? rawItems
              .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
              .toList(growable: true)
        : <T>[];
    final pagination = response['pagination'];
    final paginationMap = pagination is Map<String, dynamic>
        ? pagination
        : <String, dynamic>{};

    return PaginatedResult<T>(
      items: items,
      currentPage:
          (paginationMap['current_page'] as num?)?.toInt() ?? fallbackPage,
      totalPages: (paginationMap['last_page'] as num?)?.toInt() ?? fallbackPage,
      total: (paginationMap['total'] as num?)?.toInt() ?? items.length,
      perPage: (paginationMap['per_page'] as num?)?.toInt() ?? items.length,
    );
  }

  return PaginatedResult<T>(
    items: const [],
    currentPage: fallbackPage,
    totalPages: fallbackPage,
    total: 0,
    perPage: 0,
  );
}
