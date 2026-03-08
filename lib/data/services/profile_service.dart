// lib/data/services/profile_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile service – Sprint 2.
//
// Separated from [AuthService] following the Single Responsibility Principle:
//   AuthService  → authentication only (login / register).
//   ProfileService → profile read / update only.
//
// Depends on [UserRepository] for DB access.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class ProfileService {
  final UserRepository _userRepository;

  ProfileService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  // ── Read ──────────────────────────────────────────────────────────────────────
  /// Returns the [UserModel] for [userId], or `null` if not found.
  Future<UserModel?> getProfile(int userId) async {
    return _userRepository.findById(userId);
  }

  // ── Update ────────────────────────────────────────────────────────────────────
  /// Persists [updatedUser] to the database and returns the saved model.
  ///
  /// Automatically bumps [updatedAt] to the current UTC timestamp.
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final stamped = updatedUser.copyWith(updatedAt: AppHelpers.nowIso());
    await _userRepository.update(stamped);
    return stamped;
  }

  // ── Avatar ────────────────────────────────────────────────────────────────────
  /// Saves [avatarPath] for [userId] and returns the updated model.
  Future<UserModel> updateAvatar({
    required UserModel user,
    required String avatarPath,
  }) async {
    return updateProfile(user.copyWith(avatarPath: avatarPath));
  }
}
