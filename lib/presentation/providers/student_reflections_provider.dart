import 'package:portfolioph/data/models/student_reflections_model.dart';
import 'package:portfolioph/data/repositories/student_reflections_repository.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class StudentReflectionsProvider extends AsyncUserProviderBase {
  final StudentReflectionsRepository _repository;

  StudentReflectionsProvider({required StudentReflectionsRepository repository})
    : _repository = repository;

  List<StudentReflectionModel> _reflections = [];

  List<StudentReflectionModel> get reflections =>
      List.unmodifiable(_reflections);

  Future<void> loadForStudent(int studentId) async {
    setCurrentUserId(studentId);
    await runLoadingTask(() async {
      _reflections = await _repository.findByStudentId(studentId);
    });
  }

  Future<bool> addReflection(StudentReflectionModel item) async {
    clearError();
    try {
      final id = await _repository.insert(item);
      _reflections = [item.copyWith(id: id), ..._reflections];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReflection(StudentReflectionModel item) async {
    final id = item.id;
    if (id == null) {
      setError('Reflection id is required for delete.');
      notifyListeners();
      return false;
    }

    clearError();
    try {
      await _repository.delete(id);
      _reflections = _reflections
          .where((r) => r.id != id)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> reload() async {
    final studentId = currentUserId;
    if (studentId == null) return;
    await loadForStudent(studentId);
  }
}
