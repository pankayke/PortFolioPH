import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/student_essay_model.dart';
import 'package:portfolioph/data/repositories/student_essays_repository.dart';

class StudentEssaysProvider extends ChangeNotifier {
  final StudentEssaysRepository _repository;

  StudentEssaysProvider({StudentEssaysRepository? repository})
    : _repository = repository ?? StudentEssaysRepository();

  List<StudentEssayModel> _essays = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentStudentId;

  List<StudentEssayModel> get essays => List.unmodifiable(_essays);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadForStudent(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentStudentId = studentId;
    notifyListeners();

    try {
      _essays = await _repository.findByStudentId(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEssay(StudentEssayModel item) async {
    _errorMessage = null;
    try {
      final id = await _repository.insert(item);
      _essays = [item.copyWith(id: id), ..._essays];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEssay(StudentEssayModel item) async {
    final id = item.id;
    if (id == null) {
      _errorMessage = 'Essay id is required for delete.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    try {
      await _repository.delete(id);
      _essays = _essays
          .where((essay) => essay.id != id)
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
