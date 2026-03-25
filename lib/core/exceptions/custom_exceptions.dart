/// Custom Exceptions
///
/// Application-specific exception classes
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required super.message});
}

class ValidationException extends AppException {
  ValidationException({required super.message});
}

class NotFoundException extends AppException {
  NotFoundException({required super.message});
}
