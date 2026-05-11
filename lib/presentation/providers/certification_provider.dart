import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/repositories/certification_repository.dart';
import 'package:portfolioph/data/services/certification_image_service.dart';
import 'package:portfolioph/presentation/providers/async_user_provider_base.dart';

class CertificationProvider extends AsyncUserProviderBase {
  final CertificationRepository _repository;
  final CertificationImageService _imageService;

  CertificationProvider({
    required CertificationRepository repository,
    CertificationImageService? imageService,
  }) : _repository = repository,
       _imageService = imageService ?? CertificationImageService();

  List<CertificationModel> _certifications = [];
  String _searchQuery = '';

  List<CertificationModel> get certifications =>
      List.unmodifiable(_certifications);
  String get searchQuery => _searchQuery;

  Future<void> loadForUser(int userId) async {
    setCurrentUserId(userId);
    await runLoadingTask(() async {
      final all = await _repository.findByUserId(userId);
      _certifications = _applySearch(all, _searchQuery);
    });
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final all = await _repository.findByUserId(userId);
      _certifications = _applySearch(all, _searchQuery);
      notifyListeners();
    } catch (e) {
      setError(e);
      notifyListeners();
    }
  }

  Future<bool> addCertification(CertificationModel certification) async {
    clearError();
    try {
      final id = await _repository.insert(certification);
      _certifications = [certification.copyWith(id: id), ..._certifications];
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCertification(CertificationModel certification) async {
    clearError();
    if (certification.id == null) {
      setError('Certification id is required for update.');
      notifyListeners();
      return false;
    }

    try {
      await _repository.update(certification);
      _certifications = _certifications
          .map((item) => item.id == certification.id ? certification : item)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCertification(CertificationModel certification) async {
    clearError();
    final id = certification.id;
    if (id == null) {
      setError('Certification id is required for delete.');
      notifyListeners();
      return false;
    }

    try {
      await _repository.delete(id);
      final imagePath = certification.imagePath;
      if (imagePath != null && imagePath.trim().isNotEmpty) {
        await _imageService.deleteImage(imagePath);
      }

      _certifications = _certifications
          .where((item) => item.id != id)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<String?> pickAndStoreImage() => _imageService.pickAndStoreImage();

  Future<void> replaceImage({
    required String? previousPath,
    required String? nextPath,
  }) async {
    if (previousPath == null || previousPath.trim().isEmpty) return;
    if (previousPath == nextPath) return;
    await _imageService.deleteImage(previousPath);
  }

  Future<void> deleteImagePath(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) return;
    await _imageService.deleteImage(imagePath);
  }

  List<CertificationModel> _applySearch(
    List<CertificationModel> source,
    String query,
  ) {
    if (query.isEmpty) return source;

    final q = query.toLowerCase();
    return source
        .where((certification) {
          return certification.name.toLowerCase().contains(q) ||
              certification.issuingOrganization.toLowerCase().contains(q) ||
              (certification.credentialId?.toLowerCase().contains(q) ?? false);
        })
        .toList(growable: false);
  }

  void clearProviderError() {
    clearError();
    notifyListeners();
  }
}
