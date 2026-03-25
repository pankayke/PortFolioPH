import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/skills_model.dart';
import 'package:portfolioph/data/repositories/skills_repository.dart';

class SkillsProvider extends ChangeNotifier {
  final SkillsRepository _repository;

  SkillsProvider({SkillsRepository? repository})
    : _repository = repository ?? SkillsRepository();

  List<SkillsModel> _skills = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  int? _currentUserId;

  List<SkillsModel> get skills => List.unmodifiable(_skills);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  Future<void> loadForUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    notifyListeners();

    try {
      final all = await _repository.findByUserId(userId);
      _skills = _applySearch(all, _searchQuery);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final all = await _repository.findByUserId(userId);
      _skills = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addSkill(SkillsModel skill) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(skill);
      _skills = [skill.copyWith(id: id), ..._skills];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSkill(SkillsModel skill) async {
    _errorMessage = null;
    if (skill.id == null) {
      _errorMessage = 'Skill id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.update(skill);
      _skills = _skills
          .map((existing) => existing.id == skill.id ? skill : existing)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(SkillsModel skill) async {
    _errorMessage = null;
    final id = skill.id;
    if (id == null) {
      _errorMessage = 'Skill id is required for delete.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.delete(id);
      _skills = _skills
          .where((existing) => existing.id != id)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<SkillsModel> _applySearch(List<SkillsModel> source, String q) {
    if (q.isEmpty) return source;
    final query = q.toLowerCase();

    return source
        .where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
