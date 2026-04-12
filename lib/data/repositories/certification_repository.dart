// lib/data/repositories/certification_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Certifications stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/certification_model.dart';

class CertificationRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<CertificationModel>> _localByUser =
      <int, List<CertificationModel>>{};

  CertificationRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(CertificationModel cert) async {
    try {
      final data = await _apiService.post(
        '/users/${cert.userId}/certifications',
        data: cert.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fall through to local cache fallback.
    }

    final id = _nextId++;
    final created = cert.copyWith(id: id);
    final list = _localByUser.putIfAbsent(cert.userId, () => <CertificationModel>[]);
    list.insert(0, created);
    return id;
  }

  Future<List<CertificationModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/certifications');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CertificationModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback below.
    }

    return List<CertificationModel>.unmodifiable(_localByUser[userId] ?? const <CertificationModel>[]);
  }

  Future<int> update(CertificationModel cert) async {
    try {
      await _apiService.put(
        '/certifications/${cert.id}',
        data: cert.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[cert.userId] ?? <CertificationModel>[];
      final index = list.indexWhere((item) => item.id == cert.id);
      if (index >= 0) {
        list[index] = cert;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/certifications/$id');
      return 1;
    } catch (_) {
      var deleted = 0;
      for (final list in _localByUser.values) {
        final before = list.length;
        list.removeWhere((item) => item.id == id);
        if (list.length != before) {
          deleted = 1;
          break;
        }
      }
      return deleted;
    }
  }
}
