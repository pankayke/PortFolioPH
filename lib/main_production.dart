// lib/main_production.dart
// ─────────────────────────────────────────────────────────────────────────────
// Production flavor entry point with security hardening.
// 
// - Debug logs disabled
// - No sensitive data exposed
// - Optimized performance
// - Analytics enabled
// 
// Build: flutter run -t lib/main_production.dart --release
// Or: flutter build apk --flavor production -t lib/main_production.dart --release
// Or: flutter build appbundle --flavor production -t lib/main_production.dart --release
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/main.dart' as app;

void main() {
  AppConfig.initialize(Flavor.production);
  app.main();
}
