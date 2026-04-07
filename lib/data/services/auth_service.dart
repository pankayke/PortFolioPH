// lib/data/services/auth_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Authentication service – Sprint 2.
//
// Responsibilities (SRP):
//   • register   – validate inputs, check uniqueness, hash password, INSERT user.
//   • login      – locate user by email, verify SHA-256 hash, return model.
//
// All failures raise [AuthException] so callers never need to inspect raw
// exception types or parse message strings.
//
// Depends on:
//   [UserRepository]  – DB CRUD for the users table.
//   [AppHelpers]      – SHA-256 hashing, ISO timestamp.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/exceptions/auth_exception.dart';
import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';

class AuthService {
  final UserRepository _userRepository;
  final ApiService _apiService;

  AuthService({UserRepository? userRepository, ApiService? apiService})
    : _userRepository = userRepository ?? UserRepository(),
      _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  // ── Register ──────────────────────────────────────────────────────────────────
  /// Creates a new user account.
  ///
  /// Throws [AuthException] when:
  ///   - any required field is blank.
  ///   - [email] is already registered.
  ///   - [username] is already taken.
  ///   - DB write fails.
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    // ── Field-level guards ──────────────────────────────────────────────────
    if (username.trim().isEmpty) {
      throw const AuthException(
        'Username is required.',
        code: 'username_empty',
      );
    }
    if (email.trim().isEmpty) {
      throw const AuthException('Email is required.', code: 'email_empty');
    }
    if (password.isEmpty) {
      throw const AuthException(
        'Password is required.',
        code: 'password_empty',
      );
    }

    // ── Uniqueness checks ───────────────────────────────────────────────────
    final existingEmail = await _userRepository.findByEmail(email);
    if (existingEmail != null) {
      throw const AuthException(
        'An account with this email already exists.',
        code: 'email_taken',
      );
    }

    final existingUsername = await _userRepository.findByUsername(username);
    if (existingUsername != null) {
      throw const AuthException(
        'This username is already taken.',
        code: 'username_taken',
      );
    }

    // ── Build and persist model ─────────────────────────────────────────────
    final now = AppHelpers.nowIso();
    final userRole = role ?? AppConstants.roleSeeker;

    try {
      // For online-only API: send plain password to backend (backend hashes it)
      final id = await _userRepository.registerUser(
        username: username.trim(),
        email: email.trim().toLowerCase(),
        plainPassword: password, // Send plain password to backend
        fullName: fullName?.trim().isEmpty == true ? null : fullName?.trim(),
        role: userRole,
      );

      // Create UserModel with placeholder hash (won't be used for API requests)
      final newUser = UserModel(
        id: id,
        username: username.trim(),
        email: email.trim().toLowerCase(),
        role: userRole,
        passwordHash: '', // Backend handles hashing
        fullName: fullName?.trim().isEmpty == true ? null : fullName?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      return _ensureAdminBootstrap(newUser);
    } catch (e) {
      throw AuthException('Registration failed: $e', code: 'insert_failed');
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Verifies credentials via the backend API.
  /// Backend handles password verification and returns user data.
  ///
  /// Throws [AuthException] when:
  ///   - email is not found.
  ///   - password does not match.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Backend authenticates and returns user
    final user = await _userRepository.authenticate(
      email: email.trim().toLowerCase(),
      plainPassword: password,
    );

    if (user == null) {
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    return _ensureAdminBootstrap(user);
  }

  // ── Forgot/Reset password ──────────────────────────────────────────────────
  /// Requests a reset token for the provided email.
  ///
  /// In local/development, backend may return `reset_token` in response data.
  Future<String?> requestPasswordReset({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.', code: 'email_empty');
    }

    try {
      final response = await _apiService.post(
        '/auth/password-reset/request',
        data: {'email': normalizedEmail},
      );

      if (response is Map<String, dynamic>) {
        final token = response['reset_token'];
        if (token is String && token.isNotEmpty) {
          return token;
        }
      }

      return null;
    } catch (_) {
      throw const AuthException(
        'Could not request reset token. Please try again.',
        code: 'password_reset_request_failed',
      );
    }
  }

  /// Confirms password reset using email + token + new password.
  Future<void> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.', code: 'email_empty');
    }
    if (token.trim().isEmpty) {
      throw const AuthException(
        'Reset token is required.',
        code: 'token_empty',
      );
    }
    if (newPassword.isEmpty) {
      throw const AuthException(
        'New password is required.',
        code: 'password_empty',
      );
    }

    try {
      await _apiService.post(
        '/auth/password-reset/confirm',
        data: {
          'email': normalizedEmail,
          'token': token.trim(),
          'new_password': newPassword,
        },
      );
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('invalid or expired reset token') ||
          errorText.contains('422')) {
        throw const AuthException(
          'Invalid or expired reset token.',
          code: 'token_invalid_or_expired',
        );
      }
      throw AuthException(
        'Password reset failed. Please try again.',
        code: 'password_reset_failed',
      );
    }
  }

  /// Ensures there is always at least one admin account in local development.
  /// If no admin exists yet, the current authenticated user is promoted.
  Future<UserModel> ensureAdminBootstrap(UserModel user) {
    return _ensureAdminBootstrap(user);
  }

  /// Ensures the dedicated local admin account exists for development/demo use.
  /// If an account already exists with the seed email, it is promoted to admin.
  Future<UserModel> ensureSeedAdminAccount() async {
    final now = AppHelpers.nowIso();
    final seededAdmin = UserModel(
      username: AppConstants.localAdminUsername,
      email: AppConstants.localAdminEmail,
      role: 'admin',
      passwordHash: AppHelpers.hashPassword(AppConstants.localAdminPassword),
      fullName: AppConstants.localAdminFullName,
      createdAt: now,
      updatedAt: now,
    );

    final existingUser = await _userRepository.findByEmail(
      AppConstants.localAdminEmail,
    );
    if (existingUser != null) {
      if (existingUser.role == 'admin') {
        return existingUser;
      }

      final elevatedUser = existingUser.copyWith(
        role: 'admin',
        updatedAt: AppHelpers.nowIso(),
      );
      await _userRepository.update(elevatedUser);
      return elevatedUser;
    }

    final createdUser = await _userRepository.createIfMissingByEmail(
      seededAdmin,
    );
    if (createdUser == null) {
      throw const AuthException(
        'Failed to create local admin account.',
        code: 'admin_seed_failed',
      );
    }

    if (createdUser.role == 'admin') {
      return createdUser;
    }

    final elevatedUser = createdUser.copyWith(
      role: 'admin',
      updatedAt: AppHelpers.nowIso(),
    );
    await _userRepository.update(elevatedUser);
    return elevatedUser;
  }

  /// Ensures local teacher and coordinator accounts exist for academic review
  /// dashboards in development and demo environments.
  Future<void> ensureAcademicStaffSeedAccounts() async {
    await _ensureSeedAccount(
      username: AppConstants.localTeacherUsername,
      email: AppConstants.localTeacherEmail,
      password: AppConstants.localTeacherPassword,
      fullName: AppConstants.localTeacherFullName,
      role: AppConstants.roleTeacher,
    );

    await _ensureSeedAccount(
      username: AppConstants.localCoordinatorUsername,
      email: AppConstants.localCoordinatorEmail,
      password: AppConstants.localCoordinatorPassword,
      fullName: AppConstants.localCoordinatorFullName,
      role: AppConstants.roleCoordinator,
    );
  }

  Future<UserModel> _ensureAdminBootstrap(UserModel user) async {
    // Online API mode: backend owns role governance.
    // Do not auto-promote or attempt protected updates during signup/login.
    return user;
  }

  Future<UserModel> _ensureSeedAccount({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final now = AppHelpers.nowIso();
    final existing = await _userRepository.findByEmail(email);

    if (existing != null) {
      if (existing.role == role) return existing;
      final updated = existing.copyWith(role: role, updatedAt: now);
      await _userRepository.update(updated);
      return updated;
    }

    final user = UserModel(
      username: username,
      email: email,
      role: role,
      passwordHash: AppHelpers.hashPassword(password),
      fullName: fullName,
      createdAt: now,
      updatedAt: now,
    );

    final created = await _userRepository.createIfMissingByEmail(user);
    if (created == null) {
      throw AuthException(
        'Failed to create local $role account.',
        code: 'seed_${role}_failed',
      );
    }

    return created;
  }

  // ── Token Management (NEW - Sanctum Integration) ────────────────────────────
  
  /// Check if a token exists in secure storage
  Future<bool> hasToken() async {
    return _apiService.hasToken();
  }

  /// Save a Sanctum token to secure storage
  Future<void> saveToken(String token) async {
    await _apiService.saveToken(token);
  }

  /// Clear the stored token (logout)
  Future<void> clearToken() async {
    await _apiService.clearToken();
  }

  /// Call backend logout endpoint (invalidates token on server)
  /// Then clear local token
  Future<void> logout() async {
    try {
      // Call /auth/logout endpoint on backend
      // This invalidates the Sanctum token server-side
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Even if backend logout fails, we should clear local token
      AppLogger.warning('[AuthService] Backend logout error: $e');
    }
    
    // Clear token from local storage
    await _apiService.clearToken();
  }

  /// Get current user from API using stored token
  /// Called on app startup to restore session
  /// Returns null if token is invalid or expired
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      
      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      AppLogger.warning('[AuthService] getCurrentUser failed: $e');
      return null;
    }
  }
}
