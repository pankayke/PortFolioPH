import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/skills_model.dart';

class SkillsRepository {
  final ApiService _apiService;

  SkillsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(SkillsModel skill) async {
    try {
      final response = await _apiService.post('/users/${skill.userId}/skill-tracker', data: skill.toMap());
      if (response.statusCode == 201) return response.data['id'] as int;
      throw Exception('Failed to create skill tracking');
    } catch (e) {
      throw Exception('Failed to insert skill: $e');
    }
  }

  Future<List<SkillsModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/skill-tracker');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => SkillsModel.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }

  Future<int> update(SkillsModel skill) async {
    try {
      final response = await _apiService.put('/skill-tracker/${skill.id}', data: skill.toMap());
      if (response.statusCode == 200) return 1;
      throw Exception('Failed to update skill');
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/skill-tracker/$id');
      if (response.statusCode == 200 || response.statusCode == 204) return 1;
      throw Exception('Failed to delete skill');
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }
}
