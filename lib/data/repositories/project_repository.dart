// lib/data/repositories/project_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/project_model.dart';

class ProjectRepository {
  final ApiService _apiService;

  static int _nextId = 1;
  static const Duration _featuredCacheTtl = Duration(minutes: 2);
  static final Map<int, List<ProjectModel>> _localByPortfolio =
      <int, List<ProjectModel>>{};
  static final Map<int, _FeaturedCacheEntry> _featuredCacheByUser =
      <int, _FeaturedCacheEntry>{};

  ProjectRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ProjectModel project) async {
    try {
      final data = await _apiService.post(
        '/portfolios/${project.portfolioId}/projects',
        data: project.toMap(),
      );
      if (data is Map<String, dynamic> && data['id'] is int) {
        _invalidateFeaturedCacheForUser(project.userId);
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
    _invalidateFeaturedCacheForUser(project.userId);
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
    final cached = _featuredCacheByUser[userId];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.projects;
    }

    try {
      final portfoliosData = await _apiService.get('/users/$userId/portfolios');
      if (portfoliosData is List) {
        final portfolioIds = portfoliosData
            .whereType<Map<String, dynamic>>()
            .map((item) => _asInt(item['id']))
            .whereType<int>()
            .toList(growable: false);

        final projectsPerPortfolio = await Future.wait(
          portfolioIds.map(_loadPortfolioProjectsSafely),
        );

        final featured = projectsPerPortfolio
            .expand((items) => items)
            .where((project) => project.userId == userId && project.isFeatured)
            .toList(growable: false);

        featured.sort((a, b) {
          final sortOrderCompare = a.sortOrder.compareTo(b.sortOrder);
          if (sortOrderCompare != 0) return sortOrderCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

        final deduped = <ProjectModel>[];
        final seenIds = <int>{};
        for (final project in featured) {
          final id = project.id;
          if (id != null) {
            if (seenIds.contains(id)) continue;
            seenIds.add(id);
          }
          deduped.add(project);
        }

        _featuredCacheByUser[userId] = _FeaturedCacheEntry(
          projects: List<ProjectModel>.unmodifiable(deduped),
          expiresAt: DateTime.now().add(_featuredCacheTtl),
        );
        return deduped;
      }
    } catch (_) {
      // Fallback to local cache.
    }

    final fallback = _localByPortfolio.values
        .expand((list) => list)
        .where((item) => item.userId == userId && item.isFeatured)
        .toList(growable: false);

    _featuredCacheByUser[userId] = _FeaturedCacheEntry(
      projects: List<ProjectModel>.unmodifiable(fallback),
      expiresAt: DateTime.now().add(_featuredCacheTtl),
    );
    return fallback;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<List<ProjectModel>> _loadPortfolioProjectsSafely(int portfolioId) async {
    try {
      final projectsData = await _apiService.get('/portfolios/$portfolioId/projects');
      if (projectsData is! List) return const <ProjectModel>[];
      return projectsData
          .whereType<Map<String, dynamic>>()
          .map(ProjectModel.fromMap)
          .toList(growable: false);
    } catch (_) {
      return const <ProjectModel>[];
    }
  }

  Future<int> update(ProjectModel project) async {
    try {
      await _apiService.put('/projects/${project.id}', data: project.toMap());
      _invalidateFeaturedCacheForUser(project.userId);
      return 1;
    } catch (_) {
      final list = _localByPortfolio[project.portfolioId] ?? <ProjectModel>[];
      final index = list.indexWhere((item) => item.id == project.id);
      if (index >= 0) {
        list[index] = project;
        _invalidateFeaturedCacheForUser(project.userId);
        return 1;
      }
      return 0;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/projects/$id');
      _featuredCacheByUser.clear();
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
      if (deleted == 1) {
        _featuredCacheByUser.clear();
      }
      return deleted;
    }
  }

  void _invalidateFeaturedCacheForUser(int userId) {
    _featuredCacheByUser.remove(userId);
  }
}

class _FeaturedCacheEntry {
  final List<ProjectModel> projects;
  final DateTime expiresAt;

  const _FeaturedCacheEntry({
    required this.projects,
    required this.expiresAt,
  });
}
