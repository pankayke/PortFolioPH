// lib/presentation/providers/user_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages the currently authenticated user state.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({required UserRepository userRepository})
    : _userRepository = userRepository;

  // ── Getters ──────────────────────────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // ── Session restore ──────────────────────────────────────────────────────────
  /// Reads persisted [userId] from SharedPreferences and loads the user.
  /// Returns `true` if a valid session was found.
  Future<bool> restoreSession() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(AppConstants.prefUserId);
      if (userId == null) return false;

      final user = await _userRepository.findById(userId);
      if (user == null) {
        await prefs.remove(AppConstants.prefUserId);
        return false;
      }
      _currentUser = user;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Authentication ────────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _userRepository.authenticate(
        email: email,
        plainPassword: password,
      );
      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        return false;
      }
      _currentUser = user;
      await _persistSession(user.id!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserId);
    _currentUser = null;
    notifyListeners();
  }

  // ── Profile update ────────────────────────────────────────────────────────────
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _userRepository.update(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  Future<void> _persistSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefUserId, userId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
