import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';

/// JobFeedRepository - API-only (no SQLite caching).
/// Fetches live job data from backend on every request.
class JobFeedRepository {
  final ApiService _apiService;

  JobFeedRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  /// Fetch all approved jobs (or role-scoped via API).
  /// Recruiter role sees all statuses; others see approved only.
  Future<List<JobListingModel>> findAll() async {
    try {
      final response = await _apiService.get('/jobs');

      if (response is List) {
        return response
            .map((job) => JobListingModel.fromMap(job as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('jobs')) {
        final jobs = response['jobs'] as List;
        return jobs
            .map((job) => JobListingModel.fromMap(job as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single job by ID.
  Future<JobListingModel> findById(int jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId');
      return JobListingModel.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch jobs with optional filters (category, location, search).
  Future<List<JobListingModel>> findFiltered({
    String? category,
    String? location,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (category != null) params['category'] = category;
      if (location != null) params['location'] = location;
      if (search != null) params['search'] = search;

      final response = await _apiService.get('/jobs', queryParameters: params);

      if (response is List) {
        return response
            .map((job) => JobListingModel.fromMap(job as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Count total jobs (optional - API may not provide this).
  Future<int> countAll() async {
    try {
      final jobs = await findAll();
      return jobs.length;
    } catch (e) {
      rethrow;
    }
  }
}
