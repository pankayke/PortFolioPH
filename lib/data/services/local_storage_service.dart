import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local Storage Service
///
/// Handles SharedPreferences and local data persistence
class LocalStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _instance();
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _instance();
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance();
    return prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance();
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _instance();
    return prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _instance();
    return prefs.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    final prefs = await _instance();
    return prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await _instance();
    return prefs.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _instance();
    return prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance();
    return prefs.getStringList(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final raw = await getString(key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  Future<bool> remove(String key) async {
    final prefs = await _instance();
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final prefs = await _instance();
    return prefs.clear();
  }

  Future<bool> containsKey(String key) async {
    final prefs = await _instance();
    return prefs.containsKey(key);
  }
}
