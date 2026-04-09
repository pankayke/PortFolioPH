// lib/presentation/providers/portfolio_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages the active user's portfolios and their nested data.
// NOTE (Sprint 2+ roadmap): expand with full CRUD logic as screens are built.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/portfolio_model.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/repositories/portfolio_repository.dart';
import 'package:portfolioph/data/repositories/project_repository.dart';

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _portfolioRepo;
  final ProjectRepository _projectRepo;

  List<PortfolioModel> _portfolios = [];
  List<ProjectModel> _featuredProjects = [];
  List<ProjectModel> _projects = [];
  int? _selectedPortfolioId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  PortfolioProvider({
    PortfolioRepository? portfolioRepository,
    ProjectRepository? projectRepository,
  }) : _portfolioRepo = portfolioRepository ?? PortfolioRepository(),
       _projectRepo = projectRepository ?? ProjectRepository();

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<PortfolioModel> get portfolios => List.unmodifiable(_portfolios);
  List<ProjectModel> get featuredProjects =>
      List.unmodifiable(_featuredProjects);
  List<ProjectModel> get projects => List.unmodifiable(_projects);
  int? get selectedPortfolioId => _selectedPortfolioId;
  String get searchQuery => _searchQuery;
  PortfolioModel? get selectedPortfolio {
    if (_selectedPortfolioId == null) return null;
    for (final portfolio in _portfolios) {
      if (portfolio.id == _selectedPortfolioId) {
        return portfolio;
      }
    }
    return null;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Fetch ─────────────────────────────────────────────────────────────────────
  Future<void> loadForUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _portfolios = await _portfolioRepo.findByUserId(userId);
      await _ensureDefaultPortfolio(userId);

      if (_selectedPortfolioId == null && _portfolios.isNotEmpty) {
        _selectedPortfolioId = _portfolios.first.id;
      }

      await _loadProjectsForSelectedPortfolio();
      _featuredProjects = await _projectRepo.findFeaturedByUserId(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────────
  Future<bool> addPortfolio(PortfolioModel portfolio) async {
    _errorMessage = null;
    try {
      final id = await _portfolioRepo.insert(portfolio);
      final created = portfolio.copyWith(id: id);
      _portfolios = [..._portfolios, created];
      _selectedPortfolioId ??= id;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePortfolio(PortfolioModel portfolio) async {
    _errorMessage = null;
    if (portfolio.id == null) {
      _errorMessage = 'Portfolio id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _portfolioRepo.update(portfolio);
      _portfolios = _portfolios
          .map((p) => p.id == portfolio.id ? portfolio : p)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePortfolio({
    required int portfolioId,
    required int userId,
  }) async {
    _errorMessage = null;
    try {
      await _portfolioRepo.delete(portfolioId);
      _portfolios = _portfolios
          .where((portfolio) => portfolio.id != portfolioId)
          .toList(growable: false);

      if (_selectedPortfolioId == portfolioId) {
        _selectedPortfolioId = _portfolios.isNotEmpty
            ? _portfolios.first.id
            : null;
      }

      await _ensureDefaultPortfolio(userId);
      await _loadProjectsForSelectedPortfolio();
      _featuredProjects = await _projectRepo.findFeaturedByUserId(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> selectPortfolio(int? portfolioId) async {
    _selectedPortfolioId = portfolioId;
    await _loadProjectsForSelectedPortfolio();
    notifyListeners();
  }

  Future<void> updateSearchQuery(String value) async {
    _searchQuery = value.trim();
    await _loadProjectsForSelectedPortfolio();
    notifyListeners();
  }

  Future<bool> addProject(ProjectModel project, {required int userId}) async {
    _errorMessage = null;
    try {
      final id = await _projectRepo.insert(project);
      final created = project.copyWith(id: id);
      _projects = [created, ..._projects];

      if (created.isFeatured) {
        _featuredProjects = [created, ..._featuredProjects];
      }

      _featuredProjects = await _projectRepo.findFeaturedByUserId(userId);
      await _loadProjectsForSelectedPortfolio();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(
    ProjectModel project, {
    required int userId,
  }) async {
    _errorMessage = null;
    if (project.id == null) {
      _errorMessage = 'Project id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _projectRepo.update(project);
      _projects = _projects
          .map((p) => p.id == project.id ? project : p)
          .toList(growable: false);

      _featuredProjects = await _projectRepo.findFeaturedByUserId(userId);
      await _loadProjectsForSelectedPortfolio();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject({
    required int projectId,
    required int userId,
  }) async {
    _errorMessage = null;
    try {
      await _projectRepo.delete(projectId);
      _projects = _projects
          .where((project) => project.id != projectId)
          .toList(growable: false);

      _featuredProjects = await _projectRepo.findFeaturedByUserId(userId);
      await _loadProjectsForSelectedPortfolio();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _ensureDefaultPortfolio(int userId) async {
    if (_portfolios.isNotEmpty) return;

    final now = DateTime.now().toUtc().toIso8601String();
    final defaultPortfolio = PortfolioModel(
      userId: userId,
      title: 'My Portfolio',
      summary: 'Auto-created default portfolio.',
      createdAt: now,
      updatedAt: now,
    );

    final createdId = await _portfolioRepo.insert(defaultPortfolio);
    final createdPortfolio = defaultPortfolio.copyWith(id: createdId);
    _portfolios = [createdPortfolio];
    _selectedPortfolioId = createdId;
  }

  Future<void> _loadProjectsForSelectedPortfolio() async {
    if (_selectedPortfolioId == null) {
      _projects = [];
      return;
    }

    _projects = await _projectRepo.findByPortfolioId(
      _selectedPortfolioId!,
      searchQuery: _searchQuery,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
