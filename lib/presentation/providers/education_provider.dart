import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/repositories/education_repository.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class EducationProvider extends AsyncUserProviderBase {
  final EducationRepository _repository;

  EducationProvider({required EducationRepository repository})
    : _repository = repository;

  List<EducationModel> _education = [];
  String _searchQuery = '';

  List<EducationModel> get education => List.unmodifiable(_education);
  String get searchQuery => _searchQuery;

  Future<void> loadForUser(int userId) async {
    setCurrentUserId(userId);
    await runLoadingTask(() async {
      final all = await _repository.findByUserId(userId);
      _education = _applySearch(all, _searchQuery);
    });
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final all = await _repository.findByUserId(userId);
      _education = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      setError(e);
      notifyListeners();
    }
  }

  Future<bool> addEducation(EducationModel item) async {
    clearError();
    try {
      final id = await _repository.insert(item);
      _education = [item.copyWith(id: id), ..._education];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEducation(EducationModel item) async {
    clearError();
    if (item.id == null) {
      setError('Education id is required for update.');
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
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEducation(EducationModel item) async {
    clearError();
    final id = item.id;
    if (id == null) {
      setError('Education id is required for delete.');
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
      setError(e);
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

  void clearProviderError() {
    clearError();
    notifyListeners();
  }
}
