import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/student_skills_model.dart';
import 'package:portfolioph/data/repositories/student_skills_repository.dart';

class StudentSkillsProvider extends ChangeNotifier {
  final StudentSkillsRepository _repository;

  StudentSkillsProvider({StudentSkillsRepository? repository})
    : _repository = repository ?? StudentSkillsRepository();

  List<StudentSkillsModel> _skills = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentStudentId;

  List<StudentSkillsModel> get skills => List.unmodifiable(_skills);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadForStudent(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentStudentId = studentId;
    notifyListeners();

    try {
      _skills = await _repository.findByStudentId(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSkill(StudentSkillsModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _skills = [item.copyWith(id: id), ..._skills];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(StudentSkillsModel item) async {
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Skill id is required for delete.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    try {
      await _repository.delete(id);
      _skills = _skills.where((s) => s.id != id).toList(growable: false);
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
