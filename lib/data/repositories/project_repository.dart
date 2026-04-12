// lib/data/repositories/project_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/project_model.dart';

class ProjectRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static final Map<int, List<ProjectModel>> _localByPortfolio =
      <int, List<ProjectModel>>{};

  ProjectRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ProjectModel project) async {
    try {
      final data = await _apiService.post(
        '/portfolios/${project.portfolioId}/projects',
        data: project.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        return data['id'] as int;
      }
    } catch (_) {
      // Fallback to local cache when backend route is unavailable.
    }

    final id = _nextId++;
    final created = project.copyWith(id: id);
    final list = _localByPortfolio.putIfAbsent(
      project.portfolioId,
      () => <ProjectModel>[],
    );
    list.insert(0, created);
    return id;
  }

  Future<ProjectModel?> findById(int id) async {
    try {
      final data = await _apiService.get('/projects/$id');
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromMap(data);
      }
    } catch (_) {
      // Fallback lookup below.
    }

    for (final list in _localByPortfolio.values) {
      for (final item in list) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  Future<List<ProjectModel>> findByPortfolioId(
    int portfolioId, {
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final data = await _apiService.get(
        '/portfolios/$portfolioId/projects',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ProjectModel.fromMap)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback to local cache.
    }

    final source = List<ProjectModel>.from(_localByPortfolio[portfolioId] ?? const <ProjectModel>[]);
    final hasSearch = searchQuery != null && searchQuery.trim().isNotEmpty;
    final filtered = hasSearch
        ? source.where((item) {
        final q = searchQuery.toLowerCase();
            return item.title.toLowerCase().contains(q) ||
                (item.description?.toLowerCase().contains(q) ?? false) ||
                (item.techStack?.toLowerCase().contains(q) ?? false);
          }).toList(growable: false)
        : source;

    final start = (offset ?? 0).clamp(0, filtered.length);
    final end = limit == null
        ? filtered.length
        : (start + limit).clamp(start, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<List<ProjectModel>> findFeaturedByUserId(int userId) async {
    try {
      final portfoliosData = await _apiService.get('/users/$userId/portfolios');
      if (portfoliosData is List) {
        final featured = <ProjectModel>[];

        for (final rawPortfolio in portfoliosData) {
          if (rawPortfolio is! Map<String, dynamic>) continue;
          final portfolioId = _asInt(rawPortfolio['id']);
          if (portfolioId == null) continue;

          final projectsData = await _apiService.get(
            '/portfolios/$portfolioId/projects',
          );
          if (projectsData is! List) continue;

          for (final rawProject in projectsData) {
            if (rawProject is! Map<String, dynamic>) continue;
            final project = ProjectModel.fromMap(rawProject);
            if (project.userId == userId && project.isFeatured) {
              featured.add(project);
            }
          }
        }

        return featured;
      }
    } catch (_) {
      // Fallback to local cache.
    }

    return _localByPortfolio.values
        .expand((list) => list)
        .where((item) => item.userId == userId && item.isFeatured)
        .toList(growable: false);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<int> update(ProjectModel project) async {
    try {
      await _apiService.put('/projects/${project.id}', data: project.toMap());
      return 1;
    } catch (_) {
      final list = _localByPortfolio[project.portfolioId] ?? <ProjectModel>[];
      final index = list.indexWhere((item) => item.id == project.id);
      if (index >= 0) {
        list[index] = project;
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/projects/$id');
      return 1;
    } catch (_) {
      var deleted = 0;
      for (final list in _localByPortfolio.values) {
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
