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
import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

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
    final newUser = UserModel(
      username: username.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: AppHelpers.hashPassword(password),
      fullName: fullName?.trim().isEmpty == true ? null : fullName?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      final id = await _userRepository.insert(newUser);
      return newUser.copyWith(id: id);
    } catch (e) {
      throw AuthException('Registration failed: $e', code: 'insert_failed');
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Verifies credentials and returns the authenticated [UserModel].
  ///
  /// Throws [AuthException] when:
  ///   - email is not found.
  ///   - password hash does not match.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // ── Lookup by email ─────────────────────────────────────────────────────
    final user = await _userRepository.findByEmail(email);
    if (user == null) {
      // Use a generic message to avoid email enumeration attacks.
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    // ── Hash compare ────────────────────────────────────────────────────────
    final inputHash = AppHelpers.hashPassword(password);
    if (user.passwordHash != inputHash) {
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    return user;
  }
}
