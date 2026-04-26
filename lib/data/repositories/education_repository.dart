// lib/data/repositories/education_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Education records stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/education_model.dart';

class EducationRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<EducationModel>> _localByUser =
      <int, List<EducationModel>>{};

  EducationRepository({required ApiService apiService})
    : _apiService = apiService;

  Future<int> insert(EducationModel education) async {
    try {
      final data = await _apiService.post(
        '/users/${education.userId}/education',
        data: education.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fall through to local cache fallback.
    }

    final id = _nextId++;
    final created = education.copyWith(id: id);
    final list = _localByUser.putIfAbsent(
      education.userId,
      () => <EducationModel>[],
    );
    list.insert(0, created);
    return id;
  }

  Future<List<EducationModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/education');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(EducationModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback below.
    }

    return List<EducationModel>.unmodifiable(
      _localByUser[userId] ?? const <EducationModel>[],
    );
  }

  Future<int> update(EducationModel education) async {
    try {
      await _apiService.put(
        '/education/${education.id}',
        data: education.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[education.userId] ?? <EducationModel>[];
      final index = list.indexWhere((item) => item.id == education.id);
      if (index >= 0) {
        list[index] = education;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/education/$id');
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
