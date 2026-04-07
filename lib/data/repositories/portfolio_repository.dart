// lib/data/repositories/portfolio_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Portfolios stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/portfolio_model.dart';

class PortfolioRepository {
  final ApiService _apiService;

  PortfolioRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(PortfolioModel portfolio) async {
    try {
      final response = await _apiService.post(
        '/users/${portfolio.userId}/portfolios',
        data: portfolio.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create portfolio');
    } catch (e) {
      throw Exception('Failed to insert portfolio: $e');
    }
  }

  Future<PortfolioModel?> findById(int id) async {
    try {
      final response = await _apiService.get('/portfolios/$id');
      if (response.statusCode == 200) {
        return PortfolioModel.fromMap(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch portfolio: $e');
    }
  }

  Future<List<PortfolioModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/portfolios');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => PortfolioModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch portfolios: $e');
    }
  }

  Future<int> update(PortfolioModel portfolio) async {
    try {
      final response = await _apiService.put(
        '/portfolios/${portfolio.id}',
        data: portfolio.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update portfolio');
    } catch (e) {
      throw Exception('Failed to update portfolio: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/portfolios/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete portfolio');
    } catch (e) {
      throw Exception('Failed to delete portfolio: $e');
    }
  }
}
