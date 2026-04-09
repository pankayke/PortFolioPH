// lib/features/seeker/repositories/seeker_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────
// Concrete implementation of seeker repository with API calls.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/features/seeker/models/seeker_job_model.dart';
import 'package:portfolioph/features/seeker/models/seeker_application_model.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';

class SeekerRepositoryImpl implements SeekerJobRepository {
  final ApiService _apiService;

  SeekerRepositoryImpl(this._apiService);

  @override
  Future<List<SeekerJob>> getJobs({
    int page = 1,
    String? search,
    String? category,
    String? location,
    String? employmentType,
    String? experienceLevel,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (location != null && location.isNotEmpty) 'location': location,
        if (employmentType != null && employmentType.isNotEmpty)
          'employment_type': employmentType,
        if (experienceLevel != null && experienceLevel.isNotEmpty)
          'experience_level': experienceLevel,
      };

      final response = await _apiService.get(
        '/jobs',
        queryParameters: queryParams,
      );

      if (response is List) {
        return response
            .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeekerJob> getJobById(int jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId');
      return SeekerJob.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveJob(int jobId) async {
    try {
      await _apiService.post('/jobs/$jobId/save');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unsaveJob(int jobId) async {
    try {
      await _apiService.delete('/jobs/$jobId/save');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SeekerJob>> getSavedJobs({int page = 1}) async {
    try {
      final response = await _apiService.get(
        '/seeker/saved-jobs',
        queryParameters: {'page': page},
      );

      if (response is List) {
        return response
            .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}

class SeekerApplicationRepositoryImpl implements SeekerApplicationRepository {
  final ApiService _apiService;

  SeekerApplicationRepositoryImpl(this._apiService);

  @override
  Future<List<SeekerApplication>> getApplications({
    int page = 1,
    String? status,
    String sortBy = 'applied_at',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'sort_by': sortBy,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _apiService.get(
        '/seeker/applications',
        queryParameters: queryParams,
      );

      if (response is List) {
        return response
            .map((a) => SeekerApplication.fromJson(a as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeekerApplication> getApplicationById(int applicationId) async {
    try {
      final response = await _apiService.get(
        '/seeker/applications/$applicationId',
      );
      return SeekerApplication.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeekerApplication> applyForJob(int jobId) async {
    try {
      final response = await _apiService.post(
        '/seeker/applications',
        data: {'job_id': jobId},
      );
      return SeekerApplication.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> withdrawApplication(int applicationId) async {
    try {
      await _apiService.post('/seeker/applications/$applicationId/withdraw');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateResumeForApplication(
    int applicationId,
    String resumeFile,
  ) async {
    try {
      await _apiService.post(
        '/seeker/applications/$applicationId/resume',
        data: {'resume': resumeFile},
      );
    } catch (e) {
      rethrow;
    }
  }
}
