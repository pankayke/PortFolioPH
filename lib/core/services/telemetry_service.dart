import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';

class TelemetryService {
  TelemetryService._();

  static bool _initialized = false;

  static const String _dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const String _environmentOverride = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: '',
  );

  static bool get isEnabled => _dsn.trim().isNotEmpty;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (!isEnabled) {
      _initialized = true;
      if (AppConfig.enableDebugLogs) {
        AppLogger.warning('Telemetry disabled: SENTRY_DSN is not set.');
      }
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = _dsn.trim();
      options.environment = _resolveEnvironment();
      options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
      options.enableAutoSessionTracking = true;
      options.attachStacktrace = true;
      options.debug = AppConfig.enableDebugLogs;
    });

    _initialized = true;

    AppLogger.configureTelemetry(reporter: capture);
    _bindGlobalErrorHandlers();
    AppLogger.success('Telemetry initialized for ${_resolveEnvironment()}');
  }

  static Future<void> capture(AppLogEvent event) async {
    if (!_initialized || !isEnabled) return;

    final level = switch (event.level) {
      AppLogLevel.debug => SentryLevel.debug,
      AppLogLevel.info => SentryLevel.info,
      AppLogLevel.warning => SentryLevel.warning,
      AppLogLevel.error => SentryLevel.error,
      AppLogLevel.success => SentryLevel.info,
    };

    final hint = Hint.withMap({'flavor': event.flavor.name});

    if (event.error != null) {
      await Sentry.captureException(
        event.error,
        stackTrace: event.stackTrace,
        withScope: (scope) {
          scope.level = level;
          scope.setTag('app.flavor', event.flavor.name);
          scope.setTag(
            'app.analytics_enabled',
            AppConfig.enableAnalytics.toString(),
          );
          scope.setContexts('telemetry_error', {
            'message': event.message,
            if (event.error != null) 'error': event.error.toString(),
            if (event.stackTrace != null)
              'stack_trace': event.stackTrace.toString(),
          });
        },
        hint: hint,
      );
      return;
    }

    await Sentry.captureMessage(
      event.message,
      level: level,
      withScope: (scope) {
        scope.setTag('app.flavor', event.flavor.name);
        scope.setTag(
          'app.analytics_enabled',
          AppConfig.enableAnalytics.toString(),
        );
      },
      hint: hint,
    );
  }

  static void _bindGlobalErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (!_initialized || !isEnabled) return;

      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
        withScope: (scope) {
          scope.setTag('app.flavor', AppConfig.currentFlavor.name);
        },
      );
    };

    PlatformDispatcher.instance.onError =
        (Object error, StackTrace stackTrace) {
          if (!_initialized || !isEnabled) {
            return false;
          }

          Sentry.captureException(
            error,
            stackTrace: stackTrace,
            withScope: (scope) {
              scope.setTag('app.flavor', AppConfig.currentFlavor.name);
            },
          );
          return true;
        };
  }

  static String _resolveEnvironment() {
    if (_environmentOverride.trim().isNotEmpty) {
      return _environmentOverride.trim();
    }

    if (AppConfig.isProduction) return 'production';
    if (AppConfig.isStaging) return 'staging';
    return 'development';
  }
}
