// lib/core/utils/logging_utils.dart
// ─────────────────────────────────────────────────────────────────────────────
// Production-safe logging utility that respects environment configuration.
// 
// Usage:
//   AppLogger.log('Simple message');
//   AppLogger.debug('Debug info', error: e, stackTrace: st);
//   AppLogger.error('Error occurred');
// 
// In production (AppConfig.isProduction):
//   - All logs are suppressed (no console output)
//   - Errors can optionally be sent to analytics/sentry
// 
// In development (AppConfig.isDevelopment):
//   - All logs are printed with colored prefixes
//   - Full error details shown
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:portfolioph/core/config/app_config.dart';

class AppLogger {
  /// Log a simple message (always logged in debug, suppressed in production)
  static void log(String message) {
    if (AppConfig.enableDebugLogs) {
      debugPrint('ℹ️  INFO: $message');
    }
  }

  /// Log debug information
  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (AppConfig.enableDebugLogs) {
      final errorStr = error != null ? '\nError: $error' : '';
      final stackStr = stackTrace != null ? '\nStackTrace: $stackTrace' : '';
      debugPrint('🐛 DEBUG: $message$errorStr$stackStr');
    }
  }

  /// Log an error
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Always log errors, even in production (but without stack traces)
    final errorStr = AppConfig.enableDebugLogs && error != null
        ? '\nError: $error'
        : '';
    final stackStr =
        AppConfig.enableDebugLogs && stackTrace != null ? '\nStackTrace: $stackTrace' : '';
    debugPrint('❌ ERROR: $message$errorStr$stackStr');

    // In production, optionally send to analytics/sentry
    if (AppConfig.isProduction) {
      // TODO: Send to Sentry or analytics service
      // SentryService.captureException(error, stackTrace);
    }
  }

  /// Log a warning
  static void warning(String message) {
    if (AppConfig.enableDebugLogs) {
      debugPrint('⚠️  WARNING: $message');
    }
  }

  /// Log success
  static void success(String message) {
    if (AppConfig.enableDebugLogs) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}
