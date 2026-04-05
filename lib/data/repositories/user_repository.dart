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
  /// 
  /// Returns: user ID from backend
  /// Throws: Exception if registration fails or backend is unavailable
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
          'name': (fullName != null && fullName.trim().isNotEmpty)
              ? fullName.trim()
              : username,
          'username': username,
          'email': email,
          'password': plainPassword,
          'full_name': fullName,
          'role': role,
        },
      );

      // Laravel returns: {"success": true, "message": "...", "data": {"user": {...}, "token": "..."}, "errors": null}
      // ApiService extracts the 'data' field, so we receive: {"user": {...}, "token": "..."}
      if (response is Map<String, dynamic>) {
        final user = response['user'];
        if (user is Map<String, dynamic>) {
          final userId = user['id'] as int?;
          if (userId != null) {
            // IMPORTANT: AuthService should save the token after registration
            final token = response['token'] as String?;
            if (token != null) {
              await _apiService.saveToken(token);
            }
            return userId;
          }
        }
      }

      throw Exception('Backend returned invalid registration response: $response');
    } catch (e) {
      debugPrint('[UserRepository] Registration failed: $e');
      rethrow; // Let caller handle the error - NO fallback to mock data
    }
  }

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

  /// Authenticates user via API (Sanctum token-based auth).
  /// 
  /// Returns: UserModel on success, null on failure
  /// Side effect: Saves Sanctum token to secure storage on success
  /// 
  /// Response from Laravel:
  /// {"success": true, "message": "...", "data": {"user": {...}, "token": "..."}, "errors": null}
  /// ApiService extracts 'data', so we receive: {"user": {...}, "token": "..."}
  Future<UserModel?> authenticate({
    required String email,
    required String plainPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': plainPassword,
        },
      );

      if (response is Map<String, dynamic>) {
        // Extract user
        final userMap = response['user'];
        if (userMap is Map<String, dynamic>) {
          final user = UserModel.fromMap(userMap);
          
          // CRITICAL: Save token for future authenticated requests
          final token = response['token'] as String?;
          if (token != null && token.isNotEmpty) {
            await _apiService.saveToken(token);
            debugPrint('[UserRepository] Login successful - token saved');
          }
          
          return user;
        }
      }
      
      debugPrint('[UserRepository] Login failed - invalid response format');
      return null;
    } catch (e) {
      debugPrint('[UserRepository] Login failed: $e');
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
