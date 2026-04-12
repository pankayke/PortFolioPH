import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/reflections_model.dart';

class ReflectionsRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<ReflectionModel>> _localByUser =
      <int, List<ReflectionModel>>{};

  ReflectionsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ReflectionModel reflection) async {
    try {
      final data = await _apiService.post(
        '/users/${reflection.userId}/reflections',
        data: reflection.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fall through to local cache fallback.
    }

    final id = _nextId++;
    final created = reflection.copyWith(id: id);
    final list = _localByUser.putIfAbsent(reflection.userId, () => <ReflectionModel>[]);
    list.insert(0, created);
    return id;
  }

  Future<List<ReflectionModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/reflections');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ReflectionModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback below.
    }

    return List<ReflectionModel>.unmodifiable(_localByUser[userId] ?? const <ReflectionModel>[]);
  }

  Future<int> update(ReflectionModel reflection) async {
    try {
      await _apiService.put(
        '/reflections/${reflection.id}',
        data: reflection.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[reflection.userId] ?? <ReflectionModel>[];
      final index = list.indexWhere((item) => item.id == reflection.id);
      if (index >= 0) {
        list[index] = reflection;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/reflections/$id');
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
