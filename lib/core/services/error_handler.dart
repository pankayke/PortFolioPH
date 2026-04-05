// lib/core/services/error_handler.dart
// ─────────────────────────────────────────────────────────────────────────────
// Global error handler that maps API errors to user-friendly messages
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';

class ErrorHandler {
  /// Maps DioException to user-friendly error message
  static String mapError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.unknown) {
      return 'Network error. Please check your internet connection.';
    }

    // Has response from server
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final responseBody = error.response!.data;

      // Try to extract error message from response
      if (responseBody is Map<String, dynamic>) {
        final message = responseBody['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      // Map status codes to messages
      return mapStatusCodeToMessage(statusCode, responseBody);
    }

    return 'An error occurred. Please try again.';
  }

  /// Map HTTP status codes to user messages
  static String mapStatusCodeToMessage(int statusCode, dynamic responseBody) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return _extractValidationErrors(responseBody);
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract validation error messages from 422 response
  static String _extractValidationErrors(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        // Get first error message
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first as String;
        }
      }
    }

    return 'Validation error. Please check your input.';
  }

  /// Check if error is authentication-related
  static bool isAuthError(DioException error) {
    return error.response?.statusCode == 401;
  }

  /// Check if error is validation-related
  static bool isValidationError(DioException error) {
    return error.response?.statusCode == 422;
  }

  /// Check if error is server-related
  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
