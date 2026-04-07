// test/widget_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Sprint 1 – Smoke test: ensures the app compiles and the root widget mounts.
// Full unit + integration tests will be added from Sprint 3 onward.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/main.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('App widget mounts without exceptions', (tester) async {
    AppConfig.initialize(Flavor.development);
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(App(themeProvider: themeProvider));
    await tester.pump(const Duration(seconds: 4));
    // Verify the widget tree builds – SplashScreen should be the initial route.
    expect(find.byType(App), findsOneWidget);
  });
}
