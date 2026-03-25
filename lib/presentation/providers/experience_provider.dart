import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/repositories/experience_repository.dart';

class ExperienceProvider extends ChangeNotifier {
  final ExperienceRepository _repository;

  ExperienceProvider({ExperienceRepository? repository})
    : _repository = repository ?? ExperienceRepository();

  List<ExperienceModel> _experience = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  int? _currentUserId;

  List<ExperienceModel> get experience => List.unmodifiable(_experience);
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
      _experience = _applySearch(all, _searchQuery);
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
      _experience = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addExperience(ExperienceModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _experience = [item.copyWith(id: id), ..._experience];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExperience(ExperienceModel item) async {
    _errorMessage = null;
    if (item.id == null) {
      _errorMessage = 'Experience id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.update(item);
      _experience = _experience
          .map((existing) => existing.id == item.id ? item : existing)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExperience(ExperienceModel item) async {
    _errorMessage = null;
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Experience id is required for delete.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.delete(id);
      _experience = _experience
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

  List<ExperienceModel> _applySearch(
    List<ExperienceModel> source,
    String query,
  ) {
    if (query.isEmpty) return source;

    final q = query.toLowerCase();
    return source
        .where((item) {
          return item.company.toLowerCase().contains(q) ||
              item.jobTitle.toLowerCase().contains(q) ||
              (item.employmentType?.toLowerCase().contains(q) ?? false);
        })
        .toList(growable: false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
