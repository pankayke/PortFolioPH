// lib/core/exceptions/auth_exception.dart
// ─────────────────────────────────────────────────────────────────────────────
// Typed exception for all authentication failures.
//
// Callers (AuthService, AuthProvider) throw [AuthException] instead of raw
// strings so UI layers can handle error cases without parsing messages.
// ─────────────────────────────────────────────────────────────────────────────

/// Typed exception thrown by [AuthService] and [AuthProvider] on any
/// authentication or registration failure.
class AuthException implements Exception {
  /// Human-readable reason for the failure shown directly in the UI.
  final String message;

  /// Optional error code for programmatic handling (e.g. 'email_taken').
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() =>
      'AuthException(${code != null ? '$code: ' : ''}$message)';
}
