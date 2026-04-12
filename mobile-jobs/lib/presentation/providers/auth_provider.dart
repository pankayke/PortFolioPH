import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  AuthProvider(this._repository);

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isRecruiter => _user?.isRecruiter ?? false;
  bool get isJobSeeker => _user?.isJobSeeker ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<T?> _runWithLoading<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearLocalState({bool notify = true}) {
    _user = null;
    _token = null;
    _error = null;
    _isLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  // Restore session from persisted token + /auth/me
  Future<void> restoreSession() async {
    if (_isInitialized) {
      return;
    }

    final restored = await _runWithLoading(() async {
      final hasToken = await _repository.hasToken();
      if (!hasToken) {
        return false;
      }

      final user = await _repository.getMe();
      _user = user;
      // Token value remains in secure storage; sentinel keeps auth state alive in-memory.
      _token = 'persisted_token';
      return true;
    });

    if (restored != true) {
      _clearLocalState(notify: false);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? companyWebsite,
    String? phone,
  }) async {
    final result = await _runWithLoading(
      () => _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        companyName: companyName,
        companyWebsite: companyWebsite,
        phone: phone,
      ),
    );

    if (result == null) {
      return false;
    }

    final (user, token) = result;
    _user = user;
    _token = token;
    notifyListeners();
    return true;
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    final result = await _runWithLoading(
      () => _repository.login(email: email, password: password),
    );

    if (result == null) {
      return false;
    }

    final (user, token) = result;
    _user = user;
    _token = token;
    notifyListeners();
    return true;
  }

  // Logout
  Future<void> logout() async {
    await _runWithLoading(() async {
      await _repository.logout();
      return true;
    });
    _clearLocalState();
  }

  /// Clears local auth state without making a network call.
  void forceLogout() {
    _clearLocalState();
  }

  // Get current user
  Future<void> getMe() async {
    final user = await _runWithLoading(() => _repository.getMe());
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
