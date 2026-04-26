import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _defaultDevApiBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _defaultProdApiBaseUrl = 'https://api.portfolioph.dev/api';
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    final override = _apiBaseUrlOverride.trim();
    final value =
        override.isNotEmpty
            ? override
            : (kReleaseMode ? _defaultProdApiBaseUrl : _defaultDevApiBaseUrl);

    _validateApiBaseUrl(value);
    return value;
  }

  static const String apiTimeout = '30';

  static void _validateApiBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('Invalid API_BASE_URL: $value');
    }

    if (!kReleaseMode) {
      return;
    }

    final isLocalHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (uri.scheme != 'https' || isLocalHost) {
      throw StateError(
        'Release builds require a non-localhost https API endpoint. Received: $value',
      );
    }
  }
}
