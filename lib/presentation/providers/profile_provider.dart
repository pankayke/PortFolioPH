// lib/presentation/providers/profile_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// State management for user profile updates (edit profile, upload avatar/resume).
//
// Responsibilities:
//   • Load user's current profile
//   • Update profile fields (text + files)
//   • Handle loading and error states
//   • Notify listeners of changes
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  // ── State ───────────────────────────────────────────────────────────────────
  UserModel? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  UserModel? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileProvider({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  // ── Load Profile ────────────────────────────────────────────────────────────
  /// Loads the current user's profile from the API.
  ///
  /// Call this on profile screen init or after login.
  ///
  /// Side effects:
  ///   • Sets isLoading = true while fetching
  ///   • Sets currentProfile on success
  ///   • Sets errorMessage on failure
  ///   • Notifies listeners on state change
  Future<void> loadProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _userRepository.findById(userId);
      if (profile != null) {
        _currentProfile = profile;
        AppLogger.success('Profile loaded: $userId');
      } else {
        _errorMessage = 'Profile not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      AppLogger.error('Load failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update Profile ──────────────────────────────────────────────────────────
  /// Updates user profile with optional file uploads.
  ///
  /// Parameters (all optional):
  ///   - name: Full name
  ///   - email: Email address
  ///   - bio: User biography
  ///   - location: User location
  ///   - phoneNumber: Contact phone
  ///   - websiteUrl: Portfolio/website URL
  ///   - avatarFile: Profile image to upload
  ///   - resumeFile: Resume PDF to upload
  ///
  /// Returns: true if successful, false if failed
  ///
  /// Error handling:
  ///   • Catches specific exceptions (UnauthorizedException, ValidationException, etc.)
  ///   • Sets user-friendly error messages
  ///   • Notifies listeners so UI can display errors or retry
  ///   • Preserves previous profile on error
  ///   • Throws UnauthorizedException so caller can handle token expiry
  ///
  /// Exception behavior:
  ///   • UnauthorizedException: Re-thrown for caller to handle logout
  ///   • ValidationException: Error message displayed in form
  ///   • ServerException: Error with retry suggestion
  ///   • Other ApiException: Generic error message
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final success = await provider.updateProfile(
  ///     name: 'Jane Doe',
  ///     avatarFile: File('/path/to/avatar.jpg'),
  ///   );
  ///   if (success) {
  ///     context.go('/profile');
  ///   }
  /// } on UnauthorizedException catch (e) {
  ///   // Handle token expiry
  ///   authProvider.handleTokenExpired();
  ///   context.go('/login');
  /// }
  /// ```
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? location,
    String? phoneNumber,
    String? websiteUrl,
    File? avatarFile,
    File? resumeFile,
  }) async {
    if (_currentProfile == null) {
      _errorMessage = 'No profile loaded. Call loadProfile() first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _userRepository.updateProfile(
        userId: _currentProfile!.id!,
        name: name,
        email: email,
        bio: bio,
        location: location,
        phoneNumber: phoneNumber,
        websiteUrl: websiteUrl,
        avatarFile: avatarFile,
        resumeFile: resumeFile,
      );

      _currentProfile = updated;
      AppLogger.success('Profile updated successfully for ${updated.id}');

      return true;
    } on UnauthorizedException {
      _errorMessage = 'Session expired. Please log in again.';
      AppLogger.warning('Unauthorized - token expired');
      _isLoading = false;
      notifyListeners();
      rethrow; // Let caller handle logout and navigation
    } on ValidationException catch (e) {
      _errorMessage = 'Validation failed: ${e.message}';
      AppLogger.warning('Validation error: ${e.message}');
    } on ServerException catch (e) {
      _errorMessage = 'Server error. Please try again: ${e.message}';
      AppLogger.error('Server error', error: e);
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      AppLogger.error('Update failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  // ── Clear Error ──────────────────────────────────────────────────────────
  /// Clears the error message (useful after user acknowledges error).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Reset State ──────────────────────────────────────────────────────────
  /// Resets provider to initial state (logout or screen exit).
  void reset() {
    _currentProfile = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
