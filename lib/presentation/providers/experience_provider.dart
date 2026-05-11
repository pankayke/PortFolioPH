import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/repositories/experience_repository.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class ExperienceProvider extends AsyncUserProviderBase {
  final ExperienceRepository _repository;

  ExperienceProvider({required ExperienceRepository repository})
    : _repository = repository;

  List<ExperienceModel> _experience = [];
  String _searchQuery = '';

  List<ExperienceModel> get experience => List.unmodifiable(_experience);
  String get searchQuery => _searchQuery;

  Future<void> loadForUser(int userId) async {
    setCurrentUserId(userId);
    await runLoadingTask(() async {
      final all = await _repository.findByUserId(userId);
      _experience = _applySearch(all, _searchQuery);
    });
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final all = await _repository.findByUserId(userId);
      _experience = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      setError(e);
      notifyListeners();
    }
  }

  Future<bool> addExperience(ExperienceModel item) async {
    clearError();
    try {
      final id = await _repository.insert(item);
      _experience = [item.copyWith(id: id), ..._experience];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExperience(ExperienceModel item) async {
    clearError();
    if (item.id == null) {
      setError('Experience id is required for update.');
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
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExperience(ExperienceModel item) async {
    clearError();
    final id = item.id;
    if (id == null) {
      setError('Experience id is required for delete.');
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
      setError(e);
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

  void clearProviderError() {
    clearError();
    notifyListeners();
  }
}
