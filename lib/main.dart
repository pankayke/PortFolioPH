// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// PortFolioPH – Application entry point.
//
// Wires together:
//   • MultiProvider (UserProvider, ThemeProvider, NavigationProvider,
//     PortfolioProvider)
//   • GoRouter (created from AppRouter.create, reads UserProvider for guards)
//   • MaterialApp.router (Material 3, light + dark themes from AppTheme)
//
// Sprint 1 flow: main() → App → SplashScreen → DB open → /login | /dashboard
// Sprint 2 flow: /register → /profile-setup → /dashboard; /login → /dashboard
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/services/telemetry_service.dart';
import 'package:portfolioph/core/services/toast_service.dart';
import 'package:portfolioph/core/theme/app_theme.dart';
import 'package:portfolioph/presentation/providers/app_providers.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';

void main() async {
  // Ensure binding is initialised before any plugin calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration only when this entrypoint is used directly.
  if (!AppConfig.isInitialized) {
    AppConfig.initialize(Flavor.development);
  }

  // Initialize telemetry if Sentry DSN is provided.
  await TelemetryService.initialize();

  // Online-only architecture: no local SQLite

  // Lock orientation to portrait for mobile-first UX (mobile only).
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialise theme preference before first paint to avoid flicker.
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(App(themeProvider: themeProvider));
}

class App extends StatelessWidget {
  final ThemeProvider themeProvider;

  const App({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviderRegistry.build(themeProvider),
      child: const _RouterScope(),
    );
  }
}

/// Separate widget so GoRouter can read AuthProvider from context after it is
/// provided by [App] above.
class _RouterScope extends StatefulWidget {
  const _RouterScope();

  @override
  State<_RouterScope> createState() => _RouterScopeState();
}

class _RouterScopeState extends State<_RouterScope> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build the router once, after providers are available in context.
    _router ??= AppRouter.create(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final router = _router;
    if (router == null) return const SizedBox.shrink();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      scaffoldMessengerKey: ToastService.scaffoldMessengerKey,
      routerConfig: router,
    );
  }
}
