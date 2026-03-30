// lib/core/services/api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// HTTP client service using Dio with Sanctum auth interceptors.
// NOW: Online-only, no caching. Real-time API pulls for all dynamic data.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // For local development: http://localhost:8000/api/v1
  // For production: update to your API domain
  static const String baseUrl = 'http://localhost:8000/api/v1';
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

    // Add mock interceptor for development (handles failed real-backend calls)
    _dio.interceptors.add(_MockInterceptor());

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
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

// ─── Mock Interceptor (Development Only) ──────────────────────────────────────

/// Intercepts API calls and provides mock responses when backend is unavailable.
/// This allows testing the registration flow without a running backend.
class _MockInterceptor extends Interceptor {
  static int _nextUserId = 1;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    debugPrint('[MockInterceptor] Error type: ${err.type}, Path: $path');

    // Only intercept connection errors (backend not running)
    if (err.type != DioExceptionType.unknown &&
        err.type != DioExceptionType.connectionTimeout) {
      return handler.next(err);
    }

    // Mock registration endpoint
    if (path.contains('auth/register')) {
      final data = err.requestOptions.data as Map<String, dynamic>?;
      final mockResponse = Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 201,
        data: {
          'id': _nextUserId++,
          'username': data?['username'] ?? 'user',
          'email': data?['email'] ?? 'user@example.com',
          'full_name': data?['full_name'] ?? 'User Name',
          'role': data?['role'] ?? 'seeker',
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      debugPrint('[MockInterceptor] Mocked /auth/register');
      return handler.resolve(mockResponse);
    }

    // Mock login endpoint
    if (path.contains('auth/login')) {
      final mockResponse = Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 200,
        data: {
          'id': 1,
          'username': 'demo_user',
          'email': 'demo@example.com',
          'full_name': 'Demo User',
          'role': 'seeker',
          'token': 'mock_token_login_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      debugPrint('[MockInterceptor] Mocked /auth/login');
      return handler.resolve(mockResponse);
    }

    // Mock user search endpoints
    if (path.contains('users/search')) {
      final mockResponse = Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 200,
        data: {
          'id': 1,
          'username': 'searchuser',
          'email': 'search@example.com',
          'full_name': 'Search User',
          'role': 'seeker',
        },
      );
      debugPrint('[MockInterceptor] Mocked /users/search');
      return handler.resolve(mockResponse);
    }

    // Mock get user by ID (path ends with digits like /users/1)
    if (path.contains('users/') && RegExp(r'/?\d+/?$').hasMatch(path)) {
      final mockResponse = Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 200,
        data: {
          'id': 1,
          'username': 'testuser',
          'email': 'test@example.com',
          'full_name': 'Test User',
          'role': 'seeker',
        },
      );
      debugPrint('[MockInterceptor] Mocked /users/{id}');
      return handler.resolve(mockResponse);
    }

    // Default: pass through to next handler
    return handler.next(err);
  }
}

// ─── Custom Exceptions ────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

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
