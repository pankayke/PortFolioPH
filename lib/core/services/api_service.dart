// lib/core/services/api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// HTTP client service using Dio with Sanctum auth interceptors.
// 
// CRITICAL: This is the ONLY place that makes HTTP calls to Laravel.
// NO MOCKS. NO FALLBACKS. REAL DATA ONLY.
// 
// Features:
//   • Initializes Dio with base URL and timeouts
//   • Automatically injects Sanctum bearer token in all requests
//   • Handles errors and converts to user-friendly exceptions
//   • Manages token storage in flutter_secure_storage
//   • Implements get, post, put, delete methods
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';

import 'api_error_interceptor.dart';

class ApiService {
  // Base URL is now environment-aware (configured via AppConfig)
  // - Development: http://localhost:8000/api
  // - Staging: https://staging-api.portfolioph.dev/api
  // - Production: https://api.portfolioph.dev/api
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
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: kConnectTimeout,
        receiveTimeout: kReceiveTimeout,
        contentType: 'application/json',
        headers: const {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
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

    AppLogger.success('ApiService initialized with ${AppConfig.apiBaseUrl}');
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
    AppLogger.debug(
      'Response ${response.statusCode} | ${response.requestOptions.path}',
    );
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.error(
      'API Error ${error.response?.statusCode} | ${error.message}',
      error: error,
    );

    // Handle 401 - token expired or invalid
    if (error.response?.statusCode == 401) {
      await _secureStorage.delete(key: tokenKey);
      AppLogger.warning('Token cleared - unauthorized');
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

  /// Multipart form data upload (for file uploads with additional fields).
  /// 
  /// Usage:
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'name': 'John Doe',
  ///   'avatar': await MultipartFile.fromFile(imagePath),
  /// });
  /// await apiService.multipart('/profile/update', data: formData);
  /// ```
  Future<dynamic> multipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
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
    final baseOrigin = _dio.options.baseUrl;

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
      case DioExceptionType.connectionError:
        return NetworkException(
          'Cannot reach API at $baseOrigin. Ensure the backend server is running and CORS allows this origin.',
        );
      case DioExceptionType.cancel:
        return ApiException('Request cancelled');
      case DioExceptionType.unknown:
        final message = error.message ?? 'Unknown error';
        if (message.contains('XMLHttpRequest onError callback')) {
          return NetworkException(
            'Browser request failed before receiving a response. This usually means the API is offline or blocked by CORS at $baseOrigin.',
          );
        }
        return ApiException(message);
      default:
        return ApiException(error.message ?? 'Unknown error');
    }
  }
}

// ─── Error Handling ────────────────────────────────────────────────────────

/* Exception classes are now defined in lib/core/exceptions/custom_exceptions.dart
   See: UnauthorizedException, ForbiddenException, ValidationException, etc. */
