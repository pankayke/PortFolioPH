// lib/core/services/api_error_interceptor.dart
// ─────────────────────────────────────────────────────────────────────────────
// Intelligent error interceptor with automatic retry logic using exponential backoff.
// Retries on: network errors, timeouts, 5xx server errors (max 3 attempts)
// User-friendly error messages mapped by type
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/custom_exceptions.dart';

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
  final Dio _retryDio;

  ApiErrorInterceptor(this._retryDio);
  
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
    // Wrap ApiException in DioException for handler.reject()
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.message,
      ),
    );
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

  /// Execute retry request using a dedicated retry client.
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    return _retryDio.fetch<dynamic>(requestOptions);
  }

  /// Convert DioException to user-friendly ApiException with localized message
  ApiException _mapToUserFriendlyError(DioException err) {
    debugPrint('[ApiErrorInterceptor] Mapping error: ${err.type}');

    // Network/timeout errors
    if (err.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        'Connection timeout\nPlease check your internet connection',
        'CONNECTION_TIMEOUT',
      );
    }

    if (err.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Server took too long to respond\nPlease try again',
        'RECEIVE_TIMEOUT',
      );
    }

    if (err.type == DioExceptionType.sendTimeout) {
      return ApiException(
        'Request took too long to send\nPlease try again',
        'SEND_TIMEOUT',
      );
    }

    // Connection error (no internet)
    if (err.type == DioExceptionType.unknown) {
      if (err.error is SocketException) {
        return ApiException(
          'No internet connection\nPlease connect and try again',
          'NO_INTERNET',
        );
      }
      return ApiException(
        'Network error occurred\nPlease try again',
        'NETWORK_ERROR',
      );
    }

    // Server errors (5xx)
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      return ApiException(
        'Server error\nPlease try again later',
        'SERVER_ERROR_${err.response!.statusCode}',
      );
    }

    // Cancelled request
    if (err.type == DioExceptionType.cancel) {
      return ApiException(
        'Request was cancelled',
        'REQUEST_CANCELLED',
      );
    }

    // Default
    return ApiException(
      err.message ?? 'An unexpected error occurred',
      'UNKNOWN_ERROR',
    );
  }
}
