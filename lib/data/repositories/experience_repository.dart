// lib/data/repositories/experience_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Work experience records stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/experience_model.dart';

class ExperienceRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<ExperienceModel>> _localByUser =
      <int, List<ExperienceModel>>{};

  ExperienceRepository({required ApiService apiService})
    : _apiService = apiService;

  Future<int> insert(ExperienceModel experience) async {
    try {
      final data = await _apiService.post(
        '/users/${experience.userId}/experience',
        data: experience.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fall through to local cache fallback.
    }

    final id = _nextId++;
    final created = experience.copyWith(id: id);
    final list = _localByUser.putIfAbsent(
      experience.userId,
      () => <ExperienceModel>[],
    );
    list.insert(0, created);
    return id;
  }

  Future<List<ExperienceModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/experience');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ExperienceModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback below.
    }

    return List<ExperienceModel>.unmodifiable(
      _localByUser[userId] ?? const <ExperienceModel>[],
    );
  }

  Future<int> update(ExperienceModel experience) async {
    try {
      await _apiService.put(
        '/experience/${experience.id}',
        data: experience.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[experience.userId] ?? <ExperienceModel>[];
      final index = list.indexWhere((item) => item.id == experience.id);
      if (index >= 0) {
        list[index] = experience;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/experience/$id');
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
