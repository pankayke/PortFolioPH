// lib/data/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Data-layer repository for user operations – Online-only API.
//
// Removed SQLite dependency (sqflite) in favor of HTTP API via Dio.
// All operations now call the backend API.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/user_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

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

      throw Exception(
        'Backend returned invalid registration response: $response',
      );
    } catch (e) {
      debugPrint('[UserRepository] Registration failed: $e');
      rethrow; // Let caller handle the error - NO fallback to mock data
    }
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
        data: {'email': email.trim().toLowerCase(), 'password': plainPassword},
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
    } on UnauthorizedException {
      // Expected for invalid credentials from backend (401).
      return null;
    } catch (e) {
      debugPrint('[UserRepository] Login failed: $e');
      rethrow;
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

  Future<UserModel?> createIfMissingByEmail(
    UserModel user, {
    required String plainPassword,
  }) async {
    final existingUser = await findByEmail(user.email);
    if (existingUser != null) {
      return existingUser;
    }

    try {
      final id = await registerUser(
        username: user.username,
        email: user.email,
        plainPassword: plainPassword,
        fullName: user.fullName,
        role: user.role,
      );
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

  /// Updates user profile with support for multipart form data (file uploads).
  ///
  /// Supports partial updates – only fields provided will be updated.
  ///
  /// Parameters:
  ///   - userId: User's ID
  ///   - name: Full name (optional)
  ///   - email: Email address (optional, unique validation on backend)
  ///   - bio: User bio (optional)
  ///   - location: Location string (optional)
  ///   - phoneNumber: Phone number (optional)
  ///   - websiteUrl: Website/portfolio URL (optional)
  ///   - avatarFile: Profile image file to upload (optional)
  ///   - resumeFile: Resume PDF file to upload (optional)
  ///
  /// Returns: Updated UserModel with all fields from backend
  ///
  /// Throws: Various ApiException subclasses on failure
  ///   - ValidationException: If email already exists or validation fails (422)
  ///   - UnauthorizedException: If token expired (401)
  ///   - ServerException: If backend error (500+)
  ///   - ApiException: Other HTTP errors
  ///
  /// Side effects:
  ///   - Uploads files to backend storage
  ///   - Backend stores avatar in storage/avatars/
  ///   - Backend stores resume in storage/resumes/
  ///
  /// Example:
  /// ```dart
  /// final updatedUser = await userRepository.updateProfile(
  ///   userId: 1,
  ///   name: 'Jane Doe',
  ///   bio: 'Software Engineer',
  ///   avatarFile: File('/path/to/avatar.jpg'),
  /// );
  /// ```
  Future<UserModel> updateProfile({
    required int userId,
    String? name,
    String? email,
    String? bio,
    String? location,
    String? phoneNumber,
    String? websiteUrl,
    File? avatarFile,
    File? resumeFile,
    Uint8List? avatarBytes,
    Uint8List? resumeBytes,
    String? avatarFileName,
    String? resumeFileName,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      if (name != null && name.trim().isNotEmpty) {
        formData.fields.add(MapEntry('name', name.trim()));
      }
      if (email != null && email.trim().isNotEmpty) {
        formData.fields.add(MapEntry('email', email.trim().toLowerCase()));
      }
      if (bio != null && bio.trim().isNotEmpty) {
        formData.fields.add(MapEntry('bio', bio.trim()));
      }
      if (location != null && location.trim().isNotEmpty) {
        formData.fields.add(MapEntry('location', location.trim()));
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        formData.fields.add(MapEntry('phone_number', phoneNumber.trim()));
      }
      if (websiteUrl != null && websiteUrl.trim().isNotEmpty) {
        formData.fields.add(MapEntry('website_url', websiteUrl.trim()));
      }

      // Add avatar file if provided
      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              avatarBytes,
              filename:
                  avatarFileName ??
                  'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      } else if (avatarFile != null && await avatarFile.exists()) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      // Add resume file if provided
      if (resumeBytes != null && resumeBytes.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'resume',
            MultipartFile.fromBytes(
              resumeBytes,
              filename:
                  resumeFileName ??
                  'resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
            ),
          ),
        );
      } else if (resumeFile != null && await resumeFile.exists()) {
        formData.files.add(
          MapEntry(
            'resume',
            await MultipartFile.fromFile(
              resumeFile.path,
              filename: 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
            ),
          ),
        );
      }

      // Send multipart request
      final response = await _apiService.multipart(
        '/profile/update',
        data: formData,
      );

      if (response is Map<String, dynamic>) {
        debugPrint('[UserRepository] Profile updated successfully');
        return UserModel.fromMap(response);
      }

      throw ApiException(
        'Backend returned invalid profile update response: $response',
      );
    } catch (e) {
      debugPrint('[UserRepository] Profile update failed: $e');
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
