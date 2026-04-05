// lib/core/services/api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// HTTP client service using Dio with Sanctum auth interceptors.
// NOW: Online-only, no caching. Real-time API pulls for all dynamic data.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_error_interceptor.dart';

class ApiService {
  // For local development: http://localhost:8000/api
  // For production: update to your API domain
  static const String baseUrl = 'http://localhost:8000/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // NO CACHING - Disable timeouts for long polling scenarios
  static const Duration kConnectTimeout = Duration(seconds: 30);
  static const Duration kReceiveTimeout = Duration(seconds: 60);

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiService(this._secureStorage) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: kConnectTimeout,
        receiveTimeout: kReceiveTimeout,
        contentType: 'application/json',
        validateStatus: (_) => true, // Don't throw on any status
      ),
    );

    // Add interceptors in order: request → response → error
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add intelligent error interceptor with retry logic (TIER 2)
    _dio.interceptors.add(ApiErrorInterceptor());
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token to headers if available
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint(
      '[ApiService] Response ${response.statusCode} | ${response.requestOptions.path}',
    );
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(
      '[ApiService] Error ${error.response?.statusCode} | ${error.message}',
    );

    // Handle 401 - token expired or invalid
    if (error.response?.statusCode == 401) {
      await _secureStorage.delete(key: tokenKey);
      debugPrint('[ApiService] Token cleared - unauthorized');
      // Caller should handle logout
    }

    return handler.next(error);
  }

  // ─── Public Methods ────────────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Token Management ─────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── Response Handling ─────────────────────────────────────────────────────

  dynamic _handleResponse(Response response) {
    if (response.statusCode == null) {
      throw ApiException('No response from server');
    }

    // Success responses
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;

        // If response has 'data' field, return it
        if (data.containsKey('data')) {
          return data['data'];
        }

        // Otherwise return whole response
        return data;
      }
      return response.data;
    }

    // Error responses
    if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized - Please login again');
    }

    if (response.statusCode == 403) {
      final message = _extractErrorMessage(response);
      throw ForbiddenException(message);
    }

    if (response.statusCode == 422) {
      final message = _extractErrorMessage(response);
      throw ValidationException(message);
    }

    if (response.statusCode! >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    }

    throw ApiException(
      'HTTP ${response.statusCode}: ${_extractErrorMessage(response)}',
    );
  }

  String _extractErrorMessage(Response response) {
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return 'An error occurred';
  }

  dynamic _handleError(DioException error) {
    if (error.response != null) {
      return _handleResponse(error.response!);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException('Request timeout');
      case DioExceptionType.badResponse:
        return ApiException('Bad response');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled');
      case DioExceptionType.unknown:
      default:
        return ApiException(error.message ?? 'Unknown error');
    }
  }
}

// ─── Custom Exceptions (deprecated - moved to api_error_interceptor.dart) ────────────────────────────────────────────────

// These exception classes are kept for backward compatibility during transition
// New code should use ApiException from api_error_interceptor.dart

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}
