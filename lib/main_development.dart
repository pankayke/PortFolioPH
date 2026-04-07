// lib/main_development.dart
// ─────────────────────────────────────────────────────────────────────────────
// Development flavor entry point with debug logs enabled.
// 
// Build: flutter run -t lib/main_development.dart
// Or: flutter build apk --flavor development -t lib/main_development.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/main.dart' as app;

void main() {
  AppConfig.initialize(Flavor.development);
  app.main();
}
