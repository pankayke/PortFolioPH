import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/student_reflections_model.dart';

/// StudentReflectionsRepository (API-First)
///
/// Fetches student reflections from the backend API.
/// No local SQLite operations - all data is from the server.
class StudentReflectionsRepository {
  final ApiService _apiService;

  StudentReflectionsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  /// Fetch all reflections for a specific student
  Future<List<StudentReflectionModel>> findByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/reflections',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => StudentReflectionModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load student reflections: $e');
    }
  }

  /// Count reflections for a specific student
  Future<int> countByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/reflections/count',
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to count student reflections: $e');
    }
  }

  /// Add a new reflection
  Future<int> insert(StudentReflectionModel reflection) async {
    try {
      final response = await _apiService.post(
        '/students/${reflection.studentId}/reflections',
        data: reflection.toMap(),
      );

      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }

      throw Exception('Failed to create reflection');
    } catch (e) {
      throw Exception('Failed to insert reflection: $e');
    }
  }

  /// Update a reflection
  Future<void> update(StudentReflectionModel reflection) async {
    if (reflection.id == null) {
      throw Exception('Reflection id is required for update');
    }

    try {
      final response = await _apiService.put(
        '/students/${reflection.studentId}/reflections/${reflection.id}',
        data: reflection.toMap(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update reflection');
      }
    } catch (e) {
      throw Exception('Failed to update reflection: $e');
    }
  }

  /// Delete a reflection
  Future<void> delete(int id) async {
    try {
      final response = await _apiService.delete('/reflections/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete reflection');
      }
    } catch (e) {
      throw Exception('Failed to delete reflection: $e');
    }
  }
}
