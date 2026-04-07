// lib/data/repositories/education_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Education records stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/education_model.dart';

class EducationRepository {
  final ApiService _apiService;

  EducationRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(EducationModel education) async {
    try {
      final response = await _apiService.post(
        '/users/${education.userId}/education',
        data: education.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create education');
    } catch (e) {
      throw Exception('Failed to insert education: $e');
    }
  }

  Future<List<EducationModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/education');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => EducationModel.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch education: $e');
    }
  }

  Future<int> update(EducationModel education) async {
    try {
      final response = await _apiService.put(
        '/education/${education.id}',
        data: education.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update education');
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/education/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete education');
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }
}
