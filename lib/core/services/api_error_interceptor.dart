// lib/core/services/api_error_interceptor.dart
// ─────────────────────────────────────────────────────────────────────────────
// Intelligent error interceptor with automatic retry logic using exponential backoff.
// Retries on: network errors, timeouts, 5xx server errors (max 3 attempts)
// User-friendly error messages mapped by type
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Intelligent error interceptor with retry logic
/// 
/// Features:
/// - Automatic retry on network errors (max 3 attempts)
/// - Exponential backoff: 100ms → 200ms → 400ms
/// - Retries on: timeout, connection error, 5xx errors
/// - Does NOT retry: 4xx client errors (validation, auth, etc)
/// - User-friendly error message mapping
class ApiErrorInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const int _retryOn = 500; // Retry on 5xx, 0 (network error)
  
  /// Retry delay strategy: exponential backoff
  /// Attempt 1: 100ms, Attempt 2: 200ms, Attempt 3: 400ms
  static int _getRetryDelay(int attemptNumber) {
    return 100 * (1 << (attemptNumber - 1)); // 2^(n-1) * 100ms
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on specific conditions
    final bool shouldRetry = _shouldRetry(err);
    final int retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    debugPrint(
      '[ApiErrorInterceptor] Error: ${err.type} | Status: ${err.response?.statusCode} | Attempt: $retryCount | Should retry: $shouldRetry',
    );

    if (shouldRetry && retryCount < _maxRetries) {
      // Wait with exponential backoff
      final delay = _getRetryDelay(retryCount + 1);
      debugPrint('[ApiErrorInterceptor] Retrying in ${delay}ms (attempt ${retryCount + 1}/$_maxRetries)');
      
      await Future.delayed(Duration(milliseconds: delay));

      // Increment retry count and retry the request
      final options = err.requestOptions;
      options.extra['retry_count'] = retryCount + 1;

      try {
        final response = await _retryRequest(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        // If retry fails, continue with error handling
        return onError(retryErr, handler);
      }
    }

    // Convert to user-friendly exception
    final exception = _mapToUserFriendlyError(err);
    return handler.reject(exception);
  }

  /// Determine if request should be retried
  bool _shouldRetry(DioException err) {
    // Retry on network/timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown) {
      return true;
    }

    // Retry on 5xx server errors
    if (err.response?.statusCode != null && 
        err.response!.statusCode! >= 500) {
      return true;
    }

    // Don't retry on client errors (4xx)
    return false;
  }

  /// Execute retry request using existing Dio instance
  /// Hack: We create a temporary Dio to retry since we don't have access to main Dio
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: requestOptions.connectTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        contentType: requestOptions.contentType,
        validateStatus: (_) => true,
      ),
    );

    // Copy all headers
    dio.options.headers = requestOptions.headers;

    // Execute request based on method
    switch (requestOptions.method.toUpperCase()) {
      case 'GET':
        return dio.get(
          requestOptions.path,
          queryParameters: requestOptions.queryParameters,
        );
      case 'POST':
        return dio.post(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
      case 'PUT':
        return dio.put(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
      case 'DELETE':
        return dio.delete(
          requestOptions.path,
          queryParameters: requestOptions.queryParameters,
        );
      default:
        throw DioException(
          requestOptions: requestOptions,
          error: 'Unsupported method: ${requestOptions.method}',
        );
    }
  }

  /// Convert DioException to user-friendly ApiException with localized message
  ApiException _mapToUserFriendlyError(DioException err) {
    debugPrint('[ApiErrorInterceptor] Mapping error: ${err.type}');

    // Network/timeout errors
    if (err.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        'Connection timeout\nPlease check your internet connection',
        code: 'CONNECTION_TIMEOUT',
      );
    }

    if (err.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Server took too long to respond\nPlease try again',
        code: 'RECEIVE_TIMEOUT',
      );
    }

    if (err.type == DioExceptionType.sendTimeout) {
      return ApiException(
        'Request took too long to send\nPlease try again',
        code: 'SEND_TIMEOUT',
      );
    }

    // Connection error (no internet)
    if (err.type == DioExceptionType.unknown) {
      if (err.error is SocketException) {
        return ApiException(
          'No internet connection\nPlease connect and try again',
          code: 'NO_INTERNET',
        );
      }
      return ApiException(
        'Network error occurred\nPlease try again',
        code: 'NETWORK_ERROR',
      );
    }

    // Server errors (5xx)
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      return ApiException(
        'Server error\nPlease try again later',
        code: 'SERVER_ERROR_${err.response!.statusCode}',
      );
    }

    // Cancelled request
    if (err.type == DioExceptionType.cancel) {
      return ApiException(
        'Request was cancelled',
        code: 'REQUEST_CANCELLED',
      );
    }

    // Default
    return ApiException(
      err.message ?? 'An unexpected error occurred',
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Base API exception with optional error code for handling
class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Check if this is a network error
  bool get isNetworkError =>
      code?.contains('TIMEOUT') == true || code?.contains('INTERNET') == true;

  /// Check if this is a server error
  bool get isServerError => code?.contains('SERVER_ERROR') == true;

  /// Check if retries are recommended
  bool get isRetryable => isNetworkError || isServerError;
}

// Import socket exception from dart:io for connection error handling
import 'dart:io';
