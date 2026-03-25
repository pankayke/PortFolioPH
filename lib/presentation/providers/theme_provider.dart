// lib/presentation/providers/theme_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages the app-wide ThemeMode, persisted via SharedPreferences.
//
// Features:
// - Persists theme preference across app sessions
// - Supports Light, Dark, and System (OS-based) modes
// - Error handling for storage failures
// - Graceful fallback to system theme on error
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // ── Initialise from storage ───────────────────────────────────────────────────
  /// Loads the saved theme preference from SharedPreferences.
  ///
  /// If loading fails or no preference is saved, defaults to [ThemeMode.system].
  /// This method should be called before the app is first rendered to prevent
  /// theme flicker.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(AppConstants.prefThemeMode) ?? 'system';
      _themeMode = _parse(saved);
    } catch (e) {
      // Graceful fallback: use system theme on error
      debugPrint('[ThemeProvider] Failed to load theme preference: $e');
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────────────────────
  /// Sets the theme mode and persists it to SharedPreferences.
  ///
  /// Updates the UI immediately (notifyListeners), then persists asynchronously.
  /// If persistence fails, the theme still updates in-memory.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefThemeMode, _serialize(mode));
    } catch (e) {
      debugPrint('[ThemeProvider] Failed to save theme preference: $e');
      // Theme is still updated in-memory, persistence just failed
    }
  }

  /// Toggles between light and dark modes.
  ///
  /// If in system mode, switches to dark. Otherwise, alternates between
  /// light and dark.
  Future<void> toggleDarkMode() async {
    final next = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  /// Parses a string value to ThemeMode.
  ThemeMode _parse(String value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// Serializes a ThemeMode to string for persistence.
  String _serialize(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    _ => 'system',
  };
}
