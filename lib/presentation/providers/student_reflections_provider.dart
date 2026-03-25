import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/student_reflections_model.dart';
import 'package:portfolioph/data/repositories/student_reflections_repository.dart';

class StudentReflectionsProvider extends ChangeNotifier {
  final StudentReflectionsRepository _repository;

  StudentReflectionsProvider({StudentReflectionsRepository? repository})
    : _repository = repository ?? StudentReflectionsRepository();

  List<StudentReflectionModel> _reflections = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentStudentId;

  List<StudentReflectionModel> get reflections =>
      List.unmodifiable(_reflections);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadForStudent(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentStudentId = studentId;
    notifyListeners();

    try {
      _reflections = await _repository.findByStudentId(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReflection(StudentReflectionModel item) async {
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

  Future<bool> deleteReflection(StudentReflectionModel item) async {
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Reflection id is required for delete.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    try {
      await _repository.delete(id);
      _reflections = _reflections
          .where((r) => r.id != id)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> reload() async {
    final studentId = _currentStudentId;
    if (studentId == null) return;
    await loadForStudent(studentId);
  }
}
