/// Custom Exceptions
///
/// Application-specific exception classes for error handling
library;

// ─── Base Exception ───────────────────────────────────────────────────────────
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

// ─── API/HTTP Exceptions ──────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final dynamic details;

  ApiException(this.message, [this.details]);

  String? get code => details is String ? details as String : null;

  bool get isNetworkError {
    final value = code ?? '';
    return value.contains('TIMEOUT') ||
        value.contains('INTERNET') ||
        value.contains('NETWORK');
  }

  bool get isServerError {
    final value = code ?? '';
    return value.contains('SERVER_ERROR');
  }

  bool get isRetryable => isNetworkError || isServerError;

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class ClientException extends ApiException {
  ClientException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message, [super.details]);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}
