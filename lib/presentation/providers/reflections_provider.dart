import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/reflections_model.dart';
import 'package:portfolioph/data/repositories/reflections_repository.dart';

class ReflectionsProvider extends ChangeNotifier {
  final ReflectionsRepository _repository;

  ReflectionsProvider({ReflectionsRepository? repository})
    : _repository = repository ?? ReflectionsRepository();

  List<ReflectionModel> _reflections = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  int? _currentUserId;

  List<ReflectionModel> get reflections => List.unmodifiable(_reflections);
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
      _reflections = _applySearch(all, _searchQuery);
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
      _reflections = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addReflection(ReflectionModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _reflections = [item.copyWith(id: id), ..._reflections];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReflection(ReflectionModel item) async {
    _errorMessage = null;
    if (item.id == null) {
      _errorMessage = 'Reflection id is required for update.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.update(item);
      _reflections = _reflections
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

  Future<bool> deleteReflection(ReflectionModel item) async {
    _errorMessage = null;
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Reflection id is required for delete.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.delete(id);
      _reflections = _reflections
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

  List<ReflectionModel> _applySearch(List<ReflectionModel> source, String q) {
    if (q.isEmpty) return source;
    final query = q.toLowerCase();

    return source
        .where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.content.toLowerCase().contains(query) ||
              item.mood.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
