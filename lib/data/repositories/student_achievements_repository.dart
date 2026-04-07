import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/student_achievement_model.dart';

/// StudentAchievementsRepository (API-First)
///
/// Fetches student achievements from the backend API.
/// No local SQLite operations - all data is from the server.
class StudentAchievementsRepository {
  final ApiService _apiService;

  StudentAchievementsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  /// Fetch all achievements for a specific student
  Future<List<StudentAchievementModel>> findByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/achievements',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => StudentAchievementModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load student achievements: $e');
    }
  }

  /// Count achievements for a specific student
  Future<int> countByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/achievements/count',
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to count student achievements: $e');
    }
  }

  /// Add a new achievement
  Future<int> insert(StudentAchievementModel achievement) async {
    try {
      final response = await _apiService.post(
        '/students/${achievement.studentId}/achievements',
        data: achievement.toMap(),
      );

      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }

      throw Exception('Failed to create achievement');
    } catch (e) {
      throw Exception('Failed to insert achievement: $e');
    }
  }

  /// Update an achievement
  Future<void> update(StudentAchievementModel achievement) async {
    if (achievement.id == null) {
      throw Exception('Achievement id is required for update');
    }

    try {
      final response = await _apiService.put(
        '/students/${achievement.studentId}/achievements/${achievement.id}',
        data: achievement.toMap(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update achievement');
      }
    } catch (e) {
      throw Exception('Failed to update achievement: $e');
    }
  }

  /// Delete an achievement
  Future<void> delete(int id) async {
    try {
      final response = await _apiService.delete('/achievements/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete achievement');
      }
    } catch (e) {
      throw Exception('Failed to delete achievement: $e');
    }
  }
}
