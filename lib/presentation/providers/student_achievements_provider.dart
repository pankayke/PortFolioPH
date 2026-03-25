import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/student_achievement_model.dart';
import 'package:portfolioph/data/repositories/student_achievements_repository.dart';

class StudentAchievementsProvider extends ChangeNotifier {
  final StudentAchievementsRepository _repository;

  StudentAchievementsProvider({StudentAchievementsRepository? repository})
    : _repository = repository ?? StudentAchievementsRepository();

  List<StudentAchievementModel> _achievements = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentStudentId;

  List<StudentAchievementModel> get achievements =>
      List.unmodifiable(_achievements);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadForStudent(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentStudentId = studentId;
    notifyListeners();

    try {
      _achievements = await _repository.findByStudentId(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAchievement(StudentAchievementModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _achievements = [item.copyWith(id: id), ..._achievements];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAchievement(StudentAchievementModel item) async {
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Achievement id is required for delete.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    try {
      await _repository.delete(id);
      _achievements = _achievements
          .where((achievement) => achievement.id != id)
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
