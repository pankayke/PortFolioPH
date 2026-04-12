// lib/data/repositories/certification_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Certifications stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/certification_model.dart';

class CertificationRepository {
  final ApiService _apiService;

  CertificationRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(CertificationModel cert) async {
    try {
      final response = await _apiService.post(
        '/users/${cert.userId}/certifications',
        data: cert.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create certification');
    } catch (e) {
      throw Exception('Failed to insert certification: $e');
    }
  }

  Future<List<CertificationModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/certifications');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map(
              (json) =>
                  CertificationModel.fromMap(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch certifications: $e');
    }
  }

  Future<int> update(CertificationModel cert) async {
    try {
      final response = await _apiService.put(
        '/certifications/${cert.id}',
        data: cert.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update certification');
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/certifications/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete certification');
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }
}
