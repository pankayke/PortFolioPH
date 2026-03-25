import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/repositories/education_repository.dart';

class EducationProvider extends ChangeNotifier {
  final EducationRepository _repository;

  EducationProvider({EducationRepository? repository})
    : _repository = repository ?? EducationRepository();

  List<EducationModel> _education = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  int? _currentUserId;

  List<EducationModel> get education => List.unmodifiable(_education);
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
      _education = _applySearch(all, _searchQuery);
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
      _education = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addEducation(EducationModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _education = [item.copyWith(id: id), ..._education];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEducation(EducationModel item) async {
    _errorMessage = null;
    if (item.id == null) {
      _errorMessage = 'Education id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.update(item);
      _education = _education
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

  Future<bool> deleteEducation(EducationModel item) async {
    _errorMessage = null;
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Education id is required for delete.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.delete(id);
      _education = _education
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

  List<EducationModel> _applySearch(List<EducationModel> source, String query) {
    if (query.isEmpty) return source;

    final q = query.toLowerCase();
    return source
        .where((item) {
          return item.institution.toLowerCase().contains(q) ||
              item.degree.toLowerCase().contains(q) ||
              item.fieldOfStudy.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
