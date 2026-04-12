import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/skills_model.dart';

class SkillsRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<SkillsModel>> _localByUser =
      <int, List<SkillsModel>>{};

  SkillsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(SkillsModel skill) async {
    try {
      final data = await _apiService.post(
        '/users/${skill.userId}/skill-tracker',
        data: skill.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fall through to local cache fallback.
    }

    final id = _nextId++;
    final created = skill.copyWith(id: id);
    final list = _localByUser.putIfAbsent(skill.userId, () => <SkillsModel>[]);
    list.insert(0, created);
    return id;
  }

  Future<List<SkillsModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/skill-tracker');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SkillsModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback below.
    }

    return List<SkillsModel>.unmodifiable(_localByUser[userId] ?? const <SkillsModel>[]);
  }

  Future<int> update(SkillsModel skill) async {
    try {
      await _apiService.put(
        '/skill-tracker/${skill.id}',
        data: skill.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[skill.userId] ?? <SkillsModel>[];
      final index = list.indexWhere((item) => item.id == skill.id);
      if (index >= 0) {
        list[index] = skill;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/skill-tracker/$id');
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
