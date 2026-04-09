import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  late Dio _dio;
  late FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'auth_token';
  final VoidCallback? onUnauthorized;

  ApiService({this.onUnauthorized}) {
    _secureStorage = const FlutterSecureStorage();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add bearer token if exists
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 - token expired
          if (error.response?.statusCode == 401) {
            clearToken();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? companyWebsite,
    String? phone,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (companyName != null) 'company_name': companyName,
        if (companyWebsite != null) 'company_website': companyWebsite,
        if (phone != null) 'phone': phone,
      };

      final response = await _dio.post('/auth/register', data: data);

      if (response.statusCode == 201) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      await clearToken();
    } catch (e) {
      // Clear token anyway
      await clearToken();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Job endpoints
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int perPage = 15,
    String? search,
    String? jobType,
    bool? remote,
  }) async {
    try {
      final response = await _dio.get(
        '/jobs',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          if (jobType != null) 'job_type': jobType,
          if (remote != null) 'remote': remote ? 1 : 0,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    try {
      final response = await _dio.get('/jobs/$jobId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String requirements,
    required String jobType,
    required String location,
    required String deadlineAt,
    double? salaryMin,
    double? salaryMax,
    bool remote = false,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'requirements': requirements,
        'job_type': jobType,
        'location': location,
        'deadline_at': deadlineAt,
        'remote_work': remote,
        if (salaryMin != null) 'salary_min': salaryMin,
        if (salaryMax != null) 'salary_max': salaryMax,
      };

      final response = await _dio.post('/jobs', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateJob(
    int jobId, {
    String? title,
    String? description,
    String? requirements,
    String? jobType,
    String? location,
    String? deadlineAt,
    double? salaryMin,
    double? salaryMax,
    bool? remote,
  }) async {
    try {
      final data = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (requirements != null) 'requirements': requirements,
        if (jobType != null) 'job_type': jobType,
        if (location != null) 'location': location,
        if (deadlineAt != null) 'deadline_at': deadlineAt,
        if (remote != null) 'remote_work': remote,
        if (salaryMin != null) 'salary_min': salaryMin,
        if (salaryMax != null) 'salary_max': salaryMax,
      };

      final response = await _dio.put('/jobs/$jobId', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await _dio.delete('/jobs/$jobId');
    } catch (e) {
      rethrow;
    }
  }

  // Application endpoints
  Future<Map<String, dynamic>> applyJob({
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    try {
      final data = {
        if (coverLetter != null) 'cover_letter': coverLetter,
        if (resumeUrl != null) 'resume_url': resumeUrl,
      };

      final response = await _dio.post('/jobs/$jobId/apply', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyApplications({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '/my-applications',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawApplication(int applicationId) async {
    try {
      await _dio.post('/applications/$applicationId/withdraw');
    } catch (e) {
      rethrow;
    }
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _dio.get('/admin/stats');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
