// lib/domain/failures/failures.dart
// ─────────────────────────────────────────────────────────────────────────────
// Domain layer failures for Either<Failure, Success> pattern
// Immutable, type-safe error representation
// ─────────────────────────────────────────────────────────────────────────────

abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => message;
}

/// Network connectivity or HTTP errors
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network error. Please check your connection.',
  }) : super(message: message);
}

/// Server returned 500+ error
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error. Please try again later.',
  }) : super(message: message);
}

/// Bad request (400) with validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors,
  }) : super(message: message);
}

/// Resource not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Resource not found.',
  }) : super(message: message);
}

/// Authentication failed (401)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Invalid credentials. Please try again.',
  }) : super(message: message);
}

/// Authorization failed (403)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    String message = 'You do not have permission to perform this action.',
  }) : super(message: message);
}

/// Email already in use
class DuplicateEmailFailure extends Failure {
  const DuplicateEmailFailure({
    String message = 'An account with this email already exists.',
  }) : super(message: message);
}

/// Already applied to job
class DuplicateApplicationFailure extends Failure {
  const DuplicateApplicationFailure({
    String message = 'You have already applied to this job.',
  }) : super(message: message);
}

/// Cache-related errors
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache operation failed.',
  }) : super(message: message);
}

/// Generic/unknown failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String message = 'An unexpected error occurred.',
  }) : super(message: message);
}
