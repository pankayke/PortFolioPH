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
      final queryParameters = <String, dynamic>{'page': page};
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        queryParameters['category'] = category.trim();
      }
      if (location != null && location.trim().isNotEmpty) {
        queryParameters['location'] = location.trim();
      }
      if (employmentType != null && employmentType.trim().isNotEmpty) {
        queryParameters['employment_type'] = employmentType.trim();
      }
      if (experienceLevel != null && experienceLevel.trim().isNotEmpty) {
        queryParameters['experience_level'] = experienceLevel.trim();
      }

      final response = await _apiService.get(
        '/jobs',
        queryParameters: queryParameters,
      );

      if (response is List) {
        return response
            .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
              .toList();
        }
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
      await _apiService.post('/saved-jobs', data: {'job_id': jobId});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unsaveJob(int jobId) async {
    try {
      await _apiService.delete('/saved-jobs/$jobId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SeekerJob>> getSavedJobs({int page = 1}) async {
    try {
      final response = await _apiService.get(
        '/saved-jobs',
        queryParameters: {'page': page},
      );

      if (response is List) {
        return response
            .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((j) => SeekerJob.fromJson(j as Map<String, dynamic>))
              .toList();
        }
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
      final queryParameters = <String, dynamic>{
        'page': page,
        'sort_by': sortBy,
      };
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      final response = await _apiService.get(
        '/applications',
        queryParameters: queryParameters,
      );

      if (response is List) {
        return response
            .map((a) => SeekerApplication.fromJson(a as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((a) => SeekerApplication.fromJson(a as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeekerApplication> getApplicationById(int applicationId) async {
    try {
      final response = await _apiService.get('/applications/$applicationId');
      return SeekerApplication.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeekerApplication> applyForJob(int jobId) async {
    try {
      final response = await _apiService.post(
        '/applications',
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
      await _apiService.delete('/applications/$applicationId');
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
        '/applications/$applicationId/resume',
        data: {'resume': resumeFile},
      );
    } catch (e) {
      rethrow;
    }
  }
}
