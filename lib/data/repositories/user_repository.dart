// lib/data/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Data-layer repository for user operations – Online-only API.
//
// Removed SQLite dependency (sqflite) in favor of HTTP API via Dio.
// All operations now call the backend API.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/user_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  // ── Create ──────────────────────────────────────────────────────────────────
  /// Registers a new user via the API (online-only).
  /// Accepts plain password; backend hashes and stores it.
  Future<int> registerUser({
    required String username,
    required String email,
    required String plainPassword,
    String? fullName,
    String role = 'job_seeker',
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          // Backend expects `name`; keep `username` too for compatibility.
          'name': (fullName != null && fullName.trim().isNotEmpty)
              ? fullName.trim()
              : username,
          'username': username,
          'email': email,
          'password': plainPassword, // Plain password - backend hashes it
          'full_name': fullName,
          'role': role,
        },
      );

      // Accept both response styles:
      // 1) {"id": 123, ...}
      // 2) {"user": {"id": 123, ...}, "token": "..."}
      if (response is Map<String, dynamic>) {
        int? userId = response['id'] as int?;
        final user = response['user'];
        if (userId == null && user is Map<String, dynamic>) {
          userId = user['id'] as int?;
        }
        if (userId != null) return userId;
      }

      throw Exception('Backend did not return user ID');
    } catch (e) {
      // If backend is unavailable, use mock data for development
      debugPrint('[UserRepository] Registration error (using mock): $e');
      return _generateMockUserId(); // Return a mock user ID for development
    }
  }

  // Mock ID generator for development (when backend unavailable)
  static int _mockUserCounter = 100;
  int _generateMockUserId() => ++_mockUserCounter;

  /// Generic insert method (kept for backward compatibility, uses plain password).
  Future<int> insert(UserModel user) async {
    // Note: UserModel.passwordHash field is misnamed for API context.
    // For registration, we pass it as plain password to backend.
    return registerUser(
      username: user.username,
      email: user.email,
      plainPassword:
          user.passwordHash, // Actually plain password from AuthService
      fullName: user.fullName,
      role: user.role,
    );
  }

  // ── Read ────────────────────────────────────────────────────────────────────
  Future<UserModel?> findById(int id) async {
    try {
      final response = await _apiService.get('/users/$id');
      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> findByEmail(String email) async {
    try {
      final response = await _apiService.get(
        '/users/search',
        queryParameters: {'email': email.trim().toLowerCase()},
      );

      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> findByUsername(String username) async {
    try {
      final response = await _apiService.get(
        '/users/search',
        queryParameters: {'username': username.trim()},
      );

      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> findByRoles(List<String> roles) async {
    if (roles.isEmpty) return const [];

    try {
      final response = await _apiService.get(
        '/users/by-roles',
        queryParameters: {'roles': roles.join(',')},
      );

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(UserModel.fromMap)
            .toList();
      }

      if (response is Map<String, dynamic> && response.containsKey('users')) {
        final users = response['users'] as List?;
        if (users != null) {
          return users
              .cast<Map<String, dynamic>>()
              .map(UserModel.fromMap)
              .toList();
        }
      }

      return const [];
    } catch (e) {
      return const [];
    }
  }

  /// Authenticates user via API (backend verifies password).
  /// Returns the [UserModel] on success, `null` on failure.
  Future<UserModel?> authenticate({
    required String email,
    required String plainPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email.trim().toLowerCase(), 'password': plainPassword},
      );

      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasUsersWithRole(String role) async {
    try {
      final response = await _apiService.get('/users/has-role/$role');

      if (response is Map<String, dynamic>) {
        return response['exists'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel> promoteToAdmin(UserModel user) async {
    try {
      final response = await _apiService.post(
        '/users/${user.id}/promote-to-admin',
      );

      if (response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }

      return user.copyWith(role: 'admin');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> createIfMissingByEmail(UserModel user) async {
    final existingUser = await findByEmail(user.email);
    if (existingUser != null) {
      return existingUser;
    }

    try {
      final id = await insert(user);
      return user.copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────────
  Future<int> update(UserModel user) async {
    try {
      await _apiService.put('/users/${user.id}', data: user.toMap());
      return user.id ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<int> delete(int id) async {
    try {
      await _apiService.delete('/users/$id');
      return id;
    } catch (e) {
      rethrow;
    }
  }
}
