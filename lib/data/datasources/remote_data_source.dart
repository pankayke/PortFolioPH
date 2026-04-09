import 'package:dio/dio.dart';

/// Remote Data Source
///
/// Handles all API calls and network operations
abstract class RemoteDataSource {
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}

class RemoteDataSourceImpl implements RemoteDataSource {
  RemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: _mergeHeaders(headers),
    );
    return _asMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeHeaders(headers),
    );
    return _asMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeHeaders(headers),
    );
    return _asMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeHeaders(headers),
    );
    return _asMap(response.data);
  }

  Options _mergeHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return Options();
    return Options(headers: headers);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }
}
