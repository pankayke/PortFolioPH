// lib/data/repositories/contact_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// API-First Repository: Contacts stored on backend only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/contact_model.dart';

class ContactRepository {
  final ApiService _apiService;

  ContactRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  Future<int> insert(ContactModel contact) async {
    try {
      final response = await _apiService.post(
        '/users/${contact.userId}/contacts',
        data: contact.toMap(),
      );
      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw Exception('Failed to create contact');
    } catch (e) {
      throw Exception('Failed to insert contact: $e');
    }
  }

  Future<List<ContactModel>> findByUserId(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/contacts');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => ContactModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch contacts: $e');
    }
  }

  Future<int> update(ContactModel contact) async {
    try {
      final response = await _apiService.put(
        '/contacts/${contact.id}',
        data: contact.toMap(),
      );
      if (response.statusCode == 200) {
        return 1;
      }
      throw Exception('Failed to update contact');
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final response = await _apiService.delete('/contacts/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      }
      throw Exception('Failed to delete contact');
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }
}
