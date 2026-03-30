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
      final queryParams = {
        'page': page,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
      };

      final response = await _apiService.get(
        '/recruiter/jobs',
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
      final response = await _apiService.get('/recruiter/jobs/$jobId');
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Job> createJob(CreateJobRequest request) async {
    try {
      final response = await _apiService.post(
        '/recruiter/jobs',
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
        '/recruiter/jobs/$jobId',
        data: data,
      );
      return Job.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await _apiService.delete('/recruiter/jobs/$jobId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeJob(int jobId) async {
    try {
      await _apiService.post('/recruiter/jobs/$jobId/close');
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
      final queryParams = {
        'page': page,
        'sort_by': sortBy,
        if (status != null) 'status': status,
        if (jobId != null) 'job_id': jobId,
      };

      final response = await _apiService.get(
        '/recruiter/applications',
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
      final response = await _apiService.get(
        '/recruiter/applications/$applicationId',
      );
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
        '/recruiter/applications/$applicationId',
        data: {'status': status, if (notes != null) 'notes': notes},
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
      await _apiService.post(
        '/recruiter/applications/bulk-update',
        data: {'application_ids': applicationIds, 'status': status},
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
  final String category;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String employmentType;
  final String experienceLevel;
  final List<String> requiredSkills;
  final String? requiredQualifications;
  final DateTime deadline;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.employmentType,
    required this.experienceLevel,
    required this.requiredSkills,
    this.requiredQualifications,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'employment_type': employmentType,
    'experience_level': experienceLevel,
    'required_skills': requiredSkills,
    'required_qualifications': requiredQualifications,
    'deadline': deadline.toIso8601String(),
  };
}
