import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/student_skills_model.dart';

/// StudentSkillsRepository (API-First)
///
/// Fetches student skills from the backend API.
/// No local SQLite operations - all data is from the server.
class StudentSkillsRepository {
  final ApiService _apiService;

  StudentSkillsRepository({required ApiService apiService})
    : _apiService = apiService;

  /// Fetch all skills for a specific student
  Future<List<StudentSkillsModel>> findByStudentId(int studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId/skills');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map(
              (json) =>
                  StudentSkillsModel.fromMap(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load student skills: $e');
    }
  }

  /// Count skills for a specific student
  Future<int> countByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/skills/count',
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to count student skills: $e');
    }
  }

  /// Add a new skill for a student
  Future<int> insert(StudentSkillsModel skill) async {
    try {
      final response = await _apiService.post(
        '/students/${skill.studentId}/skills',
        data: skill.toMap(),
      );

      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }

      throw Exception('Failed to insert skill');
    } catch (e) {
      throw Exception('Failed to add student skill: $e');
    }
  }

  /// Update an existing skill
  Future<int> update(StudentSkillsModel skill) async {
    try {
      final response = await _apiService.put(
        '/students/${skill.studentId}/skills/${skill.id}',
        data: skill.toMap(),
      );

      if (response.statusCode == 200) {
        return 1;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to update student skill: $e');
    }
  }

  /// Delete a skill
  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/skills/$id');

      return (response.statusCode == 204 || response.statusCode == 200) ? 1 : 0;
    } catch (e) {
      throw Exception('Failed to delete student skill: $e');
    }
  }
}
