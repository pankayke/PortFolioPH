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
    super.message = 'Network error. Please check your connection.',
  });
}

/// Server returned 500+ error
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
  });
}

/// Bad request (400) with validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({required super.message, this.fieldErrors});
}

/// Resource not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found.'});
}

/// Authentication failed (401)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Invalid credentials. Please try again.',
  });
}

/// Authorization failed (403)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'You do not have permission to perform this action.',
  });
}

/// Email already in use
class DuplicateEmailFailure extends Failure {
  const DuplicateEmailFailure({
    super.message = 'An account with this email already exists.',
  });
}

/// Already applied to job
class DuplicateApplicationFailure extends Failure {
  const DuplicateApplicationFailure({
    super.message = 'You have already applied to this job.',
  });
}

/// Cache-related errors
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache operation failed.'});
}

/// Generic/unknown failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'An unexpected error occurred.'});
}
