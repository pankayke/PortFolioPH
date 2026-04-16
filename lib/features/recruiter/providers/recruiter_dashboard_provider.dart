import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/features/recruiter/models/recruiter_dashboard_summary.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';

class RecruiterDashboardProvider extends ChangeNotifier {
  final RecruiterRepositoryImpl _repository;

  RecruiterDashboardSummary? _summary;
  bool _isLoading = false;
  String? _error;

  RecruiterDashboardProvider(this._repository);

  RecruiterDashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get notificationCount => _summary?.newApplicationsCount ?? 0;

  Future<void> loadDashboard({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _repository.getDashboardSummary();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _error = _handleError(error);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() => loadDashboard(refresh: true);

  String _handleError(dynamic error) {
    if (error is ApiException) return error.message;
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return error?.toString() ?? 'Unable to load recruiter dashboard.';
  }
}