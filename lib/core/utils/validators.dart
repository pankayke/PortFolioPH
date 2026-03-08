// lib/core/utils/validators.dart
// ─────────────────────────────────────────────────────────────────────────────
// Form-validation helpers – Sprint 2.
//
// Each function returns `null` when valid, or a non-empty error string when
// invalid.  This matches Flutter's [FormField.validator] signature exactly, so
// functions can be passed directly to [TextFormField.validator].
//
// Rule: Pure functions only — no side effects, no dependencies on context.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/constants/app_constants.dart';

abstract final class AppValidators {
  // ── Email ─────────────────────────────────────────────────────────────────────
  /// Validates an email address field.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address.';
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────────
  /// Validates a new password field.
  /// Requires at least [AppConstants.minPasswordLength] characters and at least
  /// one letter and one digit for basic strength.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  // ── Confirm password ──────────────────────────────────────────────────────────
  /// Validates that [confirmValue] matches [originalValue].
  static String? validateConfirmPassword(
    String? confirmValue,
    String originalValue,
  ) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Please confirm your password.';
    }
    if (confirmValue != originalValue) return 'Passwords do not match.';
    return null;
  }

  // ── Username ──────────────────────────────────────────────────────────────────
  /// Validates a username field.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required.';
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'Username must be at least 3 characters.';
    if (trimmed.length > AppConstants.maxUsernameLength) {
      return 'Username must not exceed ${AppConstants.maxUsernameLength} characters.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(trimmed)) {
      return 'Username may only contain letters, numbers, _ . -';
    }
    return null;
  }

  // ── Required text ─────────────────────────────────────────────────────────────
  /// Generic non-empty validator for any required text field.
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }

  // ── Optional URL ─────────────────────────────────────────────────────────────
  /// Validates an optional URL field; passes `null` / empty without error.
  static String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
      return 'Enter a valid URL (https://…).';
    }
    return null;
  }
}
