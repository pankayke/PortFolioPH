import 'package:portfolioph/data/models/skills_model.dart';
import 'package:portfolioph/data/repositories/skills_repository.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class SkillsProvider extends AsyncUserProviderBase {
  final SkillsRepository _repository;

  SkillsProvider({required SkillsRepository repository})
    : _repository = repository;

  List<SkillsModel> _skills = [];
  String _searchQuery = '';

  List<SkillsModel> get skills => List.unmodifiable(_skills);
  String get searchQuery => _searchQuery;

  Future<void> loadForUser(int userId) async {
    setCurrentUserId(userId);
    await runLoadingTask(() async {
      final all = await _repository.findByUserId(userId);
      _skills = _applySearch(all, _searchQuery);
    });
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final all = await _repository.findByUserId(userId);
      _skills = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      setError(e);
      notifyListeners();
    }
  }

  Future<bool> addSkill(SkillsModel skill) async {
    clearError();
    try {
      final id = await _repository.insert(skill);
      _skills = [skill.copyWith(id: id), ..._skills];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSkill(SkillsModel skill) async {
    clearError();
    if (skill.id == null) {
      setError('Skill id is required for update.');
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
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(SkillsModel skill) async {
    clearError();
    final id = skill.id;
    if (id == null) {
      setError('Skill id is required for delete.');
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
      setError(e);
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

  void clearProviderError() {
    clearError();
    notifyListeners();
  }
}
