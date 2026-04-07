// lib/data/repositories/experience_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Work experience records stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/experience_model.dart';

class ExperienceRepository {
  final ApiService _apiService;

  ExperienceRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ExperienceModel experience) async {
    try {
      final response = await _apiService.post(
        '/users/${experience.userId}/experience',
        data: experience.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create experience');
    } catch (e) {
      throw Exception('Failed to insert experience: $e');
    }
  }

  Future<List<ExperienceModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/experience');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => ExperienceModel.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch experience: $e');
    }
  }

  Future<int> update(ExperienceModel experience) async {
    try {
      final response = await _apiService.put(
        '/experience/${experience.id}',
        data: experience.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update experience');
    } catch (e) {
      throw Exception('Failed to update experience: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/experience/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete experience');
    } catch (e) {
      throw Exception('Failed to delete experience: $e');
    }
  }
}
