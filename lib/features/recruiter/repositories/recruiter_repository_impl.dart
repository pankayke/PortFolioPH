// lib/features/recruiter/repositories/recruiter_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────
// Concrete implementation of recruiter repository with API calls.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';

class RecruiterRepositoryImpl {
  final ApiService _apiService;

  RecruiterRepositoryImpl(this._apiService);

  Future<List<Job>> getJobs({
    int page = 1,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 15,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        '/jobs/mine',
        queryParameters: queryParams,
      );

      if (response is List) {
        return response
            .map((j) => Job.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      return [];
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
      final response = await _apiService.post(
        '/jobs',
        data: request.toJson(),
      );
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Job> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        '/jobs/$jobId',
        data: data,
      );
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

  Future<List<RecruiterApplication>> getApplications({
    int page = 1,
    String? status,
    int? jobId,
    String sortBy = 'created_at',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 15,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (jobId != null) queryParams['job_id'] = jobId;
      queryParams['sort_by'] = sortBy;

      final response = await _apiService.get(
        '/applications',
        queryParameters: queryParams,
      );

      if (response is List) {
        return response
            .map(
              (a) => RecruiterApplication.fromJson(a as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
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
      for (final id in applicationIds) {
        await _apiService.put('/applications/$id/status', data: {'status': status});
      }
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
