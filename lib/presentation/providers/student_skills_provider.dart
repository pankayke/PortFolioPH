import 'package:portfolioph/data/models/student_skills_model.dart';
import 'package:portfolioph/data/repositories/student_skills_repository.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class StudentSkillsProvider extends AsyncUserProviderBase {
  final StudentSkillsRepository _repository;

  StudentSkillsProvider({required StudentSkillsRepository repository})
    : _repository = repository;

  List<StudentSkillsModel> _skills = [];

  List<StudentSkillsModel> get skills => List.unmodifiable(_skills);

  Future<void> loadForStudent(int studentId) async {
    setCurrentUserId(studentId);
    await runLoadingTask(() async {
      _skills = await _repository.findByStudentId(studentId);
    });
  }

  Future<bool> addSkill(StudentSkillsModel item) async {
    clearError();
    try {
      final id = await _repository.insert(item);
      _skills = [item.copyWith(id: id), ..._skills];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(StudentSkillsModel item) async {
    final id = item.id;
    if (id == null) {
      setError('Skill id is required for delete.');
      notifyListeners();
      return false;
    }

    clearError();
    try {
      await _repository.delete(id);
      _skills = _skills.where((s) => s.id != id).toList(growable: false);
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
