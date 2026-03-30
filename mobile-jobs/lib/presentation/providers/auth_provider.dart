import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repository);

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isRecruiter => _user?.isRecruiter ?? false;
  bool get isJobSeeker => _user?.isJobSeeker ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final (user, token) = await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        companyName: companyName,
        companyWebsite: companyWebsite,
        phone: phone,
      );

      _user = user;
      _token = token;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final (user, token) = await _repository.login(
        email: email,
        password: password,
      );

      _user = user;
      _token = token;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.logout();

      _user = null;
      _token = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user
  Future<void> getMe() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _repository.getMe();
      _user = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
