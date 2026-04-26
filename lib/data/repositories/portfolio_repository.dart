// lib/data/repositories/portfolio_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/portfolio_model.dart';

class PortfolioRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<PortfolioModel>> _localByUser =
      <int, List<PortfolioModel>>{};

  PortfolioRepository({required ApiService apiService})
    : _apiService = apiService;

  Future<int> insert(PortfolioModel portfolio) async {
    try {
      final data = await _apiService.post(
        '/users/${portfolio.userId}/portfolios',
        data: portfolio.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fallback to local cache when backend route is unavailable.
    }

    final id = _nextId++;
    final created = portfolio.copyWith(id: id);
    final list = _localByUser.putIfAbsent(
      portfolio.userId,
      () => <PortfolioModel>[],
    );
    list.removeWhere((item) => item.id == id);
    list.insert(0, created);
    return id;
  }

  Future<PortfolioModel?> findById(int id) async {
    try {
      final data = await _apiService.get('/portfolios/$id');
      if (data is Map<String, dynamic>) {
        return PortfolioModel.fromMap(data);
      }
    } catch (_) {
      // Fallback lookup below.
    }

    for (final entries in _localByUser.values) {
      for (final item in entries) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  Future<List<PortfolioModel>> findByUserId(int userId) async {
    try {
      final data = await _apiService.get('/users/$userId/portfolios');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PortfolioModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback to local cache.
    }

    return List<PortfolioModel>.unmodifiable(
      _localByUser[userId] ?? const <PortfolioModel>[],
    );
  }

  Future<int> update(PortfolioModel portfolio) async {
    try {
      await _apiService.put(
        '/portfolios/${portfolio.id}',
        data: portfolio.toMap(),
      );
      return 1;
    } catch (_) {
      final list = _localByUser[portfolio.userId] ?? <PortfolioModel>[];
      final index = list.indexWhere((item) => item.id == portfolio.id);
      if (index >= 0) {
        list[index] = portfolio;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/portfolios/$id');
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
