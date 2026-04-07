// lib/data/repositories/project_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Projects stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/project_model.dart';

class ProjectRepository {
  final ApiService _apiService;

  ProjectRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ProjectModel project) async {
    try {
      final response = await _apiService.post(
        '/portfolios/${project.portfolioId}/projects',
        data: project.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create project');
    } catch (e) {
      throw Exception('Failed to insert project: $e');
    }
  }

  Future<ProjectModel?> findById(int id) async {
    try {
      final response = await _apiService.get('/projects/$id');
      if (response.statusCode == 200) {
        return ProjectModel.fromMap(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }

  Future<List<ProjectModel>> findByPortfolioId(
    int portfolioId, {
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '/portfolios/$portfolioId/projects',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => ProjectModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<List<ProjectModel>> findFeaturedByUserId(int userId) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/projects/featured',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => ProjectModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch featured projects: $e');
    }
  }

  Future<int> update(ProjectModel project) async {
    try {
      final response = await _apiService.put(
        '/projects/${project.id}',
        data: project.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update project');
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/projects/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete project');
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
