// lib/main_staging.dart
// ─────────────────────────────────────────────────────────────────────────────
// Staging flavor entry point for QA/testing before production.
//
// Build: flutter run -t lib/main_staging.dart
// Or: flutter build apk --flavor staging -t lib/main_staging.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/main.dart' as app;

void main() {
  AppConfig.initialize(Flavor.staging);
  app.main();
}
