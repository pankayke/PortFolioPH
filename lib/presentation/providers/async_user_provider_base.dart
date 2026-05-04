import 'package:flutter/foundation.dart';

/// Shared async state for user-scoped providers.
abstract class AsyncUserProviderBase extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;

  @protected
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
  }

  @protected
  void clearError() {
    _errorMessage = null;
  }

  @protected
  void setError(Object error) {
    _errorMessage = error.toString();
  }

  @protected
  Future<void> runLoadingTask(Future<void> Function() task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await task();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
