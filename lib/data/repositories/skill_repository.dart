// lib/data/repositories/skill_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Skills stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/skill_model.dart';

class SkillRepository {
  final ApiService _apiService;

  SkillRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(SkillModel skill) async {
    try {
      final response = await _apiService.post(
        '/users/${skill.userId}/skills',
        data: skill.toMap(),
      );
      if (response.statusCode == 201) return response.data['id'] as int;
      throw Exception('Failed to create skill');
    } catch (e) {
      throw Exception('Failed to insert skill: $e');
    }
  }

  Future<List<SkillModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/skills');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => SkillModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }

  Future<List<SkillModel>> findByCategory(int userId, String category) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/skills',
        queryParameters: {'category': category},
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => SkillModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch skills by category: $e');
    }
  }

  Future<int> update(SkillModel skill) async {
    try {
      final response = await _apiService.put(
        '/skills/${skill.id}',
        data: skill.toMap(),
      );
      if (response.statusCode == 200) return 1;
      throw Exception('Failed to update skill');
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/skills/$id');
      if (response.statusCode == 200 || response.statusCode == 204) return 1;
      throw Exception('Failed to delete skill');
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }
}
