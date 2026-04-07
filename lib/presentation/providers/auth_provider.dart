// lib/presentation/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Authentication state provider – Sprint 2.
//
// Wraps [AuthService] and exposes reactive auth state to the UI layer.
// Every state mutation calls [notifyListeners()] so dependent widgets rebuild.
//
// State surface:
//   currentUser     → the authenticated [UserModel], or null.
//   isAuthenticated → shorthand: currentUser != null.
//   isLoading       → true while an async operation is in flight.
//   errorMessage    → last error string; cleared automatically on next action.
//
// Actions:
//   register(username, email, password, fullName)
//   login(email, password)
//   logout()
//   restoreSession()   ← called by SplashScreen on app launch.
//   updateCurrentUser() ← called by ProfileService after profile edits.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/exceptions/auth_exception.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  // ── Getters ───────────────────────────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Register ──────────────────────────────────────────────────────────────────
  /// Creates a new account and stores the session on success.
  /// Returns `true` on success; populates [errorMessage] on failure.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    _begin();
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      _currentUser = user;
      await _persistSession(user.id!);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString().trim();
      _errorMessage = msg.isEmpty
          ? 'Registration failed. Please try again.'
          : msg;
      notifyListeners();
      return false;
    } finally {
      _endLoading();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Validates credentials and stores the session on success.
  /// Returns `true` on success; populates [errorMessage] on failure.
  Future<bool> login({required String email, required String password}) async {
    _begin();
    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      await _persistSession(user.id!);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString().trim();
      _errorMessage = msg.isEmpty ? 'Login failed. Please try again.' : msg;
      notifyListeners();
      return false;
    } finally {
      _endLoading();
    }
  }

  // ── Forgot password ─────────────────────────────────────────────────────────
  /// Requests a reset token for the provided email.
  Future<String?> requestPasswordReset({required String email}) async {
    _begin();
    try {
      final token = await _authService.requestPasswordReset(email: email);
      notifyListeners();
      return token;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Could not request reset token. Please try again.';
      notifyListeners();
      return null;
    } finally {
      _endLoading();
    }
  }

  /// Confirms password reset using email + token + new password.
  /// Returns `true` on success; populates [errorMessage] on failure.
  Future<bool> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _begin();
    try {
      await _authService.confirmPasswordReset(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Password reset failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _endLoading();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────
  /// Logs out user by:
  /// 1. Calling /auth/logout endpoint (invalidates Sanctum token on backend)
  /// 2. Clearing token from secure storage
  /// 3. Clearing currentUser state
  Future<void> logout() async {
    try {
      // Call backend logout endpoint (invalidates token)
      await _authService.logout();
    } catch (e) {
      debugPrint('[AuthProvider] Backend logout failed: $e (proceeding with local logout)');
    }
    
    // Clear token from secure storage
    await _authService.clearToken();
    
    // Clear user state
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
    
    debugPrint('[AuthProvider] Logged out successfully');
  }

  // ── Session restore ───────────────────────────────────────────────────────────
  /// Called by [SplashScreen] on launch.
  /// Restores session from stored Sanctum token.
  /// Called on app startup by SplashScreen.
  /// 
  /// Flow:
  /// 1. Check if token exists in secure storage
  /// 2. If yes, call /auth/me to verify token is still valid
  /// 3. If valid, restore user and stay logged in
  /// 4. If invalid/expired, clear token and redirect to login
  /// 
  /// Returns true if session restored successfully, false otherwise.
  Future<bool> restoreSession() async {
    _begin();
    try {
      // Check if token exists in secure storage
      final hasToken = await _authService.hasToken();
      if (!hasToken) {
        debugPrint('[AuthProvider] No token found - user not logged in');
        return false;
      }

      // Token exists, now verify it with backend
      final user = await _authService.getCurrentUser();
      if (user == null) {
        debugPrint('[AuthProvider] Token validation failed - redirecting to login');
        await _authService.clearToken();
        return false;
      }

      _currentUser = user;
      notifyListeners();
      debugPrint('[AuthProvider] Session restored successfully for ${user.email}');
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] Session restore failed: $e');
      await _authService.clearToken();
      return false;
    } finally {
      _endLoading();
    }
  }

  // ── Profile sync ──────────────────────────────────────────────────────────────
  /// Replaces [currentUser] with [updated] and notifies listeners.
  /// Called by the profile setup / edit flows after [ProfileService.updateProfile].
  void updateCurrentUser(UserModel updated) {
    _currentUser = updated;
    notifyListeners();
  }

  // ── Token expiry handling ─────────────────────────────────────────────────────
  /// Handles 401 Unauthorized responses (expired or invalid token).
  /// 
  /// Called by providers/screens when they catch UnauthorizedException.
  /// This ensures consistent logout behavior across the app.
  /// 
  /// Flow:
  /// 1. Clear stored token from secure storage
  /// 2. Clear currentUser from state
  /// 3. Notify listeners (triggers UI rebuild)
  /// 4. Caller should navigate to /login
  /// 
  /// Usage in providers:
  /// ```dart
  /// try {
  ///   final result = await _userRepository.updateProfile(...);
  /// } on UnauthorizedException catch (e) {
  ///   debugPrint('Token expired: $e');
  ///   authProvider.handleTokenExpired();
  ///   // Then in UI, navigate to login
  /// }
  /// ```
  Future<void> handleTokenExpired() async {
    debugPrint('[AuthProvider] Token expired - clearing session');
    
    await _authService.clearToken();
    _currentUser = null;
    _errorMessage = 'Session expired. Please log in again.';
    notifyListeners();
  }

  // ── Error control ─────────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  void _begin() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefUserId, userId);
  }
}
