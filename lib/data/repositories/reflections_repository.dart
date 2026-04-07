import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/reflections_model.dart';

class ReflectionsRepository {
  final ApiService _apiService;

  ReflectionsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ReflectionModel reflection) async {
    try {
      final response = await _apiService.post(
        '/users/${reflection.userId}/reflections',
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

  Future<List<ReflectionModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/reflections');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => ReflectionModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch reflections: $e');
    }
  }

  Future<int> update(ReflectionModel reflection) async {
    try {
      final response = await _apiService.put(
        '/reflections/${reflection.id}',
        data: reflection.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update reflection');
    } catch (e) {
      throw Exception('Failed to update reflection: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/reflections/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete reflection');
    } catch (e) {
      throw Exception('Failed to delete reflection: $e');
    }
  }
}
