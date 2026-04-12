import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/student_essay_model.dart';

/// StudentEssaysRepository (API-First)
///
/// Fetches student essays from the backend API.
/// No local SQLite operations - all data is from the server.
class StudentEssaysRepository {
  final ApiService _apiService;

  StudentEssaysRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  /// Fetch all essays for a specific student
  Future<List<StudentEssayModel>> findByStudentId(int studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId/essays');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map(
              (json) => StudentEssayModel.fromMap(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load student essays: $e');
    }
  }

  /// Count essays for a specific student
  Future<int> countByStudentId(int studentId) async {
    try {
      final response = await _apiService.get(
        '/students/$studentId/essays/count',
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to count student essays: $e');
    }
  }

  /// Add a new essay
  Future<int> insert(StudentEssayModel essay) async {
    try {
      final response = await _apiService.post(
        '/students/${essay.studentId}/essays',
        data: essay.toMap(),
      );

      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }

      throw Exception('Failed to create essay');
    } catch (e) {
      throw Exception('Failed to insert essay: $e');
    }
  }

  /// Update an essay
  Future<void> update(StudentEssayModel essay) async {
    if (essay.id == null) {
      throw Exception('Essay id is required for update');
    }

    try {
      final response = await _apiService.put(
        '/students/${essay.studentId}/essays/${essay.id}',
        data: essay.toMap(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update essay');
      }
    } catch (e) {
      throw Exception('Failed to update essay: $e');
    }
  }

  /// Delete an essay
  Future<void> delete(int id) async {
    try {
      final response = await _apiService.delete('/essays/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete essay');
      }
    } catch (e) {
      throw Exception('Failed to delete essay: $e');
    }
  }
}
