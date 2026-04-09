// lib/core/config/app_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// Environment-aware configuration for Development, Staging, and Production.
//
// Usage:
//   - Access via: AppConfig.apiBaseUrl, AppConfig.enableDebugLogs, etc.
//   - Initialize in main.dart: AppConfig.initialize(Flavor.production)
//
// Flavor Strategy:
//   • Development: localhost:8000, debug logs enabled, verbose error messages
//   • Staging: staging.portfolioph.dev, minimal logs, production-like behavior
//   • Production: api.portfolioph.dev, no logs, security hardened
//
// Building with Flavors:
//   flutter build apk --flavor production -t lib/main_production.dart
//   flutter build apk --flavor staging -t lib/main_staging.dart
//   flutter build apk --flavor development -t lib/main_development.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

enum Flavor { development, staging, production }

class AppConfig {
  static bool _isInitialized = false;
  static late Flavor _currentFlavor;
  static late String _apiBaseUrl;
  static late bool _enableDebugLogs;
  static late bool _enableAnalytics;
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Initialize configuration for the given flavor
  static void initialize(Flavor flavor) {
    _currentFlavor = flavor;

    switch (flavor) {
      case Flavor.development:
        _apiBaseUrl = _resolveDevelopmentApiBaseUrl();
        _enableDebugLogs = true;
        _enableAnalytics = false;
        break;
      case Flavor.staging:
        // Configuration note: replace with your staging domain if different.
        _apiBaseUrl = 'https://staging-api.portfolioph.dev/api';
        _enableDebugLogs = false;
        _enableAnalytics = true;
        break;
      case Flavor.production:
        // Configuration note: replace with your production domain if different.
        _apiBaseUrl = 'https://api.portfolioph.dev/api';
        _enableDebugLogs = false;
        _enableAnalytics = true;
        break;
    }

    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;

  /// Get the current flavor
  static Flavor get currentFlavor => _currentFlavor;

  /// Get the API base URL
  static String get apiBaseUrl => _apiBaseUrl;

  static String _resolveDevelopmentApiBaseUrl() {
    // Highest priority: explicit runtime override via --dart-define.
    if (_apiBaseUrlOverride.trim().isNotEmpty) {
      return _apiBaseUrlOverride.trim();
    }

    // Browser builds can fail DNS/CORS checks more often with localhost.
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    return 'http://localhost:8000/api';
  }

  /// Check if debug logs are enabled (disabled in prod)
  static bool get enableDebugLogs => _enableDebugLogs;

  /// Check if analytics should be enabled
  static bool get enableAnalytics => _enableAnalytics;

  /// Check if we're in production
  static bool get isProduction => _currentFlavor == Flavor.production;

  /// Check if we're in development
  static bool get isDevelopment => _currentFlavor == Flavor.development;

  /// Check if we're in staging
  static bool get isStaging => _currentFlavor == Flavor.staging;
}
